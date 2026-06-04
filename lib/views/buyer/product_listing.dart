import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/product_listing_widgets.dart';

class ProductListing extends StatefulWidget {
  const ProductListing({super.key});

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu_outlined, color: Color(0xff5E1D04)),
        title: Text(
          "Product Listing",
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0), // Assuming it's part of home flow
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Filters Row
            const Row(
              children: [
                Expanded(child: FilterButtonWidget(label: "Select")),
                SizedBox(width: 20),
                Expanded(child: FilterButtonWidget(label: "Search")),
              ],
            ),
            const SizedBox(height: 20),

            // Staggered layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Tall Item
                const Expanded(
                  child: TallProductCard(
                    title: "Elegant Noir",
                    price: "\$95",
                    imagePath: "assets/images/perfume.png", // Using available assets
                  ),
                ),
                const SizedBox(width: 15),
                // Right Column - Stacked Items
                Expanded(
                  child: Column(
                    children: [
                      const SmallProductCard(
                        title: "Sold Quit",
                        price: "\$95",
                        imagePath: "assets/images/perfume-6.png",
                      ),
                      const SizedBox(height: 15),
                      // Shop Now Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xffD08C4A),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Shop Now",
                            style: GoogleFonts.poppins(
                              color: const Color(0xff5E1D04),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const SmallProductCard(
                        title: "Amber Noir",
                        price: "\$93",
                        imagePath: "assets/images/perfume.png", // Reuse image or add new ones later
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
