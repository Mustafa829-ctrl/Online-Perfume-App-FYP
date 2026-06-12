import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/buyer_homescreen.dart';

class MapIllustration extends StatelessWidget {
  final bool isRider;
  const MapIllustration({super.key, required this.isRider});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffA8D8A8), Color(0xff8EC6E6)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                color: const Color(0xff8B8B8B).withOpacity(0.4),
              ),
            ),
            Positioned(
              bottom: 26,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    8,
                        (_) => Container(
                        width: 28,
                        height: 4,
                        color: Colors.white.withOpacity(0.8))),
              ),
            ),
            const Positioned(
              top: 24,
              left: 40,
              child: Icon(Icons.location_on, color: Colors.red, size: 32),
            ),
            const Positioned(
              top: 18,
              right: 50,
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
            Positioned(
              bottom: 22,
              left: isRider ? 100 : 80,
              child: Icon(
                isRider
                    ? Icons.delivery_dining_rounded
                    : Icons.local_shipping_rounded,
                color: const Color(0xff5E1D04),
                size: 52,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRider ? " Rider Delivery" : " Courier Delivery",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineStepData {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool done;
  const TimelineStepData(this.icon, this.label, this.subtitle, this.done);
}

class OrderTimeline extends StatelessWidget {
  final bool isCourier;
  final String companyName;
  final String currentStatus; // Live status tracked from backend

  const OrderTimeline({
    super.key,
    required this.isCourier,
    required this.currentStatus,
    this.companyName = '',
  });

  @override
  Widget build(BuildContext context) {
    final status = currentStatus.toLowerCase().trim();

    // Determine visual active tracking points dynamically
    final bool isPlaced = true;
    final bool isPacked = status == 'packed' || status == 'in transit' || status == 'delivered';
    final bool isDispatched = status == 'in transit' || status == 'delivered';
    final bool isDelivered = status == 'delivered';

    final steps = isCourier
        ? [
      TimelineStepData(Icons.check_circle_rounded, "Order Placed", "Confirmed & being packed", isPlaced),
      TimelineStepData(Icons.inventory_2_outlined, "Quality Check", "Package inspected & sealed", isPacked),
      TimelineStepData(Icons.local_shipping_outlined, "Dispatched", "$companyName collected parcel", isDispatched),
      TimelineStepData(Icons.route_outlined, "En Route", "Package traveling to destination", isDispatched && !isDelivered),
      TimelineStepData(Icons.home_outlined, "Delivered", isDelivered ? "Successfully received!" : "Awaiting delivery", isDelivered),
    ]
        : [
      TimelineStepData(Icons.check_circle_rounded, "Order Placed", "Confirmed successfully", isPlaced),
      TimelineStepData(Icons.inventory_2_outlined, "Packed", "Quality check complete", isPacked),
      TimelineStepData(Icons.delivery_dining_rounded, "Rider Dispatched", status == 'in transit' ? "Rider is heading to you" : "Awaiting dispatch", isDispatched),
      TimelineStepData(Icons.home_outlined, "Delivered", isDelivered ? "Handed over to buyer" : "Awaiting delivery", isDelivered),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.done
                          ? const Color(0xffD08C4A)
                          : const Color(0xffD08C4A).withOpacity(0.2),
                    ),
                    child: Icon(step.icon,
                        color: step.done
                            ? const Color(0xff5E1D04)
                            : const Color(0xff5E1D04).withOpacity(0.35),
                        size: 18),
                  ),
                  if (!isLast)
                    Container(
                        width: 2,
                        height: 30,
                        color: step.done
                            ? const Color(0xffD08C4A)
                            : const Color(0xffD08C4A).withOpacity(0.2)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.label,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: step.done
                                  ? const Color(0xff5E1D04)
                                  : const Color(0xff5E1D04).withOpacity(0.4))),
                      Text(step.subtitle,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xff5E1D04).withOpacity(0.55))),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class LiveTrackBanner extends StatelessWidget {
  const LiveTrackBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff5E1D04).withOpacity(0.85),
            const Color(0xffD08C4A).withOpacity(0.85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Live Rider Location",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text("Google Maps tracking available after API integration.",
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white38),
            ),
            child: Text("Soon",
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class DeliveryAddressCard extends StatelessWidget {
  final String deliveryAddress;
  const DeliveryAddressCard({super.key, required this.deliveryAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffD08C4A).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xffD08C4A), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              deliveryAddress.isEmpty ? "—" : deliveryAddress,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04).withOpacity(0.75)),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xffD08C4A), size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
      ],
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRowWidget({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffD08C4A), size: 18),
          const SizedBox(width: 8),
          Text("$label: ",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E1D04))),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xff5E1D04).withOpacity(0.65)),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class BackToHomeButton extends StatelessWidget {
  const BackToHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BuyerHomescreen()),
              (r) => false,
        ),
        icon: const Icon(Icons.home_rounded, color: Color(0xff5E1D04)),
        label: Text("Back to Home",
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffD08C4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
      ),
    );
  }
}

class SnackBarHelper {
  static SnackBar styledSnack(String msg) {
    return SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(color: const Color(0xff5E1D04))),
      backgroundColor: const Color(0xffF6B55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}