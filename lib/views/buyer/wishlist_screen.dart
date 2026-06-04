import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/wishlist_item_model.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/wishlist_widgets.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: WishlistService.instance,
          builder: (context, _) {
            final items = WishlistService.instance.items;

            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WishlistHeader(),
                    const Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.favorite_border,
                              size: 80, color: const Color(0xff5E1D04).withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            "Your wishlist is empty",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: const Color(0xff5E1D04).withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WishlistHeader(),
                  const SizedBox(height: 30),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (items.length / 2).ceil(),
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final firstIndex = index * 2;
                      final secondIndex = firstIndex + 1;

                      // Every 3rd "logical" row is large (approx)
                      if (index % 3 == 2) {
                        return WishlistItemCard(item: items[firstIndex], isLarge: true);
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 220,
                              child: WishlistItemCard(item: items[firstIndex]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (secondIndex < items.length)
                            Expanded(
                              child: SizedBox(
                                height: 220,
                                child: WishlistItemCard(item: items[secondIndex]),
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
        ),
      ),
    );
  }
}
