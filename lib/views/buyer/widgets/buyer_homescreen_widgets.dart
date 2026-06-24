import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';
import '../../../models/product_model.dart';
import '../screens/product_details.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const HomeSearchBar({
    super.key,
    this.onFilterTap,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffF6B55E),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xff5E1D04)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: GoogleFonts.poppins(color: const Color(0xff5E1D04), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search product",
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xff5E1D04).withOpacity(0.7),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff5E1D04),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── ProductHomeCard — Improved
class ProductHomeCard extends StatelessWidget {
  final ProductModel product;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const ProductHomeCard({
    super.key,
    required this.product,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = product.sizes != null && product.sizes!.isNotEmpty
        ? 'Rs ${product.sizes!.first['price']}'
        : 'Rs ${product.price ?? 0.0}';

    final double numericPrice = product.sizes != null && product.sizes!.isNotEmpty
        ? double.tryParse(product.sizes!.first['price'].toString()) ?? 0.0
        : (product.price ?? 0.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetails(
              product: product,
              isLoggedIn: isLoggedIn,
              onLoginRequired: onLoginRequired,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_florist_outlined,
                          color: Color(0xffD08C4A),
                          size: 40,
                        ),
                      ),
                    )
                        : const Icon(Icons.local_florist_outlined, color: Color(0xffD08C4A), size: 40),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name ?? 'Fragrance',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.brand ?? 'Generic Brand',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xff5E1D04).withOpacity(0.8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedPrice,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xff5E1D04), fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          (product.rating ?? 0.0).toStringAsFixed(1),
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Wishlist Button
            Positioned(
              top: 0,
              right: 0,
              child: _WishlistButton(
                product: product,
                numericPrice: numericPrice,
                isLoggedIn: isLoggedIn,
                onLoginRequired: onLoginRequired,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final ProductModel product;
  final double numericPrice;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const _WishlistButton({
    required this.product,
    required this.numericPrice,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.favorite_border, color: Color(0xff5E1D04), size: 22),
        onPressed: onLoginRequired,
      );
    }

    final String buyerId = FirebaseAuth.instance.currentUser!.uid;
    final String wishlistItemId = '${buyerId}_${product.docId ?? ''}';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wishlists')
          .doc(buyerId)
          .collection('items')
          .doc(wishlistItemId)
          .snapshots(),
      builder: (context, snapshot) {
        final bool isLiked = snapshot.data?.exists ?? false;

        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? const Color(0xffF6B55E) : const Color(0xff5E1D04),
            size: 22,
          ),
          onPressed: () async {
            try {
              await WishlistService().toggleWishlist(
                buyerId: buyerId,
                productId: product.docId ?? '',
                name: product.name ?? '',
                price: numericPrice,
                imagePath: product.imageUrl ?? '',
                sellerId: product.sellerId ?? '',
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}