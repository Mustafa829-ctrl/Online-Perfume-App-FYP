import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'delivery_widgets.dart';
class CourierDeliveryView extends StatelessWidget {
  final Map<String, String> courier;
  final String deliveryAddress;

  const CourierDeliveryView({
    super.key,
    required this.courier,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Courier illustration banner
          const MapIllustration(isRider: false),
          const SizedBox(height: 16),

          // ── ETA row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estimated Delivery",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xff5E1D04).withOpacity(0.6))),
                  Text(courier['eta']!,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04))),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xffD08C4A), width: 1.2),
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
                    Text("Dispatched",
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Order timeline
          OrderTimeline(
            isCourier: true,
            companyName: courier['company']!,
          ),
          const SizedBox(height: 20),

          // ── Tracking ID card
          const SectionTitle(
              title: "Tracking Information",
              icon: Icons.local_shipping_outlined),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Courier name
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xffD08C4A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_shipping_outlined,
                          color: Color(0xff5E1D04), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(courier['company']!,
                            style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff5E1D04))),
                        Text("Courier Service",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xff5E1D04)
                                    .withOpacity(0.55))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xffD08C4A), thickness: 0.6),
                const SizedBox(height: 14),

                // Tracking ID with copy button
                Text("Tracking ID",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04).withOpacity(0.6))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffD08C4A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xffD08C4A).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          courier['trackingId']!,
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: const Color(0xff5E1D04)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: courier['trackingId']!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBarHelper.styledSnack("Tracking ID copied!"),
                          );
                        },
                        child: const Icon(Icons.copy_rounded,
                            color: Color(0xffD08C4A), size: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                InfoRowWidget(
                    icon: Icons.access_time_rounded,
                    label: "ETA",
                    value: courier['eta']!),
                InfoRowWidget(
                    icon: Icons.support_agent_rounded,
                    label: "Hotline",
                    value: courier['hotline']!),
                const SizedBox(height: 10),

                // Track on courier website note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffD08C4A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xffD08C4A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Use your tracking ID on the ${courier['company']} website or app to track your shipment.",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  const Color(0xff5E1D04).withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Delivery address
          const SectionTitle(
              title: "Delivery Address", icon: Icons.location_on_outlined),
          const SizedBox(height: 10),
          DeliveryAddressCard(deliveryAddress: deliveryAddress),
          const SizedBox(height: 24),

          // ── Back home button
          const BackToHomeButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
