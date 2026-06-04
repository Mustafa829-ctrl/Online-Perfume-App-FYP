import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/checkout_screen.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 90,
            color: Color(0xff5E1D04),
          ),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some perfumes to get started!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xff5E1D04),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final int index;
  final CartService cartService;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),

          // Name, volume, price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.selectedVolume,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$${item.totalPrice.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff5E1D04),
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          CartQuantityControls(
            index: index,
            quantity: item.quantity,
            cartService: cartService,
          ),
        ],
      ),
    );
  }
}

class CartQuantityControls extends StatelessWidget {
  final int index;
  final int quantity;
  final CartService cartService;

  const CartQuantityControls({
    super.key,
    required this.index,
    required this.quantity,
    required this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffD08C4A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Plus button
          GestureDetector(
            onTap: () => cartService.incrementQuantity(index),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Color(0xff5E1D04), size: 20),
            ),
          ),
          // Quantity number
          Container(
            width: 36,
            height: 30,
            alignment: Alignment.center,
            color: const Color(0xff5E1D04),
            child: Text(
              "$quantity",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xffF6B55E),
              ),
            ),
          ),
          // Minus button
          GestureDetector(
            onTap: () => cartService.decrementQuantity(index),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, color: Color(0xff5E1D04), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class CartOrderSummary extends StatelessWidget {
  final double subtotal;
  final double total;

  const CartOrderSummary({
    super.key,
    required this.subtotal,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xff5E1D04),
                ),
              ),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xff5E1D04),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: Color(0xffD08C4A), thickness: 0.8),
          const SizedBox(height: 6),
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xff5E1D04),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Proceed to Checkout Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD08C4A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
                shadowColor: Colors.black,
              ),
              child: Text(
                "Proceed to Checkout",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
