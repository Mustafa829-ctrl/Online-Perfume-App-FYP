import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'wishlists';

  // ── Add to Wishlist
  Future<void> addToWishlist({
    required String buyerId,
    required String productId,
    required String name,
    required double price,
    required String imagePath,
    required String sellerId,
  }) async {
    try {
      final String wishlistItemId = '${buyerId}_$productId';

      await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')

          .doc(wishlistItemId)
          .set({
        'docId':          wishlistItemId,
        'wishlistItemId': wishlistItemId,
        'productId':      productId,
        'buyerId':        buyerId,
        'name':           name,
        'price':          price,
        'imagePath':      imagePath,
        'sellerId':       sellerId,
        'addedAt':        DateTime.now().millisecondsSinceEpoch,
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

  // ── Toggle Wishlist (add if not exists, remove if exists)
  Future<void> toggleWishlist({
    required String buyerId,
    required String productId,
    required String name,
    required double price,
    required String imagePath,
    required String sellerId,
  }) async {
    try {
      final String wishlistItemId = '${buyerId}_$productId';

      final doc = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .doc(wishlistItemId)
          .get();

      if (doc.exists) {
        await removeFromWishlist(
            buyerId: buyerId, productId: productId);
      } else {
        await addToWishlist(
          buyerId:   buyerId,
          productId: productId,
          name:      name,
          price:     price,
          imagePath: imagePath,
          sellerId:  sellerId,
        );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Check if product is in wishlist
  Future<bool> isInWishlist({
    required String buyerId,
    required String productId,
  }) async {
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

  // ── Get wishlist items stream (real-time)
  Stream<List<WishlistItemModel>> getWishlistStream(String buyerId) {
    return _firestore
        .collection(_collection)
        .doc(buyerId)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) =>
        WishlistItemModel.fromJson(doc.data()))
        .toList());
  }

  // ── Get all wishlist items once
  Future<List<WishlistItemModel>> getWishlistItems(
      String buyerId) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .doc(buyerId)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .get();

      return snap.docs
          .map((doc) =>
          WishlistItemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // ── Clear entire wishlist
  Future<void> clearWishlist(String buyerId) async {
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

  // ── Get wishlist count stream (real-time badge)
  Stream<int> getWishlistCountStream(String buyerId) {
    return _firestore
        .collection(_collection)
        .doc(buyerId)
        .collection('items')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}