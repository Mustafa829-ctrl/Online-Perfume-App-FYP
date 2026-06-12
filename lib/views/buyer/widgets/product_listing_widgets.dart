import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';
import '../screens/product_details.dart';

// ── Filter Button Widget
class FilterButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterButtonWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffF6B55E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: const Color(0xff5E1D04),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xff5E1D04)),
          ],
        ),
      ),
    );
  }
}

// ── Tall Product Card
class TallProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const TallProductCard({
    super.key,
    required this.product,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice =
    product.sizes != null && product.sizes!.isNotEmpty
        ? 'Rs ${product.sizes!.first['price']}'
        : 'Rs ${product.price?.toStringAsFixed(0) ?? '0'}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetails(
            product: product,
            isLoggedIn: isLoggedIn,
            onLoginRequired: onLoginRequired,
          ),
        ),
      ),
      child: Container(
        height: 480,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: (product.imageUrl ?? '').isNotEmpty
                        ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildImageFallback(),
                    )
                        : _buildImageFallback(),
                  ),
                ),

                // Info section
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? '',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xff5E1D04),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((product.brand ?? '').isNotEmpty)
                        Text(product.brand ?? '',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedPrice,
                            style: GoogleFonts.playfairDisplay(
                              color: const Color(0xff5E1D04),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              (product.rating ?? 0.0)
                                  .toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Wishlist button
            Positioned(
              top: 10,
              right: 10,
              child: WishlistBtn(
                product: product,
                isLoggedIn: isLoggedIn,
                onLoginRequired: onLoginRequired,
              ),
            ),

            // Discount badge
            if ((product.discount ?? 0) > 0)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${product.discount!.toStringAsFixed(0)}% OFF',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFFFFF3CD),
      child: const Center(
        child: Icon(Icons.local_florist_outlined,
            color: Color(0xffD08C4A), size: 50),
      ),
    );
  }
}

// ── Small Product Card
class SmallProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const SmallProductCard({
    super.key,
    required this.product,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice =
    product.sizes != null && product.sizes!.isNotEmpty
        ? 'Rs ${product.sizes!.first['price']}'
        : 'Rs ${product.price?.toStringAsFixed(0) ?? '0'}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetails(
            product: product,
            isLoggedIn: isLoggedIn,
            onLoginRequired: onLoginRequired,
          ),
        ),
      ),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: (product.imageUrl ?? '').isNotEmpty
                        ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildImageFallback(),
                    )
                        : _buildImageFallback(),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? '',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xff5E1D04),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedPrice,
                            style: GoogleFonts.playfairDisplay(
                              color: const Color(0xff5E1D04),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xff5E1D04)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Wishlist button
            Positioned(
              top: 6,
              right: 6,
              child: WishlistBtn(
                product: product,
                isLoggedIn: isLoggedIn,
                onLoginRequired: onLoginRequired,
                size: 18,
              ),
            ),

            // Discount badge
            if ((product.discount ?? 0) > 0)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.discount!.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFFFFF3CD),
      child: const Center(
        child: Icon(Icons.local_florist_outlined,
            color: Color(0xffD08C4A), size: 30),
      ),
    );
  }
}

// ── Wishlist Button (reused in both cards)
class WishlistBtn extends StatelessWidget {
  final ProductModel product;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;
  final double size;

  const WishlistBtn({
    required this.product,
    required this.isLoggedIn,
    required this.onLoginRequired,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return GestureDetector(
        onTap: onLoginRequired,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.favorite_border,
              color: const Color(0xff5E1D04), size: size),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final wishlistItemId = '${uid}_${product.docId ?? ''}';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wishlists')
          .doc(uid)
          .collection('items')
          .doc(wishlistItemId)
          .snapshots(),
      builder: (context, snapshot) {
        final bool isLiked = snapshot.data?.exists ?? false;

        return GestureDetector(
          onTap: () async {
            try {
              final double price =
              product.sizes != null &&
                  product.sizes!.isNotEmpty
                  ? double.tryParse(product
                  .sizes!.first['price']
                  .toString()) ??
                  0.0
                  : product.price ?? 0.0;

              await WishlistService().toggleWishlist(
                buyerId:   uid,
                productId: product.docId ?? '',
                name:      product.name ?? '',
                price:     price,
                imagePath: product.imageUrl ?? '',
                sellerId:  product.sellerId ?? '',
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString(),
                        style: GoogleFonts.poppins(
                            fontSize: 13)),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                  ),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked
                  ? const Color(0xffF6B55E)
                  : const Color(0xff5E1D04),
              size: size,
            ),
          ),
        );
      },
    );
  }
}