import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'cart_service.dart';

class OrderPlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _ordersCollection = 'orders';

  // PLACE NEW ORDER (Buyer Side)-------

  /// Place New Order
  Future<String?> placeOrder({
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    required List<Map<String, dynamic>> items,   // Cart items
    required double totalAmount,
    required String paymentMethod, // 'Cash on Delivery', 'Online', etc.
  }) async {
    try {
      // Generate unique Order ID
      String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      OrderModel order = OrderModel(
        orderId: orderId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        buyerAddress: buyerAddress,
        sellerId: items.first['sellerId'],           // Assuming single seller for now
        sellerName: items.first['sellerName'] ?? '',
        amount: totalAmount.toInt(),
        status: 'Pending',
        isPaid: paymentMethod == 'Online',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Save Order
      await _firestore.collection(_ordersCollection)
          .doc(orderId)
          .set(order.toJson(orderId));

      // Save Order Items (Sub-collection)
      for (var item in items) {
        await _firestore
            .collection(_ordersCollection)
            .doc(orderId)
            .collection('items')
            .doc(item['productId'])
            .set({
          'productId': item['productId'],
          'productName': item['productName'],
          'price': item['price'],
          'quantity': item['quantity'],
          'imageUrl': item['imageUrl'] ?? '',
          'sellerId': item['sellerId'],
        });
      }

      //  Clear Cart after successful order
      await CartService().clearCart(buyerId);

      return orderId;
    } catch (e) {
      throw e.toString();
    }
  }

  // BUYER SIDE ORDER MANAGEMENT--------

  /// Get All Orders of Buyer
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .where('buyerId', isEqualTo: buyerId)   // Note: aapke OrderModel mein buyerId nahi hai, agar chahiye to add kar sakte hain
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Order Details with Items
  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    try {
      DocumentSnapshot orderDoc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) throw 'Order not found';

      QuerySnapshot itemsSnap = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .collection('items')
          .get();

      return {
        'order': OrderModel.fromJson(orderDoc.data() as Map<String, dynamic>),
        'items': itemsSnap.docs.map((doc) => doc.data()).toList(),
      };
    } catch (e) {
      throw e.toString();
    }
  }

  /// Cancel Order (Buyer - within 15 minutes)
  Future<void> cancelBuyerOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': 'Cancelled',
        'notDeliveredReason': reason,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Return Order Request
  Future<void> requestReturn({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': 'Return Requested',
        'notDeliveredReason': reason,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }
}