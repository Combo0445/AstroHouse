import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final int basePrice; // price can be base or specific to an option
  final String? optionLabel; // e.g., 'seafood(ทะเล)'
  int quantity;

  // A unique ID to identify the exact variation of the item
  String get id => optionLabel != null ? '\$name-\$optionLabel' : name;

  int get unitPrice => basePrice;
  int get totalPrice => unitPrice * quantity;

  CartItem({
    required this.name,
    required this.basePrice,
    this.optionLabel,
    this.quantity = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem({
    required String name,
    required int price,
    String? optionLabel,
  }) {
    final newItemId = optionLabel != null ? '\$name-\$optionLabel' : name;

    // Check if item exist
    final existingIndex = _items.indexWhere((item) => item.id == newItemId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          name: name,
          basePrice: price,
          optionLabel: optionLabel,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String id, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(id);
      return;
    }
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
