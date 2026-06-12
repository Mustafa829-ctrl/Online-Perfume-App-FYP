import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sellers';

  /// Get All Sellers (for Admin)
  Future<List<SellerModel>> getAllSellers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SellerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Pending Sellers (for verification)
  Future<List<SellerModel>> getPendingSellers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'Pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SellerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Approve / Verify Seller
  Future<void> verifySeller({
    required String sellerId,
    required bool isApproved,
  }) async {
    try {
      await _firestore.collection(_collection).doc(sellerId).update({
        'isVerified': isApproved,
        'status': isApproved ? 'Approved' : 'Rejected',
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Block Seller
  Future<void> blockSeller({
    required String sellerId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(sellerId).update({
        'isBlocked': true,
        'blockedReason': reason,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unblock Seller
  Future<void> unblockSeller({required String sellerId}) async {
    try {
      await _firestore.collection(_collection).doc(sellerId).update({
        'isBlocked': false,
        'blockedReason': null,
      });
    } catch (e) {
      throw e.toString();
    }
  }


  /// Get Current Seller (Already in SellerAuthService, but for consistency)
  Future<SellerModel> getSellerById(String sellerId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(_collection).doc(sellerId).get();

      if (!doc.exists) throw 'Seller not found.';

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
      });
    } catch (e) {
      throw e.toString();
    }
  }


  /// Get Seller Performance Stats
  Future<Map<String, dynamic>> getSellerPerformance(String sellerId) async {
    try {
      // Get total products
      QuerySnapshot productsSnap = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      // Get total orders
      QuerySnapshot ordersSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      // Get delivered orders
      QuerySnapshot deliveredSnap = await _firestore
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
        'successRate': successRate.toStringAsFixed(1),
      };
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Top Selling Products of Seller (Already in ProductService, but can call from here)
  Future<List<dynamic>> getTopSellingProducts(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('totalSold', descending: true)
          .limit(5)
          .get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search Sellers (Admin)
  Future<List<SellerModel>> searchSellers(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final allSellers = snapshot.docs
          .map((doc) => SellerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allSellers.where((seller) {
        final nameMatch = seller.name
            ?.toLowerCase()
            .contains(query.toLowerCase()) ??
            false;
        final businessMatch = seller.businessName
            ?.toLowerCase()
            .contains(query.toLowerCase()) ??
            false;
        return nameMatch || businessMatch;
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}