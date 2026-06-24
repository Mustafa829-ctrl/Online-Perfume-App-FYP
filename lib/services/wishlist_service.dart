import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'wishlists';

  // ── Helper: Validate User
  void _validateBuyer(String buyerId) {
    if (buyerId.isEmpty) {
      throw 'User must be logged in to perform this action';
    }
  }

  // ── Add to Wishlist
  Future<void> addToWishlist({
    required String buyerId,
    required String productId,
    required String name,
    required double price,
    required String imagePath,
    required String sellerId,
  }) async {
    _validateBuyer(buyerId);

    try {
      final String wishlistItemId = '${buyerId}_$productId';

      await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(wishlistItemId)
          .set({
        'docId': wishlistItemId,
        'wishlistItemId': wishlistItemId,
        'productId': productId,
        'buyerId': buyerId,
        'name': name,
        'price': price,
        'imagePath': imagePath,
        'sellerId': sellerId,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Remove from Wishlist
  Future<void> removeFromWishlist({
    required String buyerId,
    required String productId,
  }) async {
    _validateBuyer(buyerId);

    try {
      final String wishlistItemId = '${buyerId}_$productId';

      await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(wishlistItemId)
          .delete();
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Toggle Wishlist
  Future<void> toggleWishlist({
    required String buyerId,
    required String productId,
    required String name,
    required double price,
    required String imagePath,
    required String sellerId,
  }) async {
    _validateBuyer(buyerId);

    try {
      final String wishlistItemId = '${buyerId}_$productId';

      final doc = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(wishlistItemId)
          .get();

      if (doc.exists) {
        await removeFromWishlist(buyerId: buyerId, productId: productId);
      } else {
        await addToWishlist(
          buyerId: buyerId,
          productId: productId,
          name: name,
          price: price,
          imagePath: imagePath,
          sellerId: sellerId,
        );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Check if in wishlist
  Future<bool> isInWishlist({
    required String buyerId,
    required String productId,
  }) async {
    if (buyerId.isEmpty) return false;

    try {
      final String wishlistItemId = '${buyerId}_$productId';

      final doc = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(wishlistItemId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ── Get wishlist stream
  Stream<List<WishlistItemModel>> getWishlistStream(String buyerId) {
    if (buyerId.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .doc(buyerId)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => WishlistItemModel.fromJson(doc.data()))
        .toList());
  }

  // ── Get all wishlist items
  Future<List<WishlistItemModel>> getWishlistItems(String buyerId) async {
    if (buyerId.isEmpty) return [];

    try {
      final snap = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => WishlistItemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Clear wishlist
  Future<void> clearWishlist(String buyerId) async {
    _validateBuyer(buyerId);

    try {
      final batch = _firestore.batch();
      final snap = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .get();

      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Wishlist count stream
  Stream<int> getWishlistCountStream(String buyerId) {
    if (buyerId.isEmpty) return Stream.value(0);

    return _firestore
        .collection(_collection)
        .doc(buyerId)
        .collection('items')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}