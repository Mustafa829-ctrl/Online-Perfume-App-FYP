import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';   // Agar aap alag ThresholdModel banana chahte ho to batao

class ThresholdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';   // Hum products collection mein threshold manage kar rahe hain


  // THRESHOLD MANAGEMENT
  /// Add / Update Product Threshold (Low Stock Alert Level)
  Future<void> setThreshold({
    required String productId,
    required int threshold,
  }) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'threshold': threshold,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Low Stock Products for Seller
  Future<List<Map<String, dynamic>>> getLowStockProducts(
      String sellerId, int defaultThreshold) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('stock', isLessThanOrEqualTo: defaultThreshold)
          .orderBy('stock', descending: false)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Products with Custom Threshold
  Future<List<Map<String, dynamic>>> getProductsWithThreshold(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('threshold', isGreaterThan: 0)   // jo threshold set kiye hain
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Threshold for Multiple Products (Bulk)
  Future<void> updateBulkThreshold({
    required List<String> productIds,
    required int newThreshold,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String id in productIds) {
        DocumentReference docRef = _firestore.collection(_collection).doc(id);
        batch.update(docRef, {
          'threshold': newThreshold,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await batch.commit();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Single Product Threshold
  Future<int> getProductThreshold(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(productId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['threshold'] ?? 10;   // default 10
      }
      return 10;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Low Stock Alert Count for Seller Dashboard
  Future<int> getLowStockCount(String sellerId, int threshold) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('stock', isLessThanOrEqualTo: threshold)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }
}