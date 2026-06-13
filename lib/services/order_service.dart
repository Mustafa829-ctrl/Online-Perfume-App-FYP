import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // SELLER SIDE ORDER MANAGEMENT----------

  /// Get All Orders of a Seller
  Future<List<OrderModel>> getSellerOrders(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Orders by Status (Seller)
  Future<List<OrderModel>> getSellerOrdersByStatus({
    required String sellerId,
    required String status,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Order Status (Seller - Processing, Dispatched, etc.)
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? riderId,
    String? riderName,
    String? deliveryType,
    String? courierName,
    String? trackingNumber,
  }) async {
    try {
      Map<String, dynamic> data = {
        'status': status,
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      if (riderId != null) data['riderId'] = riderId;
      if (riderName != null) data['riderName'] = riderName;
      if (deliveryType != null) data['deliveryType'] = deliveryType;
      if (courierName != null) data['courierName'] = courierName;
      if (trackingNumber != null) data['trackingNumber'] = trackingNumber;

      await _firestore.collection(_collection).doc(orderId).update(data);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Cancel Order (Seller or Buyer)
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': 'Cancelled',
        'notDeliveredReason': reason,
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // RIDER + DELIVERY MANAGEMENT--------

  /// Assign Order to Rider
  Future<void> assignOrderToRider({
    required String orderId,
    required String riderId,
    required String riderName,
  }) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'riderId': riderId,
        'riderName': riderName,
        'status': 'Assigned',
        'assignedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Orders Assigned to a Rider
  Future<List<OrderModel>> getAssignedOrders(String riderId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('riderId', isEqualTo: riderId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Delivered Orders of a Rider
  Future<List<OrderModel>> getAllDeliveredOrders(String riderId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('riderId', isEqualTo: riderId)
          .where('status', isEqualTo: 'Delivered')
          .orderBy('deliveredAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Accept Order (Rider)
  Future<void> acceptOrder(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Accepted',
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Pick Up Delivery (Rider)
  Future<void> pickDelivery(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Picked',
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Mark Order In Transit (Rider)
  Future<void> markInTransit(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'In Transit',
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Mark Order Delivered (Rider)
  Future<void> markDelivered(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Delivered',
        'deliveredAt': DateTime
            .now()
            .millisecondsSinceEpoch,
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Reject Order (Rider)
  Future<void> rejectOrder(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Rejected',
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Mark Order Not Delivered (Rider)
  Future<void> markNotDelivered({
    required String docId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Not Delivered',
        'notDeliveredReason': reason,
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }
  /// Buyer/Seller submits return request
  Future<void> submitReturnRequest({
    required String docId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status':       'Returned',
        'returnReason': reason,
        'returnedAt':   DateTime.now().millisecondsSinceEpoch,
        'updatedAt':    DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ADMIN SIDE------

  /// Get All Orders (Admin)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Orders by Status (Admin)
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Complaint / Return Orders (Admin)
  Future<List<OrderModel>> getComplaintOrders() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', whereIn: ['Returned', 'Not Delivered', 'Cancelled'])
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // HELPER / STATS-----

  /// Get Total Orders Count
  Future<int> getTotalOrdersCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Today's Orders (Admin / Seller)
  Future<List<OrderModel>> getTodayOrders() async {
    try {
      final now = DateTime.now();
      final startOfDay =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Single Order
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

// ── PAYMENT MANAGEMENT (add these to your existing OrderService) ──────

  /// Rider marks buyer payment received (buyer paid cash to rider)
  /// Called from RIDER panel
  Future<void> markBuyerPaymentReceived(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'buyerPaymentStatus': 'Received',
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get all Delivered orders for a seller where buyer has paid
  /// (buyerPaymentStatus == 'Received') — these show in seller payments screen
  Future<List<OrderModel>> getSellerPayments(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('buyerPaymentStatus', isEqualTo: 'Received')
          .orderBy('deliveredAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Seller clears payment from RIDER
  /// → riderPaymentStatus: 'Cleared', order status: 'Completed', clearedAt set
  Future<void> clearRiderPayment(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'riderPaymentStatus': 'Cleared',
        'status': 'Completed',
        'clearedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Seller confirms remittance received from COURIER
  /// → riderPaymentStatus: 'Cleared', order status: 'Completed', clearedAt set
  Future<void> clearCourierPayment(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'riderPaymentStatus': 'Cleared',
        'status': 'Completed',
        'clearedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
        'updatedAt': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ── BUYER SIDE ORDER OPERATIONS--------

  /// Place Order from Checkout Screen
  /// Maps active cart items to your OrderModel structure, posts them, and flushes the cart.
  Future<void> placeOrder({
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    required List<Map<String, dynamic>> cartItems, // Raw items passed from your cart/state
  }) async {
    final WriteBatch batch = _firestore.batch();
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    try {
      for (var item in cartItems) {
        // Generate a clean distinct document path reference for each unique order item
        DocumentReference orderDocRef = _firestore.collection(_collection).doc();

        // 1. Map values directly to your custom OrderModel structure
        OrderModel newOrder = OrderModel(
          docId: orderDocRef.id,
          orderId: 'ORD-${timestamp.toString().substring(7)}-${orderDocRef.id.substring(0, 3).toUpperCase()}',
          buyerName: buyerName,
          buyerPhone: buyerPhone,
          buyerAddress: buyerAddress,
          productName: item['productName'] ?? 'Perfume',
          quantity: item['quantity'] ?? 1,
          amount: ((item['price'] as num? ?? 0.0) * (item['quantity'] as int? ?? 1)).toInt(),
          status: 'Pending', // Initial tracking bucket state before vendor assignment
          sellerId: item['sellerId'] ?? '',
          isPaid: false,
          buyerPaymentStatus: 'Pending',
          riderPaymentStatus: 'Pending',
          deliveryType: 'Rider',
          createdAt: timestamp,
        );

        // Stage the order document creation inside our active batch operation
        batch.set(orderDocRef, newOrder.toJson(orderDocRef.id));

        // 2. Stage the deletion of this specific item from the buyer's cart document subcollection
        DocumentReference cartItemDocRef = _firestore
            .collection('carts')
            .doc(buyerId)
            .collection('items')
            .doc(item['cartItemId']);

        batch.delete(cartItemDocRef);
      }

      // Execute all operations safely on the backend server atomically
      await batch.commit();
    } catch (e) {
      throw 'Failed to place order: ${e.toString()}';
    }
  }

  /// Get all orders for a specific buyer (by buyerId)
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('buyerId', isEqualTo: buyerId) 
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
