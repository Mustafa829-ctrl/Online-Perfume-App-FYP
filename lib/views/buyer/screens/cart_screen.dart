import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/cart_widgets.dart';
import '../buyer auth/buyer_login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartItemModel> _items = [];
  double _subtotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final String buyerId = user.uid;
      final results = await Future.wait([
        _cartService.getCartItems(buyerId),
        _cartService.getCartTotal(buyerId),
      ]);

      if (mounted) {
        setState(() {
          _items = results[0] as List<CartItemModel>;
          _subtotal = results[1] as double;
        });
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _clearEntireCart() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      setState(() => _isLoading = true);
      await _cartService.clearCart(user.uid);
      await _loadCart();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    // Guest User
    if (user == null) {
      return _buildGuestState();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)));
    }

    if (_items.isEmpty) {
      return const EmptyCartView();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shopping Cart',
                style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xff5E1D04)),
                onPressed: _clearEntireCart,
                tooltip: 'Clear cart',
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xffD08C4A),
            onRefresh: _loadCart,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              itemBuilder: (context, index) => CartItemWidget(
                item: _items[index],
                index: index,
                cartService: _cartService,
              ),
            ),
          ),
        ),
        CartOrderSummary(
          subtotal: _subtotal,
          total: _subtotal,
        ),
      ],
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: const Color(0xff5E1D04).withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Login to view your cart',
              style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xff5E1D04).withOpacity(0.6), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cart items will appear here after login',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyerLoginScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5E1D04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Login Now',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xffD08C4A))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}