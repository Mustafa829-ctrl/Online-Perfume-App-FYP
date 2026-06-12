import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/admin_model.dart';
import 'package:online_perfume_app_fyp/models/complaint_model.dart';
import 'package:online_perfume_app_fyp/models/expense_model.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/models/rider_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/models/user_model.dart';

class AdminService {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _admins     = 'admins';
  static const String _sellers    = 'sellers';
  static const String _buyers     = 'users';
  static const String _riders     = 'riders';
  static const String _orders     = 'orders';
  static const String _products   = 'products';
  static const String _complaints = 'complaints';
  static const String _expenses   = 'expenses';

  // ════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════

  /// Get current logged-in admin
  Future<AdminModel> getCurrentAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No admin logged in.';
      final doc = await _firestore
          .collection(_admins)
          .doc(user.uid)
          .get();
      if (!doc.exists) throw 'Admin data not found.';

      // Get the data map
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Add the document ID to the map (if not already present)
      data['docId'] = doc.id;

      return AdminModel.fromJson(data);
    } catch (e) {
      throw e.toString();
    }
  }
  // ════════════════════════════════════════
  // ADMIN PROFILE
  // ════════════════════════════════════════

  /// Update Admin Profile
  Future<void> updateAdminProfile({
    required String adminId,
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (profileImage != null) 'profileImage': profileImage,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection(_admins)
          .doc(adminId)
          .update(data);

    } catch (e) {
      throw e.toString();
    }
  }

  /// Get buyer details from users collection by buyerId
  Future<Map<String, String>> getBuyerDetails(
      String buyerId) async {
    try {
      final doc = await _firestore
          .collection(_buyers)
          .doc(buyerId)
          .get();
      if (!doc.exists) return {};
      final data = doc.data() as Map<String, dynamic>;
      return {
        'name':    data['name']  ?? '',
        'email':   data['email'] ?? '',
        'phone':   data['phone'] ?? '',
        'address': data['address'] ?? '',
      };
    } catch (e) {
      return {};
    }
  }

  // ════════════════════════════════════════
  // DASHBOARD STATS
  // ════════════════════════════════════════

  /// Get all dashboard counts in one call
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _firestore.collection(_sellers).count().get(),
        _firestore.collection(_buyers).count().get(),
        _firestore.collection(_riders).count().get(),
        _firestore.collection(_orders).count().get(),
        _firestore.collection(_products).count().get(),
        _firestore
            .collection(_complaints)
            .where('status', isEqualTo: 'Pending')
            .count()
            .get(),
        _firestore
            .collection(_sellers)
            .where('isVerified', isEqualTo: false)
            .where('isBlocked', isEqualTo: false)
            .count()
            .get(),
        _firestore
            .collection(_orders)
            .where('status', whereIn: [
          'Cancelled',
          'Returned',
          'Not Delivered'
        ])
            .count()
            .get(),
      ]);

      return {
        'totalSellers':         results[0].count ?? 0,
        'totalBuyers':          results[1].count ?? 0,
        'totalRiders':          results[2].count ?? 0,
        'totalOrders':          results[3].count ?? 0,
        'totalProducts':        results[4].count ?? 0,
        'pendingComplaints':    results[5].count ?? 0,
        'pendingVerifications': results[6].count ?? 0,
        'issuedOrders':         results[7].count ?? 0,
      };
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // SELLER MANAGEMENT
  // ════════════════════════════════════════

  /// Get all sellers
  Future<List<SellerModel>> getAllSellers() async {
    try {
      final snap = await _firestore
          .collection(_sellers)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => SellerModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get sellers pending verification
  Future<List<SellerModel>> getPendingVerificationSellers() async {
    try {
      final snap = await _firestore
          .collection(_sellers)
          .where('isVerified', isEqualTo: false)
          .where('isBlocked', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => SellerModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get seller by ID
  Future<SellerModel> getSellerById(String sellerId) async {
    try {
      final doc = await _firestore
          .collection(_sellers)
          .doc(sellerId)
          .get();
      if (!doc.exists) throw 'Seller not found.';
      return SellerModel.fromJson(
          doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get seller performance metrics
  /// Returns: totalOrders, deliveredOrders, cancelledOrders,
  /// completionRate, avgRating, totalRevenue
  Future<Map<String, dynamic>> getSellerPerformance(
      String sellerId) async {
    try {
      final results = await Future.wait([
        // All seller orders
        _firestore
            .collection(_orders)
            .where('sellerId', isEqualTo: sellerId)
            .get(),
        // All seller product reviews (for avg rating)
        _firestore
            .collection('reviews')
            .where('sellerId', isEqualTo: sellerId)
            .get(),
      ]);

      final orderDocs = results[0].docs;
      final reviewDocs = results[1].docs;

      final totalOrders = orderDocs.length;
      final deliveredOrders = orderDocs
          .where((d) =>
      (d.data() as Map)['status'] == 'Delivered')
          .length;
      final cancelledOrders = orderDocs
          .where((d) =>
      (d.data() as Map)['status'] == 'Cancelled')
          .length;
      final returnedOrders = orderDocs
          .where((d) =>
      (d.data() as Map)['status'] == 'Returned')
          .length;

      final completionRate = totalOrders == 0
          ? 0.0
          : (deliveredOrders / totalOrders * 100);

      // Average rating from reviews
      double avgRating = 0.0;
      if (reviewDocs.isNotEmpty) {
        final totalRating = reviewDocs.fold<double>(
            0.0,
                (sum, d) =>
            sum +
                ((d.data() as Map)['rating'] as num? ?? 0)
                    .toDouble());
        avgRating = totalRating / reviewDocs.length;
      }

      // Total revenue from delivered orders
      final totalRevenue = orderDocs
          .where((d) =>
      (d.data() as Map)['status'] == 'Delivered')
          .fold<double>(
          0.0,
              (sum, d) =>
          sum +
              (((d.data() as Map)['amount'] as num?) ?? 0)
                  .toDouble());

      // Flag low performer:
      // completion rate < 70% OR avg rating < 3.0
      final isLowPerformer =
          completionRate < 70 || avgRating < 3.0;

      return {
        'totalOrders':      totalOrders,
        'deliveredOrders':  deliveredOrders,
        'cancelledOrders':  cancelledOrders,
        'returnedOrders':   returnedOrders,
        'completionRate':
        double.parse(completionRate.toStringAsFixed(1)),
        'avgRating':
        double.parse(avgRating.toStringAsFixed(1)),
        'totalRevenue':     totalRevenue,
        'isLowPerformer':   isLowPerformer,
      };
    } catch (e) {
      throw e.toString();
    }
  }

  /// Verify seller
  /// TODO: send push notification when notification API added
  Future<void> verifySeller(String sellerId) async {
    try {
      await _firestore
          .collection(_sellers)
          .doc(sellerId)
          .update({
        'isVerified': true,
        'status':     'active',
        'verifiedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unverify seller — blocks access, keeps Firestore doc
  /// TODO: send push notification when notification API added
  /// TODO: delete Firebase Auth account via Cloud Function
  Future<void> unverifySeller(String sellerId) async {
    try {
      await _firestore
          .collection(_sellers)
          .doc(sellerId)
          .update({
        'isVerified':    false,
        'isBlocked':     true,
        'status':        'unverified',
        'blockedReason': 'Account unverified by admin.',
        'unverifiedAt':  DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Block seller
  /// TODO: send push notification when notification API added
  Future<void> blockSeller({
    required String sellerId,
    required String reason,
  }) async {
    try {
      await _firestore
          .collection(_sellers)
          .doc(sellerId)
          .update({
        'isBlocked':     true,
        'status':        'blocked',
        'blockedReason': reason,
        'blockedAt':     DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unblock seller
  /// TODO: send push notification when notification API added
  Future<void> unblockSeller(String sellerId) async {
    try {
      await _firestore
          .collection(_sellers)
          .doc(sellerId)
          .update({
        'isBlocked':     false,
        'status':        'active',
        'blockedReason': null,
        'unblockedAt':   DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search sellers by name, email or businessName
  Future<List<SellerModel>> searchSellers(String query) async {
    try {
      final snap = await _firestore
          .collection(_sellers)
          .orderBy('createdAt', descending: true)
          .get();
      final q = query.toLowerCase();
      return snap.docs
          .map((doc) => SellerModel.fromJson(
          doc.data()))
          .where((s) =>
      (s.name?.toLowerCase().contains(q) ?? false) ||
          (s.email?.toLowerCase().contains(q) ?? false) ||
          (s.businessName?.toLowerCase().contains(q) ??
              false))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // BUYER MANAGEMENT
  // ════════════════════════════════════════

  /// Get all buyers
  Future<List<UserModel>> getAllBuyers() async {
    try {
      final snap = await _firestore
          .collection(_buyers)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => UserModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Block buyer
  /// TODO: send push notification when notification API added
  Future<void> blockBuyer({
    required String buyerId,
    required String reason,
  }) async {
    try {
      await _firestore
          .collection(_buyers)
          .doc(buyerId)
          .update({
        'isBlocked':     true,
        'blockedReason': reason,
        'blockedAt':     DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unblock buyer
  /// TODO: send push notification when notification API added
  Future<void> unblockBuyer(String buyerId) async {
    try {
      await _firestore
          .collection(_buyers)
          .doc(buyerId)
          .update({
        'isBlocked':     false,
        'blockedReason': null,
        'unblockedAt':   DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search buyers
  Future<List<UserModel>> searchBuyers(String query) async {
    try {
      final snap = await _firestore
          .collection(_buyers)
          .orderBy('createdAt', descending: true)
          .get();
      final q = query.toLowerCase();
      return snap.docs
          .map((doc) => UserModel.fromJson(
          doc.data()))
          .where((u) =>
      (u.name?.toLowerCase().contains(q) ?? false) ||
          (u.email?.toLowerCase().contains(q) ?? false) ||
          (u.phone?.contains(q) ?? false))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // RIDER MANAGEMENT
  // ════════════════════════════════════════

  /// Get all riders
  Future<List<RiderModel>> getAllRiders() async {
    try {
      final snap = await _firestore
          .collection(_riders)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => RiderModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Block rider
  /// TODO: send push notification when notification API added
  Future<void> blockRider({
    required String riderId,
    required String reason,
  }) async {
    try {
      await _firestore
          .collection(_riders)
          .doc(riderId)
          .update({
        'isBlocked':     true,
        'status':        'blocked',
        'blockedReason': reason,
        'blockedAt':     DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unblock rider
  /// TODO: send push notification when notification API added
  Future<void> unblockRider(String riderId) async {
    try {
      await _firestore
          .collection(_riders)
          .doc(riderId)
          .update({
        'isBlocked':     false,
        'status':        'active',
        'blockedReason': null,
        'unblockedAt':   DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search riders
  Future<List<RiderModel>> searchRiders(String query) async {
    try {
      final snap = await _firestore
          .collection(_riders)
          .orderBy('createdAt', descending: true)
          .get();
      final q = query.toLowerCase();
      return snap.docs
          .map((doc) => RiderModel.fromJson(
          doc.data()))
          .where((r) =>
      (r.name?.toLowerCase().contains(q) ?? false) ||
          (r.phone?.contains(q) ?? false) ||
          (r.email?.toLowerCase().contains(q) ?? false))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Assign order to rider (admin override)
  Future<void> assignOrderToRider({
    required String orderId,
    required String riderId,
    required String riderName,
  }) async {
    try {
      await _firestore
          .collection(_orders)
          .doc(orderId)
          .update({
        'riderId':    riderId,
        'riderName':  riderName,
        'status':     'Dispatched',
        'assignedAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt':  DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get rider salary summary
  /// Calculates: totalDeliveries, totalCODCollected,
  /// pendingPayments, completedPayments
  Future<Map<String, dynamic>> getRiderSalarySummary(
      String riderId) async {
    try {
      final snap = await _firestore
          .collection(_orders)
          .where('riderId', isEqualTo: riderId)
          .get();

      final allOrders = snap.docs
          .map((d) => d.data())
          .toList();

      final deliveredOrders = allOrders
          .where((o) => o['status'] == 'Delivered')
          .toList();

      final totalDeliveries  = deliveredOrders.length;
      final totalCOD         = deliveredOrders.fold<double>(
          0.0,
              (sum, o) =>
          sum + ((o['amount'] as num?) ?? 0).toDouble());
      final pendingPayments  = deliveredOrders
          .where((o) =>
      (o['riderPaymentStatus'] ?? 'Pending') ==
          'Pending')
          .fold<double>(
          0.0,
              (sum, o) =>
          sum +
              ((o['amount'] as num?) ?? 0).toDouble());
      final clearedPayments  = deliveredOrders
          .where((o) => o['riderPaymentStatus'] == 'Cleared')
          .fold<double>(
          0.0,
              (sum, o) =>
          sum +
              ((o['amount'] as num?) ?? 0).toDouble());

      return {
        'totalDeliveries':  totalDeliveries,
        'totalCOD':         totalCOD,
        'pendingPayments':  pendingPayments,
        'clearedPayments':  clearedPayments,
      };
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // ADD USER
  // ════════════════════════════════════════

  /// Admin creates a new seller account
  Future<void> addSeller({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      final userCred =
      await _auth.createUserWithEmailAndPassword(
        email:    email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final seller = SellerModel(
        docId:      uid,
        sellerId:   uid,
        name:       name,
        email:      email,
        phone:      phone,
        address:    address,
        isVerified: false,
        isBlocked:  false,
        role:       'seller',
        status:     'pending',
        createdAt:  DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection(_sellers)
          .doc(uid)
          .set(seller.toJson(uid));

      // TODO: send welcome notification when API added
    } catch (e) {
      throw e.toString();
    }
  }

  /// Admin creates a new rider account
  Future<void> addRider({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    String? sellerId,
    String? sellerName,
  }) async {
    try {
      final userCred =
      await _auth.createUserWithEmailAndPassword(
        email:    email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final rider = RiderModel(
        docId:     uid,
        riderId:   uid,
        name:      name,
        email:     email,
        phone:     phone,
        address:   address,
        isBlocked: false,
        role:      'rider',
        status:    'active',
        sellerId:  sellerId ?? '',
        sellerName: sellerName ?? '',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection(_riders)
          .doc(uid)
          .set(rider.toJson(uid));

      // TODO: send welcome notification when API added
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // ORDER MANAGEMENT
  // ════════════════════════════════════════

  /// Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snap = await _firestore
          .collection(_orders)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get issued/problematic orders
  Future<List<OrderModel>> getIssuedOrders() async {
    try {
      final snap = await _firestore
          .collection(_orders)
          .where('status', whereIn: [
        'Cancelled',
        'Returned',
        'Not Delivered',
      ])
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(
      String status) async {
    try {
      final snap = await _firestore
          .collection(_orders)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get return order requests
  /// Return orders are tracked via status field in orders collection
  Future<List<OrderModel>> getReturnOrders() async {
    try {
      final snap = await _firestore
          .collection(_orders)
          .where('status', isEqualTo: 'Returned')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Process return order — admin approves or rejects
  Future<void> processReturnOrder({
    required String orderId,
    required bool approved,
    String? adminNote,
  }) async {
    try {
      await _firestore
          .collection(_orders)
          .doc(orderId)
          .update({
        'returnStatus':    approved ? 'Approved' : 'Rejected',
        'returnAdminNote': adminNote ?? '',
        'returnProcessedAt':
        DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Process reorder request
  /// Reorders reuse orders collection with isReorderRequest flag
  Future<void> processReorderRequest({
    required String orderId,
    required bool approved,
  }) async {
    try {
      await _firestore
          .collection(_orders)
          .doc(orderId)
          .update({
        'reorderStatus': approved ? 'Approved' : 'Rejected',
        'reorderProcessedAt':
        DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Admin override order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection(_orders)
          .doc(orderId)
          .update({
        'status':    status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }


  // ════════════════════════════════════════
  // COMPLAINT MANAGEMENT
  // ════════════════════════════════════════

  /// Get all complaints
  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      final snap = await _firestore
          .collection(_complaints)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ComplaintModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get complaints by status
  Future<List<ComplaintModel>> getComplaintsByStatus(
      String status) async {
    try {
      final snap = await _firestore
          .collection(_complaints)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ComplaintModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Reply to complaint — sets status to In Progress
  Future<void> replyToComplaint({
    required String docId,
    required String reply,
  }) async {
    try {
      await _firestore
          .collection(_complaints)
          .doc(docId)
          .update({
        'adminReply': reply,
        'status':     'In Progress',
        'repliedAt':  DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Resolve complaint
  Future<void> resolveComplaint({
    required String docId,
    required String reply,
  }) async {
    try {
      await _firestore
          .collection(_complaints)
          .doc(docId)
          .update({
        'adminReply':  reply,
        'status':      'Resolved',
        'resolvedAt':  DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Dismiss complaint
  Future<void> dismissComplaint(String docId) async {
    try {
      await _firestore
          .collection(_complaints)
          .doc(docId)
          .update({
        'status':      'Dismissed',
        'dismissedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update complaint status only
  Future<void> updateComplaintStatus({
    required String docId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection(_complaints)
          .doc(docId)
          .update({
        'status':    status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        if (status == 'Resolved')
          'resolvedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // PRODUCT MANAGEMENT
  // ════════════════════════════════════════

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snap = await _firestore
          .collection(_products)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ProductModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Remove product (admin takedown)
  Future<void> removeProduct(String productId) async {
    try {
      await _firestore
          .collection(_products)
          .doc(productId)
          .update({
        'isAvailable':    false,
        'removedByAdmin': true,
        'removedAt':
        DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Restore product
  Future<void> restoreProduct(String productId) async {
    try {
      await _firestore
          .collection(_products)
          .doc(productId)
          .update({
        'isAvailable':    true,
        'removedByAdmin': false,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // EXPENSE OVERVIEW (Admin read-only)
  // ════════════════════════════════════════

  /// Get all expenses across all sellers
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final snap = await _firestore
          .collection(_expenses)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ExpenseModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get expenses by seller
  Future<List<ExpenseModel>> getExpensesBySeller(
      String sellerId) async {
    try {
      final snap = await _firestore
          .collection(_expenses)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ExpenseModel.fromJson(
          doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // ════════════════════════════════════════
  // REAL-TIME STREAMS
  // ════════════════════════════════════════

  /// Stream of pending seller verifications (live badge)
  Stream<int> pendingVerificationsStream() {
    return _firestore
        .collection(_sellers)
        .where('isVerified', isEqualTo: false)
        .where('isBlocked', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Stream of pending complaints (live badge)
  Stream<int> pendingComplaintsStream() {
    return _firestore
        .collection(_complaints)
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Stream of all sellers (live list)
  Stream<List<SellerModel>> sellersStream() {
    return _firestore
        .collection(_sellers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => SellerModel.fromJson(
        doc.data()))
        .toList());
  }

  /// Stream of all buyers (live list)
  Stream<List<UserModel>> buyersStream() {
    return _firestore
        .collection(_buyers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => UserModel.fromJson(
        doc.data()))
        .toList());
  }

  /// Stream of all riders (live list)
  Stream<List<RiderModel>> ridersStream() {
    return _firestore
        .collection(_riders)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => RiderModel.fromJson(
        doc.data()))
        .toList());
  }

  /// Stream of all complaints (live list)
  Stream<List<ComplaintModel>> complaintsStream() {
    return _firestore
        .collection(_complaints)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ComplaintModel.fromJson(
        doc.data()))
        .toList());
  }

  /// Stream of issued orders (live list)
  Stream<List<OrderModel>> issuedOrdersStream() {
    return _firestore
        .collection(_orders)
        .where('status', whereIn: [
      'Cancelled',
      'Returned',
      'Not Delivered',
    ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => OrderModel.fromJson(
        doc.data()))
        .toList());
  }

  /// Stream of return orders (live list)
  Stream<List<OrderModel>> returnOrdersStream() {
    return _firestore
        .collection(_orders)
        .where('status', isEqualTo: 'Returned')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => OrderModel.fromJson(
        doc.data()))
        .toList());
  }
}