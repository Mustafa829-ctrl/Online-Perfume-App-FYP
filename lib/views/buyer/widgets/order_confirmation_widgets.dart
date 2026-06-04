import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSummaryCard extends StatelessWidget {
  final String orderId;
  final String deliveryAddress;
  final double orderTotal;

  const OrderSummaryCard({
    super.key,
    required this.orderId,
    required this.deliveryAddress,
    required this.orderTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04)),
          ),
          const SizedBox(height: 12),
          _summaryRow(Icons.tag_rounded, "Order ID", "#$orderId"),
          _summaryRow(Icons.payments_outlined, "Payment", "Cash on Delivery"),
          _summaryRow(Icons.location_on_outlined, "Delivery",
              deliveryAddress.isEmpty ? "—" : deliveryAddress),
          const Divider(color: Color(0xffD08C4A), height: 22, thickness: 0.7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04)),
              ),
              Text(
                "\$${orderTotal.toStringAsFixed(2)}",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff5E1D04)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffD08C4A), size: 18),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5E1D04)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04).withOpacity(0.65)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CountdownTimerCard extends StatelessWidget {
  final double timerProgress;
  final String formattedTime;

  const CountdownTimerCard({
    super.key,
    required this.timerProgress,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Cancellation Window",
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5E1D04).withOpacity(0.7)),
          ),
          const SizedBox(height: 14),

          // Circular progress timer
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: timerProgress,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xffD08C4A).withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerProgress > 0.3
                          ? const Color(0xffD08C4A)
                          : Colors.red.shade400,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: timerProgress > 0.3
                              ? const Color(0xff5E1D04)
                              : Colors.red.shade600),
                    ),
                    Text(
                      "remaining",
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xff5E1D04).withOpacity(0.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "You can cancel your order within 15 minutes.\nAfter that, your order will be confirmed.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xff5E1D04).withOpacity(0.65)),
          ),
        ],
      ),
    );
  }
}
