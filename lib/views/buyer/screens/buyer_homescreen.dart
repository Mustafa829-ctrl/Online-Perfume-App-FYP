import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/category_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/category_service.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/cart_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/wishlist_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/profile_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/buyer_homescreen_widgets.dart';
import '../../../services/user_auth_service.dart';
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
  final BuyerAuthService _buyerAuth = BuyerAuthService();
  final TextEditingController _searchFieldController = TextEditingController();

  bool _isCategoriesLoading = true;
  bool _isProductsLoading = true;
  List<CategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  String _selectedCategory = 'All';
  String _searchQueryString = '';

  int _selectedIndex = 0;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Stream<int> get _cartCountStream {
    final user = _currentUser;
    if (user == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

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
    await Future.wait([_loadFirestoreCategories(), _loadFirestoreProducts()]);
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

  // MENU HANDLER
  void _handleMenuTap(BuildContext context) {
    if (_currentUser == null) {
      _showLoginPrompt();
    } else {
      Scaffold.of(context).openDrawer();
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xffD08C4A), size: 28),
            const SizedBox(width: 12),
            Text('Login Required', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Please login first to access the menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerLoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5E1D04),
              foregroundColor: const Color(0xffD08C4A),
            ),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = index);
      return;
    }
    _guardNavigation(index);
  }

  Future<void> _guardNavigation(int index) async {
    final isValid = await _buyerAuth.isValidBuyer();
    if (!isValid) {
      _showLoginPrompt();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      color: const Color(0xffD08C4A),
      onRefresh: _fetchLiveHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (_currentUser == null)
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
                        child: Text('Please Login First', style: TextStyle(fontSize: 13, color: Color(0xff5E1D04))),
                      ),
                      Text('Login ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            HomeSearchBar(
              controller: _searchFieldController,
              onChanged: (val) => setState(() => _searchQueryString = val),
            ),
            const SizedBox(height: 20),
            Text(
              'Featured Scent',
              style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
            ),
            const SizedBox(height: 10),
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
                  isLoggedIn: _currentUser != null,
                  onLoginRequired: _showLoginPrompt,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final bool isLoggedIn = authSnapshot.data != null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _selectedIndex == 0 ? 'Buyer Home' : _selectedIndex == 1 ? 'My Wishlist' : _selectedIndex == 2 ? 'Shopping Cart' : 'My Profile',
              style: GoogleFonts.poppins(fontSize: 22, color: const Color(0xff5E1D04), fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Color(0xff5E1D04)),
                onPressed: () => _handleMenuTap(context),   // ← Fixed
              ),
            ),
          ),
          drawer: isLoggedIn ? const BuyerMenuBar() : null,
          body: _selectedIndex == 0
              ? _buildHomeContent()
              : _selectedIndex == 1
              ? const WishlistScreen()
              : _selectedIndex == 2
              ? const CartScreen()
              : const ProfileScreen(),
          bottomNavigationBar: StreamBuilder<int>(
            stream: _cartCountStream,
            initialData: 0,
            builder: (context, snapshot) {
              final cartCount = snapshot.data ?? 0;
              return BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xffD08C4A),
                unselectedItemColor: Colors.grey,
                items: [
                  const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                  const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
                  BottomNavigationBarItem(
                    icon: _CartIcon(cartCount: cartCount, isLoggedIn: isLoggedIn),
                    activeIcon: _CartIcon(cartCount: cartCount, isLoggedIn: isLoggedIn, isActive: true),
                    label: 'Cart',
                  ),
                  const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int cartCount;
  final bool isLoggedIn;
  final bool isActive;

  const _CartIcon({required this.cartCount, required this.isLoggedIn, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
        if (cartCount > 0 && isLoggedIn)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Color(0xff5E1D04), shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              child: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(color: Color(0xffD08C4A), fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}