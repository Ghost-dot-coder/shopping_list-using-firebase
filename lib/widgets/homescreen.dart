import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/additem.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isLoading = true;
  List<GroceryItem> _groceryitems = [];

  @override
  void initState() {
    super.initState();
    _retrivedata();
  }

  void _retrivedata() async {
    final List<GroceryItem> recivedItem = [];
    final url = Uri.https('fire-practice-94933-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final response = await http.get(url);
    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listitem = json.decode(response.body);

    for (final items in listitem.entries) {
      final catego = categories.entries
          .firstWhere(
              (catitem) => catitem.value.title == items.value['category'])
          .value;
      recivedItem.add(
        GroceryItem(
          id: items.key,
          name: items.value['name'],
          quantity: items.value['quantity'],
          category: catego,
        ),
      );
    }

    setState(() {
      _groceryitems = recivedItem;
      _isLoading = false;
    });
  }

  void _onAdd() async {
    await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItem(),
      ),
    );
    _retrivedata();
  }

  void _onRemove(GroceryItem item) async {
    final index = _groceryitems.indexOf(item);
    setState(() {
      _groceryitems.remove(item);
    });
    final url = Uri.https('fire-practice-94933-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryitems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Item not added yet'),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryitems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryitems[index].id),
          onDismissed: (direction) {
            _onRemove(_groceryitems[index]);
          },
          child: ListTile(
            title: Text(_groceryitems[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryitems[index].category.color,
            ),
            trailing: Text(
              _groceryitems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: _onAdd,
              icon: const Icon(Icons.add),
            ),
          ],
          title: Text(
            'Your Groceries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        body: content);
  }
}
