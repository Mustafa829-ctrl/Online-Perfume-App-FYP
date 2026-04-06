import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/buyer/product_details.dart';

class FilterButtonWidget extends StatelessWidget {
  final String label;

  const FilterButtonWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xff5E1D04),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xff5E1D04)),
        ],
      ),
    );
  }
}

class TallProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;

  const TallProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              productName: title,
              productPrice: price,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        height: 480, // Taller size
        decoration: BoxDecoration(
          color: const Color(0xffF8E7E5), // Lighter background for card
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      // Using serif-like font for titles
                      color: const Color(0xff5E1D04),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xff5E1D04),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Color(0xff5E1D04)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmallProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;

  const SmallProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              productName: title,
              productPrice: price,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        height: 200, // Shorter size
        decoration: BoxDecoration(
          color: const Color(0xffF8E7E5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xff5E1D04),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xff5E1D04),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Color(0xff5E1D04)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
