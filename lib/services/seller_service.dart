import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sellers';

  /// Get Current Seller Profile
  Future<SellerModel> getCurrentSeller(String sellerId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(sellerId)
          .get();

      if (!doc.exists) throw 'Seller profile not found.';

      return SellerModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Seller Profile
  Future<void> updateSellerProfile({
    required String sellerId,
    required String name,
    required String phone,
    required String address,
    required String businessName,
    required String businessAddress,
    String? profileImageUrl,
  }) async {
    try {
      await _firestore.collection(_collection).doc(sellerId).update({
        'name': name,
        'phone': phone,
        'address': address,
        'businessName': businessName,
        'businessAddress': businessAddress,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }


  /// Get Seller Performance Stats
  Future<Map<String, dynamic>> getSellerPerformance(String sellerId) async {
    try {
      // Total Products
      final productsSnap = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      // Total Orders
      final ordersSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      // Delivered Orders
      final deliveredSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'Delivered')
          .get();

      int totalProducts = productsSnap.docs.length;
      int totalOrders = ordersSnap.docs.length;
      int deliveredOrders = deliveredSnap.docs.length;

      double successRate = totalOrders > 0
          ? (deliveredOrders / totalOrders) * 100
          : 0.0;

      return {
        'totalProducts': totalProducts,
        'totalOrders': totalOrders,
        'deliveredOrders': deliveredOrders,
        'successRate': successRate.toStringAsFixed(1) + "%",
        'pendingOrders': totalOrders - deliveredOrders,
      };
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Top Selling Products for Seller
  Future<List<Map<String, dynamic>>> getTopSellingProducts(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('totalSold', descending: true)
          .limit(5)
          .get();

      return snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }


  /// Get Low Stock Products
  Future<List<Map<String, dynamic>>> getLowStockProducts(String sellerId, int threshold) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .where('stock', isLessThanOrEqualTo: threshold)
          .orderBy('stock', descending: false)
          .get();

      return snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}