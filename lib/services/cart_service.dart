import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'carts';

  // ── CART OPERATIONS

  /// Add to Cart
  Future<void> addToCart({
    required String buyerId,
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String sellerId,
    String? imageUrl,
  }) async {
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

  /// Get All Cart Items (Mapped to CartItemModel)
  Future<List<CartItemModel>> getCartItems(String buyerId) async {
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
    try {
      // Automatically clear item if quantity drops to zero
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

  /// Get Cart Total Amount
  Future<double> getCartTotal(String buyerId) async {
    try {
      List<CartItemModel> items = await getCartItems(buyerId);
      double total = 0.0;

      for (var item in items) {
        total += item.totalPrice;
      }
      return total;
    } catch (e) {
      throw e.toString();
    }
  }
}