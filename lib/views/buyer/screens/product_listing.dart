import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer%20auth/buyer_login_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/product_listing_widgets.dart';
import 'product_details.dart';

class ProductListing extends StatefulWidget {
  final String? preSelectedCategory;

  const ProductListing({super.key, this.preSelectedCategory});

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  final ProductService _productService = ProductService();

  bool isLoading = false;
  List<ProductModel> _allProducts   = [];
  List<ProductModel> _filtered      = [];

  String _selectedCategory = 'All';
  String _selectedSort     = 'Newest';

  final List<String> _sortOptions = [
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
  ];

  // Category list built dynamically from products
  List<String> get _categories {
    final cats = _allProducts
        .map((p) => p.category ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return ['All', ...cats];
  }

  bool get _isLoggedIn =>
      FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedCategory != null) {
      _selectedCategory = widget.preSelectedCategory!;
    }
    _loadProducts();
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
      _showError(e.toString());
    }
  }

  void _applyFilters() {
    List<ProductModel> result = List.from(_allProducts);

    // Category filter
    if (_selectedCategory != 'All') {
      result = result
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'Price: Low to High':
        result.sort((a, b) =>
            (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'Price: High to Low':
        result.sort((a, b) =>
            (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'Top Rated':
        result.sort((a, b) =>
            (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'Newest':
      default:
        result.sort((a, b) =>
            (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        break;
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
                      builder: (_) => const BuyerLoginScreen()));
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

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
      Text(msg, style: GoogleFonts.poppins(fontSize: 12)),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Category filter bottom sheet
  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Select Category',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedCategory = cat);
                    _applyFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff5E1D04)
                          : const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xff5E1D04)
                              : const Color(0xFFEEEEEE)),
                    ),
                    child: Text(cat,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xffF6B55E)
                                : Colors.grey.shade600)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sort bottom sheet
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Sort By',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 12),
            ..._sortOptions.map((option) {
              final isSelected = _selectedSort == option;
              return ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedSort = option);
                  _applyFilters();
                },
                title: Text(option,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xff5E1D04)
                            : Colors.grey.shade600)),
                trailing: isSelected
                    ? const Icon(Icons.check,
                    color: Color(0xffD08C4A))
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              );
            }),
          ],
        ),
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
        title: Text('Shop',
            style: GoogleFonts.poppins(
                fontSize: 22,
                color: const Color(0xff5E1D04),
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      bottomNavigationBar:
      const CustomBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        color: const Color(0xffD08C4A),
        onRefresh: _loadProducts,
        child: Column(
          children: [
            // ── Filter row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: FilterButtonWidget(
                      label: _selectedCategory == 'All'
                          ? 'Category'
                          : _selectedCategory,
                      onTap: _showCategorySheet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilterButtonWidget(
                      label: _selectedSort == 'Newest'
                          ? 'Sort By'
                          : _selectedSort,
                      onTap: _showSortSheet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Count
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} Products',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Products grid
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
                        Icons
                            .local_florist_outlined,
                        size: 60,
                        color:
                        Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No products found',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors
                                .grey.shade400)),
                  ],
                ),
              )
                  : _filtered.length == 1
              // Single product — tall card full width
                  ? ListView(
                padding:
                const EdgeInsets.fromLTRB(
                    20, 0, 20, 20),
                children: [
                  TallProductCard(
                    product: _filtered.first,
                    isLoggedIn: _isLoggedIn,
                    onLoginRequired:
                    _showLoginPrompt,
                  ),
                ],
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(
                    20, 0, 20, 20),
                itemCount: (_filtered.length /
                    2)
                    .ceil(),
                itemBuilder: (context, rowIndex) {
                  final leftIndex = rowIndex * 2;
                  final rightIndex =
                      leftIndex + 1;
                  final leftProduct =
                  _filtered[leftIndex];
                  final hasRight = rightIndex;
                  _filtered.length;

                  // Alternate tall/small layout
                  // Even rows: left=tall, right=small
                  // Odd rows: left=small, right=tall
                  final isEvenRow =
                      rowIndex % 2 == 0;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
                        bottom: 15),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Expanded(
                          child: isEvenRow
                              ? TallProductCard(
                            product:
                            leftProduct,
                            isLoggedIn:
                            _isLoggedIn,
                            onLoginRequired:
                            _showLoginPrompt,
                          )
                              : SmallProductCard(
                            product:
                            leftProduct,
                            isLoggedIn:
                            _isLoggedIn,
                            onLoginRequired:
                            _showLoginPrompt,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: hasRight == 1
                              ? (isEvenRow
                              ? SmallProductCard(
                            product: _filtered[
                            rightIndex],
                            isLoggedIn:
                            _isLoggedIn,
                            onLoginRequired:
                            _showLoginPrompt,
                          )
                              : TallProductCard(
                            product: _filtered[
                            rightIndex],
                            isLoggedIn:
                            _isLoggedIn,
                            onLoginRequired:
                            _showLoginPrompt,
                          ))
                              : const SizedBox(),
                        ),
                      ],
                    ),
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