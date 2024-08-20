import 'package:shopping_list/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.category,
    required this.id,
    required this.name,
    required this.quantity,
  });
  final String id;
  final String name;
  final Category category;
  final int quantity;
}
