import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/widgets/bottom_navigation_bar.dart';

// Import our new extracted view components
import 'package:online_perfume_app_fyp/widgets/rider_delivery_view.dart';
import 'package:online_perfume_app_fyp/widgets/courier_delivery_view.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final String orderId;
  final String city;
  final double orderTotal;
  final String deliveryAddress;

  const DeliveryTrackingScreen({
    super.key,
    required this.orderId,
    required this.city,
    required this.orderTotal,
    required this.deliveryAddress,
  });

  // ── City detection
  bool get _isInCity {
    final c = city.toLowerCase().trim();
    return c.contains('islamabad') || c.contains('rawalpindi');
  }

  // ── Dummy rider data (will be replaced from API)
  static const _rider = {
    'name': 'Ahmed Raza',
    'phone': '+92-300-8821476',
    'cnic': '61101-2345678-3',
    'license': 'ICT-RB-2024-00412',
    'bike': 'Honda CG 125',
    'color': 'Red',
    'eta': '24 Hours',
  };

  // ── Dummy courier data (will be replaced from API)
  static const _courier = {
    'company': 'TCS Express',
    'trackingId': 'TCS-PK-847291-24',
    'eta': '3–5 Business Days',
    'hotline': '111-123-456',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1C8C6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xff5E1D04)),
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
      body: _isInCity
          ? RiderDeliveryView(
              rider: _rider,
              deliveryAddress: deliveryAddress,
            )
          : CourierDeliveryView(
              courier: _courier,
              deliveryAddress: deliveryAddress,
            ),
    );
  }
}
