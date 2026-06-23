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

  /// Update Order Status
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'assignedAt': DateTime.now().millisecondsSinceEpoch,
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'deliveredAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Submit Return Request
  Future<void> submitReturnRequest({
    required String docId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Returned',
        'returnReason': reason,
        'returnedAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
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

  /// Get Today's Orders
  Future<List<OrderModel>> getTodayOrders() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
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

  // ── PAYMENT MANAGEMENT ──────

  /// Rider confirms payment received
  Future<void> markBuyerPaymentReceived(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'buyerPaymentStatus': 'Received',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get seller payments
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

  /// Clear rider payment
  Future<void> clearRiderPayment(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'riderPaymentStatus': 'Cleared',
        'status': 'Completed',
        'clearedAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Clear courier payment
  Future<void> clearCourierPayment(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'riderPaymentStatus': 'Cleared',
        'status': 'Completed',
        'clearedAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ── BUYER SIDE ORDER OPERATIONS--------

  /// Place Order — Option B: one Firestore document for all cart items.
  ///
  /// All cart items are stored in the 'items' array inside a single order
  /// document. This means one cancel call cancels the entire order
  /// (all products) at once.
  ///
  /// Returns a Map with 'docId' and 'orderId' of the created order
  /// so CheckoutScreen can pass them to OrderConfirmationScreen.
  Future<Map<String, String>> placeOrder({
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    try {
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final DocumentReference orderDocRef =
      _firestore.collection(_collection).doc();
      final String docId = orderDocRef.id;
      final String orderId =
          'ORD-${timestamp.toString().substring(7)}-${docId.substring(0, 4).toUpperCase()}';

      // Build items array — one entry per cart item
      final List<Map<String, dynamic>> items = cartItems.map((item) {
        final int qty = (item['quantity'] as int?) ?? 1;
        final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
        return {
          'productId':   item['productId'] ?? '',
          'productName': item['productName'] ?? '',
          'sellerId':    item['sellerId'] ?? '',
          'sellerName':  item['sellerName'] ?? '',
          'quantity':    qty,
          'price':       price,
          'amount':      (price * qty).toInt(),
        };
      }).toList();

      // Calculate totals from items
      final int totalAmount =
      items.fold(0, (sum, i) => sum + ((i['amount'] as int?) ?? 0));
      final int totalQuantity =
      items.fold(0, (sum, i) => sum + ((i['quantity'] as int?) ?? 0));

      // Use first item as summary fields for backward compat with
      // rider/seller screens that read productName, sellerId directly
      final firstItem = items.isNotEmpty ? items.first : <String, dynamic>{};

      final OrderModel newOrder = OrderModel(
        docId:              docId,
        orderId:            orderId,
        buyerId:            buyerId,
        buyerName:          buyerName,
        buyerPhone:         buyerPhone,
        buyerAddress:       buyerAddress,
        // summary fields — first item for backward compat
        productName:        firstItem['productName'] as String? ?? '',
        productId:          firstItem['productId'] as String? ?? '',
        sellerId:           firstItem['sellerId'] as String? ?? '',
        sellerName:         firstItem['sellerName'] as String? ?? '',
        quantity:           totalQuantity,
        amount:             totalAmount,
        // full items list
        items:              items,
        status:             'Pending',
        isPaid:             false,
        buyerPaymentStatus: 'Pending',
        riderPaymentStatus: 'Pending',
        deliveryType:       'Rider',
        createdAt:          timestamp,
      );

      // Single document write + cart clear in one batch
      final WriteBatch batch = _firestore.batch();
      batch.set(orderDocRef, newOrder.toJson(docId));

      // Delete all cart items
      for (final item in cartItems) {
        final cartItemRef = _firestore
            .collection('carts')
            .doc(buyerId)
            .collection('items')
            .doc(item['cartItemId'] as String? ?? '');
        batch.delete(cartItemRef);
      }

      await batch.commit();

      return {'docId': docId, 'orderId': orderId};
    } catch (e) {
      throw 'Failed to place order: ${e.toString()}';
    }
  }

  /// Get all orders for a buyer
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Cancel rider dispatch — reverts to Processing
  Future<void> cancelDispatch(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status':       'Processing',
        'riderId':      '',
        'riderName':    '',
        'deliveryType': '',
        'updatedAt':    DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get active orders count for a rider
  Future<int> getRiderActiveOrdersCount(String riderId) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('riderId', isEqualTo: riderId)
          .where('status', isEqualTo: 'Dispatched')
          .get();
      return snap.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Reorder — creates a fresh order from a previous one
  Future<void> reorderItem({required OrderModel originalOrder}) async {
    try {
      final ref = _firestore.collection(_collection).doc();
      final newOrderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newOrder = OrderModel(
        docId:       ref.id,
        orderId:     newOrderId,
        buyerId:     originalOrder.buyerId,
        buyerName:   originalOrder.buyerName,
        buyerPhone:  originalOrder.buyerPhone,
        buyerAddress:originalOrder.buyerAddress,
        productName: originalOrder.productName,
        productId:   originalOrder.productId,
        quantity:    originalOrder.quantity,
        amount:      originalOrder.amount,
        sellerId:    originalOrder.sellerId,
        sellerName:  originalOrder.sellerName,
        sellerPhone: originalOrder.sellerPhone,
        items:       originalOrder.items,  // carry items forward
        status:      'Pending',
        isPaid:      false,
        createdAt:   DateTime.now().millisecondsSinceEpoch,
      );

      await ref.set(newOrder.toJson(ref.id));
    } catch (e) {
      throw e.toString();
    }
  }
}