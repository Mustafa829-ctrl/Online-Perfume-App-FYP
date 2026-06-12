import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'delivery_widgets.dart';

class RiderDeliveryView extends StatelessWidget {
  final Map<String, dynamic> rider; // Changed to dynamic to support backend object parsing safely
  final String deliveryAddress;

  const RiderDeliveryView({
    super.key,
    required this.rider,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final String currentStatus = rider['status']?.toString() ?? 'Pending';
    final String riderName = rider['name']?.toString() ?? 'Awaiting Assignment';
    final String initialAvatarLetter = riderName.isNotEmpty ? riderName[0].toUpperCase() : 'R';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rider illustration banner
          const MapIllustration(isRider: true),
          const SizedBox(height: 16),

          // ── ETA & Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estimated Arrival",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xff5E1D04).withOpacity(0.6))),
                  Text(rider['eta']?.toString() ?? 'Within 24 Hours',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffD08C4A), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffD08C4A))),
                    const SizedBox(width: 6),
                    Text(
                      currentStatus,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Order timeline linked with real stream backend status tracking
          OrderTimeline(
            isCourier: false,
            currentStatus: currentStatus,
          ),
          const SizedBox(height: 20),

          // ── Rider details card
          const SectionTitle(
              title: "Your Rider", icon: Icons.delivery_dining_rounded),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                // Avatar row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xffD08C4A),
                      child: Text(
                        initialAvatarLetter,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5E1D04)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(riderName,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff5E1D04))),
                          Text("Delivery Rider",
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xff5E1D04).withOpacity(0.55))),
                        ],
                      ),
                    ),
                    // Call button
                    GestureDetector(
                      onTap: () {
                        if (rider['phone'] != null && rider['phone'] != '—') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBarHelper.styledSnack("Contacting $riderName at ${rider['phone']}..."),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBarHelper.styledSnack("Rider contact number unavailable."),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xffD08C4A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_rounded,
                            color: Color(0xff5E1D04), size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xffD08C4A), thickness: 0.6),
                const SizedBox(height: 12),

                // Real registration metrics (Stripped out color, CNIC, and license profiles)
                InfoRowWidget(
                    icon: Icons.phone_android_outlined,
                    label: "Phone",
                    value: rider['phone']?.toString() ?? '—'),
                InfoRowWidget(
                    icon: Icons.two_wheeler_rounded,
                    label: "Vehicle Model",
                    value: rider['bike']?.toString() ?? 'Delivery Vehicle'),
                InfoRowWidget(
                    icon: Icons.pin_outlined,
                    label: "Registration Number",
                    value: rider['bikeNumber']?.toString() ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Delivery address
          const SectionTitle(
              title: "Delivery Address", icon: Icons.location_on_outlined),
          const SizedBox(height: 10),
          DeliveryAddressCard(deliveryAddress: deliveryAddress),
          const SizedBox(height: 20),

          // ── Live tracking placeholder banner
          const LiveTrackBanner(),
          const SizedBox(height: 24),

          // ── Back home button
          const BackToHomeButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}