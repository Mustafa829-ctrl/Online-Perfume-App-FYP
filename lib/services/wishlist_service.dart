import 'package:flutter/foundation.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';

class WishlistService extends ChangeNotifier {
  // Singleton
  static final WishlistService instance = WishlistService._internal();
  WishlistService._internal();

  final List<WishlistItemModel> _items = [];

  List<WishlistItemModel> get items => List.unmodifiable(_items);

  bool isInWishlist(String productName) {
    return _items.any((item) => item.name == productName);
  }

  void toggleWishlist({
    required String name,
    required double price,
    required String imagePath,
  }) {
    final existingIndex = _items.indexWhere((item) => item.name == name);

    if (existingIndex != -1) {
      _items.removeAt(existingIndex);
    } else {
      _items.add(WishlistItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        price: price,
        imagePath: imagePath,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  int get wishlistCount => _items.length;
}
