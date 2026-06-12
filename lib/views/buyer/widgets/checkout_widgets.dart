import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';

class CheckoutStepper extends StatelessWidget {
  final int currentStep;
  const CheckoutStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ["Address", "Payment", "Review"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: const Color(0xffD08C4A),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentStep;
          final isActive = stepIndex == currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffD08C4A),
                  boxShadow: isActive
                      ? [
                    const BoxShadow(
                      color: Color(0xffD08C4A),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                      : [],
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                      color: Color(0xff5E1D04), size: 22)
                      : Text(
                    "${stepIndex + 1}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? const Color(0xff5E1D04)
                          : const Color(0xff5E1D04).withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[stepIndex],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xff5E1D04)
                      : const Color(0xff5E1D04).withOpacity(0.5),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class AddressStep extends StatelessWidget {
  final bool hasAddress;
  final String savedLabel;
  final String savedName;
  final String savedAddress;
  final String savedPhone;
  final VoidCallback onAddNewAddress;

  const AddressStep({
    super.key,
    required this.hasAddress,
    required this.savedLabel,
    required this.savedName,
    required this.savedAddress,
    required this.savedPhone,
    required this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Shopping Address",
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            GestureDetector(
              onTap: onAddNewAddress,
              child: Row(
                children: [
                  const Icon(Icons.add, color: Color(0xff5E1D04), size: 18),
                  Text(
                    "Add New Address",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xff5E1D04),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!hasAddress)
          _buildNoAddressCard()
        else
          _buildAddressCard(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildNoAddressCard() {
    return GestureDetector(
      onTap: onAddNewAddress,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xffD08C4A).withOpacity(0.5),
              style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_location_alt_outlined,
                color: Color(0xffD08C4A), size: 40),
            const SizedBox(height: 10),
            Text(
              "No address saved yet.\nTap to add your delivery address.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xff5E1D04).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD08C4A), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  savedLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  savedName,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04)),
                ),
                Text(
                  savedAddress,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xff5E1D04).withOpacity(0.7)),
                ),
                Text(
                  savedPhone,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xff5E1D04).withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffD08C4A),
            ),
            child: const Icon(Icons.check, color: Color(0xff5E1D04), size: 18),
          ),
        ],
      ),
    );
  }
}

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffD08C4A), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_outlined,
                    color: Color(0xff5E1D04), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cash on Delivery",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                    Text(
                      "Pay when your order arrives",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04).withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff5E1D04),
                ),
                child: const Icon(Icons.check,
                    color: Color(0xffF6B55E), size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xffD08C4A).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xffD08C4A), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Only Cash on Delivery is available.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xff5E1D04).withOpacity(0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class ReviewStep extends StatelessWidget {
  final String savedAddress;
  final List<CartItemModel> cartItems; // Injected directly from CheckoutScreen state
  final double totalAmount;             // Injected directly from CheckoutScreen state

  const ReviewStep({
    super.key,
    required this.savedAddress,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Review",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        const SizedBox(height: 14),

        // Items list mapping cloud payloads
        ...cartItems.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                  item.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.local_florist_outlined, color: Color(0xffD08C4A)),
                  ),
                )
                    : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.local_florist_outlined, color: Color(0xffD08C4A)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04)),
                    ),
                    Text(
                      "Qty: ${item.quantity}",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xff5E1D04).withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              Text(
                "Rs ${item.totalPrice.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04)),
              ),
            ],
          ),
        )),

        const SizedBox(height: 16),

        // Delivery address summary
        _buildReviewRow(Icons.location_on_outlined, "Deliver to", savedAddress),
        _buildReviewRow(Icons.payments_outlined, "Payment", "Cash on Delivery"),

        const Divider(color: Color(0xffD08C4A), thickness: 0.8, height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            Text(
              "Rs ${totalAmount.toStringAsFixed(0)}",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xff5E1D04)),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffD08C4A), size: 20),
          const SizedBox(width: 10),
          Text("$label: ",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E1D04))),
          Expanded(
            child: Text(
              value.isEmpty ? "—" : value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04).withOpacity(0.7)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutBottomBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onPrimaryAction;

  const CheckoutBottomBar({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    switch (currentStep) {
      case 0:
        label = "Continue to Payment";
        break;
      case 1:
        label = "Review Order";
        break;
      default:
        label = "Place Order";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xff5E1D04), size: 20),
              ),
            ),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}