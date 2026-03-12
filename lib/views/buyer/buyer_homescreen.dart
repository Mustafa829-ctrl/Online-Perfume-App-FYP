import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/product_listing.dart';
import 'package:online_perfume_app_fyp/views/buyer/product_details.dart';

class BuyerHomescreen extends StatefulWidget {
  const BuyerHomescreen({super.key});

  @override
  State<BuyerHomescreen> createState() => _BuyerHomescreenState();
}

class _BuyerHomescreenState extends State<BuyerHomescreen> {
  // Dummy product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      "name": "Luxury Perfume",
      "brand": "Floral",
      "price": "\$120.00",
      "image": "assets/images/perfume.png",
      "rating": "4.8"
    },
    {
      "name": "Ocean Breeze",
      "brand": "Fresh",
      "price": "\$85.00",
      "image": "assets/images/perfume-6.png",
      "rating": "4.5"
    },
    {
       "name": "Midnight Rose",
       "brand": "Azan",
       "price": "\$95.00",
       "image": "assets/images/perfume.png", // Reusing image for dummy data
       "rating": "4.9"
    },
    {
       "name": "Citrus Splash",
       "brand": "Fresh",
       "price": "\$70.00",
       "image": "assets/images/perfume-6.png",
       "rating": "4.2"
    }
  ];

  String _selectedBrand = "All"; // 'All', 'Floral', 'Fresh', 'Azan'

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedBrand == "All") return _allProducts;
    return _allProducts.where((p) => p["brand"] == _selectedBrand).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1C8C6), // Light pink background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu_outlined, color: const Color(0xff5E1D04)),
        title: Text(
          "Buyer Home",
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 1. Search Bar
            Container(
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
            const SizedBox(height: 20),

            // 2. Limited Offer Image
            GestureDetector(
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
                         color: Colors.white.withOpacity(0.7),
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
            ),
            const SizedBox(height: 20),

            // 3. Featured Scent & Brands
            Text(
              "Featured Scent",
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBrandChip("All", null),
                  const SizedBox(width: 10),
                   _buildBrandChip("Floral", "assets/images/perfume.png"),
                  const SizedBox(width: 10),
                  _buildBrandChip("Fresh", "assets/images/perfume-6.png"),
                  const SizedBox(width: 10),
                  _buildBrandChip("Azan", "assets/images/perfume.png"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Shop Now button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductListing()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A), // Brown/orange button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: Colors.black.withOpacity(0.5),
                  elevation: 5,
                ),
                child: Text(
                  "Shop Now",
                  style: GoogleFonts.poppins(color: const Color(0xff5E1D04), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Gift Finder Section (Updated design)
             Container(
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
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 8.0),
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
            ),
            const SizedBox(height: 25), 
            
            // Re-added Products GridView (Mix of products)
            Text(
               "Top Products",
               style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75, // Adjust based on card height
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product);
              },
            ),

            const SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChip(String label, String? imagePath) {
    bool isSelected = _selectedBrand == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBrand = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff5E1D04) : const Color(0xff1A0A1F), // Very dark background like the design
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xffF6B55E), width: 1.5) : null,
        ),
        child: Row(
          children: [
            if (imagePath != null) ...[
               CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(imagePath),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
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
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
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
              style: GoogleFonts.poppins( // Will switch to Playfair in Details, sticking to Poppins here for consistency with previous 
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
                color: const Color(0xff5E1D04).withOpacity(0.7),
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
      ),
    );
  }
}
