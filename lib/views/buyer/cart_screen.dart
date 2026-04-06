import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';
import 'package:online_perfume_app_fyp/widgets/bottom_navigation_bar.dart';

import 'package:online_perfume_app_fyp/widgets/cart_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService.instance;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<CartItemModel> items = List.from(_cartService.items);

    return Scaffold(
      backgroundColor: const Color(0xffF1C8C6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xff5E1D04)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Shopping Cart",
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xff5E1D04)),
              tooltip: "Clear Cart",
              onPressed: () {
                _cartService.clearCart();
              },
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: items.isEmpty
          ? const EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return CartItemWidget(
                        item: items[index],
                        index: index,
                        cartService: _cartService,
                      );
                    },
                  ),
                ),
                CartOrderSummary(
                  subtotal: _cartService.subtotal,
                  total: _cartService.total,
                ),
              ],
            ),
    );
  }
}
