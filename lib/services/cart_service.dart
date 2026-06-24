import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'carts';

  // ── Helper: Validate User
  void _validateBuyer(String buyerId) {
    if (buyerId.isEmpty) {
      throw 'User must be logged in to perform this action';
    }
  }

  // ── Add to Cart
  Future<void> addToCart({
    required String buyerId,
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String sellerId,
    String? imageUrl,
  }) async {
    _validateBuyer(buyerId);

    try {
      String cartItemId = '${buyerId}_$productId';

      await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(cartItemId)
          .set({
        'cartItemId': cartItemId,
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'sellerId': sellerId,
        'imageUrl': imageUrl ?? '',
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Cart Items
  Future<List<CartItemModel>> getCartItems(String buyerId) async {
    if (buyerId.isEmpty) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Cart Item Quantity
  Future<void> updateCartQuantity({
    required String buyerId,
    required String cartItemId,
    required int newQuantity,
  }) async {
    _validateBuyer(buyerId);

    try {
      if (newQuantity <= 0) {
        await removeFromCart(buyerId: buyerId, cartItemId: cartItemId);
        return;
      }

      await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(cartItemId)
          .update({'quantity': newQuantity});
    } catch (e) {
      throw e.toString();
    }
  }

  /// Remove from Cart
  Future<void> removeFromCart({
    required String buyerId,
    required String cartItemId,
  }) async {
    _validateBuyer(buyerId);

    try {
      await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Clear Entire Cart
  Future<void> clearCart(String buyerId) async {
    _validateBuyer(buyerId);

    try {
      WriteBatch batch = _firestore.batch();
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Cart Total Amount - FIXED
  Future<double> getCartTotal(String buyerId) async {
    if (buyerId.isEmpty) return 0.0;

    try {
      List<CartItemModel> items = await getCartItems(buyerId);

      // Fixed: Use synchronous calculation
      return items.fold<double>(
        0.0,
            (double sum, CartItemModel item) => sum + (item.totalPrice ?? 0.0),
      );
    } catch (e) {
      throw e.toString();
    }
  }
}