import 'package:flutter/foundation.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  // Singleton
  static final CartService instance = CartService._internal();
  CartService._internal();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get total => subtotal; // Can add tax/shipping logic here later

  /// Adds item to cart. If it already exists (same name + volume), increments quantity.
  void addItem({
    required String productName,
    required double price,
    required String imagePath,
    required String selectedVolume,
  }) {
    final existingIndex = _items.indexWhere(
      (i) => i.productName == productName && i.selectedVolume == selectedVolume,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItemModel(
        productName: productName,
        price: price,
        imagePath: imagePath,
        selectedVolume: selectedVolume,
      ));
    }
    notifyListeners();
  }

  /// Increments the quantity of an existing item.
  void incrementQuantity(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index].quantity++;
    notifyListeners();
  }

  /// Decrements the quantity. Removes item if quantity reaches 0.
  void decrementQuantity(int index) {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  /// Removes an item entirely by index.
  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  /// Clears the entire cart.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
