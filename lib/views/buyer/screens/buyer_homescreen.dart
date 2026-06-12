import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/category_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/category_service.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/product_listing.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/buyer_homescreen_widgets.dart';

import '../buyer auth/buyer_login_screen.dart';
import 'menu_bar.dart';

class BuyerHomescreen extends StatefulWidget {
  const BuyerHomescreen({super.key});

  @override
  State<BuyerHomescreen> createState() => _BuyerHomescreenState();
}

class _BuyerHomescreenState extends State<BuyerHomescreen> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  final TextEditingController _searchFieldController = TextEditingController();

  bool _isCategoriesLoading = true;
  bool _isProductsLoading = true;

  List<CategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  String _selectedCategory = 'All';
  String _searchQueryString = '';

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _fetchLiveHomeData();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveHomeData() async {
    await Future.wait([
      _loadFirestoreCategories(),
      _loadFirestoreProducts(),
    ]);
  }

  Future<void> _loadFirestoreCategories() async {
    try {
      final data = await _categoryService.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = data;
          _isCategoriesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCategoriesLoading = false);
    }
  }

  Future<void> _loadFirestoreProducts() async {
    try {
      final data = await _productService.getAllProducts();
      if (mounted) {
        setState(() {
          _allProducts = data;
          _isProductsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isProductsLoading = false);
    }
  }

  List<ProductModel> get _filteredProducts {
    List<ProductModel> list = _allProducts;
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQueryString.isNotEmpty) {
      list = list.where((p) =>
      (p.name ?? '').toLowerCase().contains(_searchQueryString.toLowerCase()) ||
          (p.brand ?? '').toLowerCase().contains(_searchQueryString.toLowerCase())).toList();
    }
    return list;
  }

  void _onCategorySelected(String categoryName) {
    setState(() => _selectedCategory = categoryName);
  }

  // ── Login Prompt ─────────────────────────────────────
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Required'),
        content: const Text(
          'Please login or create an account to add items to cart or wishlist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyerLoginScreen()),
              );
            },
            child: const Text('Login Now'),
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
        title: Text(
          'Buyer Home',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: _isLoggedIn
            ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff5E1D04)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
            : null,
      ),

      drawer: _isLoggedIn ? const BuyerMenuBar() : null,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),

      body: RefreshIndicator(
        color: const Color(0xffD08C4A),
        onRefresh: _fetchLiveHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Guest Banner
              if (!_isLoggedIn)
                GestureDetector(
                  onTap: _showLoginPrompt,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffD08C4A).withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xffD08C4A)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Login to add to cart, wishlist & place orders',
                            style: TextStyle(fontSize: 13, color: Color(0xff5E1D04)),
                          ),
                        ),
                        Text('Login →', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              // Search Bar
              HomeSearchBar(
                controller: _searchFieldController,
                onChanged: (val) => setState(() => _searchQueryString = val),
              ),
              const SizedBox(height: 20),

              // Categories & Products (same as before)
              Text('Featured Scent', style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
              const SizedBox(height: 10),

              // ... your categories and products grid code remains same ...

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.72,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return ProductHomeCard(
                    product: product,
                    isLoggedIn: _isLoggedIn,
                    onLoginRequired: _showLoginPrompt,
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}