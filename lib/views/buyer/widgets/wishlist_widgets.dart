import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';

// ── Wishlist Header Widget
class WishlistHeader extends StatelessWidget {
  const WishlistHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Wishlist',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            Text(
              'Your saved fragrances',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.favorite,
            color: Color(0xff5E1D04),
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ── Wishlist Item Card Widget
class WishlistItemCard extends StatefulWidget {
  final WishlistItemModel item;
  final bool isLarge;
  final VoidCallback onRemove;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.isLarge = false,
  });

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard> {
  bool _isRemoving = false;

  Future<void> _handleRemove() async {
    setState(() => _isRemoving = true);
    widget.onRemove();
    if (mounted) setState(() => _isRemoving = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool isLarge = widget.isLarge;

    return Container(
      width: double.infinity,
      height: isLarge ? 280 : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: isLarge ? 180 : 130,
                  color: const Color(0xFFFFF3CD),
                  child: item.imagePath != null && item.imagePath!.isNotEmpty
                      ? Image.network(
                    item.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffD08C4A),
                          strokeWidth: 2,
                        ),
                      );
                    },
                  )
                      : _buildPlaceholder(),
                ),
              ),

              // ── Remove button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _isRemoving ? null : _handleRemove,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isRemoving
                        ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xff5E1D04),
                      ),
                    )
                        : const Icon(
                      Icons.favorite,
                      color: Color(0xff5E1D04),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Product Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'Unknown Product',
                  style: GoogleFonts.poppins(
                    fontSize: isLarge ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs ${item.price?.toStringAsFixed(0) ?? '0'}',
                      style: GoogleFonts.poppins(
                        fontSize: isLarge ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffD08C4A),
                      ),
                    ),
                    // ── Add to cart button
                    GestureDetector(
                      onTap: () {
                        // TODO: Add to cart
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.name} added to cart',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xff5E1D04),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xff5E1D04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xffD08C4A),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.spa_outlined,
            color: Color(0xffD08C4A),
            size: 40,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}