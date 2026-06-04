import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';

class WishlistHeader extends StatelessWidget {
  const WishlistHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Selection",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xff5E1D04),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Wishlist",
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SavedItemsTag(),
          ],
        ),
      ],
    );
  }
}

class SavedItemsTag extends StatelessWidget {
  const SavedItemsTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF6B55E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Saved Items",
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xff5E1D04),
        ),
      ),
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final WishlistItemModel item;
  final bool isLarge;

  const WishlistItemCard({
    super.key,
    required this.item,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return _buildLargeCard();
    }
    return _buildSmallCard();
  }

  Widget _buildSmallCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(item.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    WishlistService.instance.toggleWishlist(
                      name: item.name,
                      price: item.price,
                      imagePath: item.imagePath,
                    );
                  },
                  child: Icon(
                    item.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: item.isLiked ? const Color(0xffF6B55E) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5E1D04),
              ),
            ),
            Text(
              "\$${item.price.toInt()}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(item.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  WishlistService.instance.toggleWishlist(
                    name: item.name,
                    price: item.price,
                    imagePath: item.imagePath,
                  );
                },
                child: Icon(
                  item.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xff5E1D04),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "\$${item.price.toInt()}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
