import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/wishlist_widgets.dart';
import '../buyer auth/buyer_login_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? _buildWishlistContent() : _buildGuestState();
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
              'Login to view your wishlist',
              style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xff5E1D04).withOpacity(0.5), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your favourite fragrances\nand access them anytime',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyerLoginScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5E1D04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Login', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xffD08C4A))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistContent() {
    return StreamBuilder<List<WishlistItemModel>>(
      stream: _wishlistService.getWishlistStream(_userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Failed to load wishlist', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: const Color(0xff5E1D04).withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('Your wishlist is empty', style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xff5E1D04).withOpacity(0.5))),
                const SizedBox(height: 8),
                Text('Add fragrances you love to your wishlist', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header (since parent app bar is fixed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Wishlist', style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                      Text('Your saved fragrances', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.favorite, color: Color(0xff5E1D04), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${items.length} item${items.length == 1 ? '' : 's'} saved', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (items.length / 2).ceil(),
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final firstIndex = index * 2;
                  final secondIndex = firstIndex + 1;
                  if (index % 3 == 2) {
                    return WishlistItemCard(
                      item: items[firstIndex],
                      isLarge: true,
                      onRemove: () => _removeItem(items[firstIndex]),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 220,
                          child: WishlistItemCard(
                            item: items[firstIndex],
                            onRemove: () => _removeItem(items[firstIndex]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (secondIndex < items.length)
                        Expanded(
                          child: SizedBox(
                            height: 220,
                            child: WishlistItemCard(
                              item: items[secondIndex],
                              onRemove: () => _removeItem(items[secondIndex]),
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeItem(WishlistItemModel item) async {
    try {
      await _wishlistService.removeFromWishlist(buyerId: _userId!, productId: item.productId ?? '');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }
}