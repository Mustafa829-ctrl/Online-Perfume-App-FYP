import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/order_confirmation_widgets.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final double orderTotal;
  final String deliveryAddress;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.orderTotal,
    required this.deliveryAddress,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  static const int _cancelWindowSeconds = 01 * 60; // 15 minutes

  late int _remainingSeconds;
  Timer? _timer;
  bool _orderCancelled = false;
  bool _orderConfirmed = false; // becomes true when timer expires

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _cancelWindowSeconds;

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        setState(() {
          _remainingSeconds = 0;
          _orderConfirmed = true;
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Helpers
  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _timerProgress =>
      _remainingSeconds / _cancelWindowSeconds;

  // ── Actions
  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Cancel Order?",
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04)),
        ),
        content: Text(
          "Are you sure you want to cancel this order?",
          style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xff5E1D04).withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Keep Order",
                style: GoogleFonts.poppins(
                    color: const Color(0xff5E1D04),
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context); // close dialog
              setState(() => _orderCancelled = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Yes, Cancel",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BuyerHomescreen()),
      (route) => false,
    );
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    if (_orderCancelled) return _buildCancelledView();
    if (_orderConfirmed) return _buildConfirmedView();
    return _buildWaitingView();
  }

  // VIEW 1 – Waiting/Cancellable
  Widget _buildWaitingView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Order Placed",
          style: GoogleFonts.poppins(
              fontSize: 22,
              color: const Color(0xff5E1D04),
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // ── Success icon
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffD08C4A),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffD08C4A).withOpacity(0.4),
                      blurRadius: 18,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xff5E1D04), size: 52),
              ),
            ),
            const SizedBox(height: 18),

            Text(
              "Order Placed!",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04)),
            ),
            const SizedBox(height: 6),
            Text(
              "Order #${widget.orderId}",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04).withOpacity(0.55)),
            ),
            const SizedBox(height: 28),

            // ── Countdown card
            CountdownTimerCard(
              timerProgress: _timerProgress,
              formattedTime: _formattedTime,
            ),
            const SizedBox(height: 20),

            // ── Order summary card
            OrderSummaryCard(
              orderId: widget.orderId,
              deliveryAddress: widget.deliveryAddress,
              orderTotal: widget.orderTotal,
            ),
            const SizedBox(height: 28),

            // ── Cancel button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _cancelOrder,
                icon: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 20),
                label: Text(
                  "Cancel Order",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade400, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Go Home button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_rounded,
                    color: Color(0xff5E1D04)),
                label: Text(
                  "Continue Shopping",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // VIEW 2 – Confirmed (timer expired)
  Widget _buildConfirmedView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Order Confirmed",
          style: GoogleFonts.poppins(
              fontSize: 22,
              color: const Color(0xff5E1D04),
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffD08C4A),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffD08C4A).withOpacity(0.45),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: const Icon(Icons.verified_rounded,
                  color: Color(0xff5E1D04), size: 58),
            ),
            const SizedBox(height: 20),
            Text(
              "Order Confirmed!",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04)),
            ),
            const SizedBox(height: 8),
            Text(
              "Your order #${widget.orderId} has been confirmed\nand is being prepared for delivery.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xff5E1D04).withOpacity(0.65)),
            ),
            const SizedBox(height: 20),

            // Lock notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xff5E1D04).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xff5E1D04).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      color: const Color(0xff5E1D04).withOpacity(0.6),
                      size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "The 15-minute cancellation window has passed.\nThis order can no longer be cancelled.",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xff5E1D04).withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            OrderSummaryCard(
              orderId: widget.orderId,
              deliveryAddress: widget.deliveryAddress,
              orderTotal: widget.orderTotal,
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_rounded,
                    color: Color(0xff5E1D04)),
                label: Text(
                  "Back to Home",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // VIEW 3 – Cancelled
  Widget _buildCancelledView() {
    return Scaffold(
      backgroundColor: const Color(0xffF1C8C6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Order Cancelled",
          style: GoogleFonts.poppins(
              fontSize: 22,
              color: const Color(0xff5E1D04),
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Icon(Icons.cancel_rounded,
                  color: Colors.red.shade400, size: 58),
            ),
            const SizedBox(height: 20),
            Text(
              "Order Cancelled",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04)),
            ),
            const SizedBox(height: 8),
            Text(
              "Your order #${widget.orderId} has been\nsuccessfully cancelled.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xff5E1D04).withOpacity(0.65)),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xffD08C4A), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "No charges were made. Feel free to browse and place a new order anytime!",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xff5E1D04).withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.storefront_outlined,
                    color: Color(0xff5E1D04)),
                label: Text(
                  "Continue Shopping",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
