import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/cart_widgets.dart';

import '../widgets/bottom_navigation_bar.dart';

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
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final String buyerId = _auth.currentUser?.uid ?? '';
      if (buyerId.isNotEmpty) {
        final results = await Future.wait([
          _cartService.getCartItems(buyerId),
          _cartService.getCartTotal(buyerId),
        ]);

        _items = results[0] as List<CartItemModel>;
        _subtotal = results[1] as double;
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _clearEntireCart() async {
    try {
      final String buyerId = _auth.currentUser?.uid ?? '';
      if (buyerId.isEmpty) return;

      setState(() => _isLoading = true);
      await _cartService.clearCart(buyerId);
      await _loadCart();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff5E1D04)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Shopping Cart",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && _items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xff5E1D04)),
              onPressed: _clearEntireCart,
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : _items.isEmpty
          ? const EmptyCartView()
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xffD08C4A),
              onRefresh: _loadCart,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return CartItemWidget(
                    item: _items[index],
                    index: index,
                    cartService: _cartService,
                  );
                },
              ),
            ),
          ),
          CartOrderSummary(
            subtotal: _subtotal,
            total: _subtotal,
          ),
        ],
      ),
    );
  }
}