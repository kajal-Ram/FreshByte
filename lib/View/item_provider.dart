import 'package:flutter/material.dart';
import 'item.dart'; // Import Item model

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  void addItem(Item item) {
    _items.add(item);
    notifyListeners(); // Notify listeners that the item list has been updated
  }

  void removeItem(Item item) {
    _items.remove(item);
    notifyListeners(); // Notify listeners that the item list has been updated
  }

  void updateItem(int index, Item item) {
    _items[index] = item;
    notifyListeners(); // Notify listeners that the item at the index has been updated
  }
}
