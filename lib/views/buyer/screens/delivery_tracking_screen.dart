import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/models/rider_model.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/courier_delivery_view.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/rider_delivery_view.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final String orderDocId;

  const DeliveryTrackingScreen({
    super.key,
    required this.orderDocId,
  });

  /// Asynchronously fetches the authentic rider registration details using their unique ID
  Future<RiderModel?> _fetchRiderProfile(String? riderId) async {
    if (riderId == null || riderId.isEmpty) return null;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('riders')
          .doc(riderId)
          .get();

      if (doc.exists && doc.data() != null) {
        return RiderModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(orderDocId).snapshots(),
      builder: (context, orderSnapshot) {
        if (orderSnapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${orderSnapshot.error}")));
        }
        if (orderSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xffD08C4A))));
        }
        if (!orderSnapshot.hasData || !orderSnapshot.data!.exists) {
          return Scaffold(body: Center(child: Text("Tracking record not found.", style: GoogleFonts.poppins())));
        }

        final order = OrderModel.fromJson(orderSnapshot.data!.data() as Map<String, dynamic>);
        final bool isCourier = order.deliveryType == 'Courier';

        // ── COURIER VIEW ROUTING
        if (isCourier) {
          return _buildScaffold(
            context: context, // Passed build context down here
            orderId: order.orderId ?? '—',
            body: CourierDeliveryView(
              courier: {
                'company': order.courierName ?? 'Processing Partner',
                'trackingId': order.trackingNumber ?? 'Awaiting dispatch...',
                'eta': '3–5 Business Days',
                'hotline': 'Contact Support',
                'status': order.status ?? 'Pending',
              },
              deliveryAddress: order.buyerAddress ?? 'No address provided',
            ),
          );
        }

        // ── RIDER VIEW ROUTING
        return FutureBuilder<RiderModel?>(
          future: _fetchRiderProfile(order.riderId),
          builder: (futureContext, riderSnapshot) {
            final riderProfile = riderSnapshot.data;

            return _buildScaffold(
              context: context, // Passed build context down here
              orderId: order.orderId ?? '—',
              body: RiderDeliveryView(
                rider: {
                  'name': riderProfile?.name ?? order.riderName ?? 'Awaiting Assignment',
                  'phone': riderProfile?.phone ?? '—',
                  'bike': riderProfile?.vehicleModel ?? 'Delivery Vehicle',
                  'bikeNumber': riderProfile?.vehicleNumber ?? '—',
                  'eta': order.status == 'Pending' ? 'Awaiting Dispatch' : '24 Hours',
                  'status': order.status ?? 'Pending',
                },
                deliveryAddress: order.buyerAddress ?? 'No address provided',
              ),
            );
          },
        );
      },
    );
  }

  /// Structural Scaffold generator helper with contextual pipeline parameters injected
  Widget _buildScaffold({
    required BuildContext context,
    required String orderId,
    required Widget body,
  }) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff5E1D04)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order #$orderId",
          style: GoogleFonts.poppins(
              fontSize: 20,
              color: const Color(0xff5E1D04),
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: body,
    );
  }
}