import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/buyer/product_details.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF6B55E), // Orange/yellow
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xff5E1D04)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search product by name, brand or id",
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xff5E1D04),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeLimitedOffer extends StatelessWidget {
  const HomeLimitedOffer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Limited Offer clicked!")),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/perfume-6.png', // Or ads2.png, perfume.png
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Limited Offer",
                style: GoogleFonts.poppins(
                  fontSize: 18,
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

class HomeGiftFinder extends StatelessWidget {
  const HomeGiftFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xff2A1A12), // Dark brown/black on left
            Color(0xffD5A66B), // Goldish on right
            Color(0xffFDFBF7), // White/light on far right behind image
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 16.0, bottom: 16.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gift Finder",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff5E1D04), // Dark brown text on gold background
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Find the perfect\ngift for any occasion",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.asset(
                "assets/images/perfume.png", // Using dummy image for gift boxes
                fit: BoxFit.cover,
                height: 110,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandChip extends StatelessWidget {
  final String label;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const BrandChip({
    super.key,
    required this.label,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff5E1D04) : const Color(0xff1A0A1F), // Very dark background like the design
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xffF6B55E), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            if (imagePath != null) ...[
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(imagePath!),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xffF6B55E), // Making text yellow as per design
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductHomeCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductHomeCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              productName: product["name"],
              productPrice: product["price"],
              imagePath: product["image"],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      product["image"],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product["name"],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product["brand"],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product["price"],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        Text(
                          product["rating"],
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: ListenableBuilder(
                listenable: WishlistService.instance,
                builder: (context, _) {
                  final bool isLiked = WishlistService.instance.isInWishlist(product["name"]);
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? const Color(0xffF6B55E) : const Color(0xff5E1D04),
                      size: 22,
                    ),
                    onPressed: () {
                      final priceStr = product["price"].replaceAll(RegExp(r'[^\d.]'), '');
                      final price = double.tryParse(priceStr) ?? 0.0;
                      WishlistService.instance.toggleWishlist(
                        name: product["name"],
                        price: price,
                        imagePath: product["image"],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
