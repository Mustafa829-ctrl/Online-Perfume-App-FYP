import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/cart_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/product_details_widgets.dart';


class ProductDetails extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String imagePath;

  const ProductDetails({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.imagePath,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String _selectedVolume = "100 ml";
  String _selectedScent = "Blackcurrant";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_outlined, color: Color(0xff5E1D04)),
          onPressed: () {
            // Can add drawer or back navigation here depending on flow
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Product details",
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Color(0xff5E1D04)),
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Main Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imagePath, // e.g., 'assets/images/perfume-6.png'
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 20),

            // Title and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.productName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                ),
                Text(
                  widget.productPrice,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff5E1D04),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Volume Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                VolumeSelector(
                  volume: "50 ml",
                  isSelected: _selectedVolume == "50 ml",
                  onTap: () => setState(() => _selectedVolume = "50 ml"),
                ),
                VolumeSelector(
                  volume: "100 ml",
                  isSelected: _selectedVolume == "100 ml",
                  onTap: () => setState(() => _selectedVolume = "100 ml"),
                ),
                VolumeSelector(
                  volume: "150 ml",
                  isSelected: _selectedVolume == "150 ml",
                  onTap: () => setState(() => _selectedVolume = "150 ml"),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Scent Header and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                       alignment: Alignment.center,
                       children: [
                         Transform.rotate(
                           angle: 0.785398, // 45 degrees in radians
                           child: Container(
                             width: 14,
                             height: 14,
                             decoration: BoxDecoration(
                               border: Border.all(color: const Color(0xff5E1D04), width: 1.5),
                             ),
                           ),
                         ),
                       ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Scent",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Scent Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ScentSelector(
                    scent: "Blackcurrant",
                    isSelected: _selectedScent == "Blackcurrant",
                    onTap: () => setState(() => _selectedScent = "Blackcurrant"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ScentSelector(
                    scent: "Jasme",
                    isSelected: _selectedScent == "Jasme",
                    imagePath: 'assets/images/perfume.png',
                    onTap: () => setState(() => _selectedScent = "Jasme"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Bottom Flowery Image Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/perfume-6.png', // Temporary placeholder for flowery banner
                height: 220, // Increased height to show full picture
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 25),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Parse price string (e.g. "$120.00") to double
                  final priceStr = widget.productPrice.replaceAll(RegExp(r'[^\d.]'), '');
                  final price = double.tryParse(priceStr) ?? 0.0;

                  CartService.instance.addItem(
                    productName: widget.productName,
                    price: price,
                    imagePath: widget.imagePath,
                    selectedVolume: _selectedVolume,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${widget.productName} added to cart!",
                        style: const TextStyle(color: Color(0xff5E1D04)),
                      ),
                      backgroundColor: const Color(0xffF6B55E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      action: SnackBarAction(
                        label: "View Cart",
                        textColor: const Color(0xff5E1D04),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A), // Solid orange/brown
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.black.withOpacity(0.5),
                  elevation: 8,
                ),
                child: Text(
                  "Add to Cart", // Keeping spelling from design
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
