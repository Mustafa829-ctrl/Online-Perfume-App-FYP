import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer%20auth/buyer_login_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import '../widgets/product_listing_widgets.dart';
import 'product_details.dart';

class SearchResultScreen extends StatefulWidget {
  final String category;

  const SearchResultScreen({
    super.key,
    this.category = '',
  });

  @override
  State<SearchResultScreen> createState() =>
      _SearchResultScreenState();
}

class _SearchResultScreenState
    extends State<SearchResultScreen> {
  final ProductService _productService = ProductService();

  late TextEditingController _searchController;

  bool isLoading = false;
  List<ProductModel> _allProducts  = [];
  List<ProductModel> _filtered     = [];

  // ── Scent/category filter chips
  // Built dynamically from products + 'All'
  List<String> get _filterChips {
    final cats = _allProducts
        .map((p) => p.category ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return ['All', ...cats];
  }

  String _selectedChip = 'All';

  bool get _isLoggedIn =>
      FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.category);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => isLoading = true);
      final products = await _productService.getAllProducts();
      setState(() {
        _allProducts = products;
        isLoading    = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    final keyword =
    _searchController.text.trim().toLowerCase();
    List<ProductModel> result = List.from(_allProducts);

    // Keyword filter
    if (keyword.isNotEmpty) {
      result = result.where((p) {
        return (p.name?.toLowerCase().contains(keyword) ??
            false) ||
            (p.brand?.toLowerCase().contains(keyword) ??
                false) ||
            (p.category?.toLowerCase().contains(keyword) ??
                false) ||
            (p.fragranceNotes
                ?.toLowerCase()
                .contains(keyword) ??
                false);
      }).toList();
    }

    // Category chip filter
    if (_selectedChip != 'All') {
      result = result
          .where((p) => p.category == _selectedChip)
          .toList();
    }

    setState(() => _filtered = result);
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.lock_outline,
              color: Color(0xffD08C4A), size: 24),
          const SizedBox(width: 8),
          Text('Login Required',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                  fontSize: 16)),
        ]),
        content: Text(
          'Please login or create an account to continue.',
          style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Browse',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const BuyerLoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5E1D04),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Login',
                style: GoogleFonts.poppins(
                    color: const Color(0xffD08C4A),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
        ),
        title: // Search bar in app bar
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xff5E1D04).withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            style: GoogleFonts.poppins(
                color: const Color(0xff5E1D04),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search fragrances, brands...',
              hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: const Icon(Icons.search,
                  color: Color(0xff5E1D04), size: 20),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
      const CustomBottomNav(currentIndex: 0),
      body: Column(
        children: [
          // ── Category filter chips (dynamic from products)
          SizedBox(
            height: 56,
            child: isLoading
                ? const SizedBox()
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              itemCount: _filterChips.length,
              itemBuilder: (context, index) {
                final chip = _filterChips[index];
                final isSelected =
                    _selectedChip == chip;

                return Padding(
                  padding:
                  const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(
                              () => _selectedChip = chip);
                      _applyFilters();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff5E1D04)
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xff5E1D04)
                              : const Color(0xff5E1D04)
                              .withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        chip,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xffF6B55E)
                              : const Color(0xff5E1D04),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Results count
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isLoading
                    ? 'Loading...'
                    : '${_filtered.length} results',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500),
              ),
            ),
          ),

          // ── Products list
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A)))
                : _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.search_off_outlined,
                      size: 60,
                      color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                      'No matching fragrances found',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color:
                          Colors.grey.shade400)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final product = _filtered[index];
                return _SearchProductCard(
                  product: product,
                  isLoggedIn: _isLoggedIn,
                  onLoginRequired: _showLoginPrompt,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search result product card
class _SearchProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const _SearchProductCard({
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: (product.imageUrl ?? '').isNotEmpty
                      ? Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildFallback(),
                  )
                      : _buildFallback(),
                ),
                const SizedBox(height: 10),

                // Name
                Text(
                  product.name ?? '',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xff5E1D04),
                  ),
                ),

                // Brand + rating
                Row(children: [
                  if ((product.brand ?? '').isNotEmpty)
                    Text(product.brand ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500)),
                  const Spacer(),
                  const Icon(Icons.star,
                      color: Colors.orange, size: 13),
                  const SizedBox(width: 2),
                  Text(
                    (product.rating ?? 0.0).toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600),
                  ),
                ]),
              ],
            ),

            // Price badge
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formattedPrice,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),

            // Discount badge
            if ((product.discount ?? 0) > 0)
              Positioned(
                top: 14,
                left: 14,
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

            // Wishlist button
            Positioned(
              bottom: 46,
              right: 14,
              child: WishlistBtn(
                product: product,
                isLoggedIn: isLoggedIn,
                onLoginRequired: onLoginRequired,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.local_florist_outlined,
          color: Color(0xffD08C4A), size: 48),
    );
  }
}