import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';

import '../screens/checkout_screen.dart';

/// Empty Cart View
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

/// Cart Item Widget
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.imageUrl.isNotEmpty && item.imageUrl.startsWith('http')
                  ? Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Color(0xff5E1D04), size: 35),
                ),
              )
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Color(0xff5E1D04), size: 35),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Product Details
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

          // Quantity Controls
          CartQuantityControls(
            buyerId: item.buyerId ?? '',
            cartItemId: item.cartItemId ?? '',
            quantity: item.quantity,
            cartService: cartService,
          ),
        ],
      ),
    );
  }
}

/// Quantity Controls
class CartQuantityControls extends StatelessWidget {
  final String buyerId;
  final String cartItemId;
  final int quantity;
  final CartService cartService;

  const CartQuantityControls({
    super.key,
    required this.buyerId,
    required this.cartItemId,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cartService.updateCartQuantity(
              buyerId: buyerId,
              cartItemId: cartItemId,
              newQuantity: quantity + 1,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.add, color: Color(0xff5E1D04), size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          GestureDetector(
            onTap: () => cartService.updateCartQuantity(
              buyerId: buyerId,
              cartItemId: cartItemId,
              newQuantity: quantity - 1,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.remove, color: Color(0xff5E1D04), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cart Order Summary
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal",
                style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xff5E1D04)),
              ),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xffD08C4A), thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Checkout
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD08C4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                "Proceed to Checkout",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}