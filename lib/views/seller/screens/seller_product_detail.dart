import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_edit_product_screen.dart';

class SellerProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final SellerModel seller;

  const SellerProductDetailsScreen({
    super.key,
    required this.product,
    required this.seller,
  });

  @override
  State<SellerProductDetailsScreen> createState() =>
      _SellerProductDetailsScreenState();
}

class _SellerProductDetailsScreenState
    extends State<SellerProductDetailsScreen> {
  final ProductService _productService = ProductService();
  bool _isDeleting = false;

  // Fragrance notes as chips
  List<String> _fragranceChips(String? notes) {
    if (notes == null || notes.isEmpty) return [];
    return notes
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  Future<void> _deleteProduct(String docId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Product?',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        content: Text(
          'Are you sure you want to delete "$name"? This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isDeleting = true);
      await _productService.deleteProduct(docId);
      if (mounted) {
        Navigator.pop(context); // back to products list
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Product deleted', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xff5E1D04),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() => _isDeleting = false);
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

  @override
  Widget build(BuildContext context) {
    final docId = widget.product.docId ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Product Details',
            style: GoogleFonts.poppins(
                fontSize: 20,
                color: const Color(0xff5E1D04),
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xff5E1D04)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SellerEditProductScreen(
                      product: widget.product,
                      seller: widget.seller,
                    ),
              ),
            ),
          ),
          // Delete button
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.red),
            )
                : const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isDeleting
                ? null
                : () => _deleteProduct(docId, widget.product.name ?? 'this product'),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Real-time stream — stock updates live as orders come in
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xffD08C4A)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Product not found',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey.shade500)),
            );
          }

          final product = ProductModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);
          final sizes = product.sizes ?? [];
          final threshold = product.threshold ?? 5;
          final totalStock = product.stock ?? 0;
          final isLowStock = totalStock <= threshold;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (product.imageUrl ?? '').isNotEmpty
                      ? Image.network(
                    product.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                      : _imagePlaceholder(),
                ),
                const SizedBox(height: 20),

                // Name + Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? '',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff5E1D04),
                            ),
                          ),
                          if ((product.brand ?? '').isNotEmpty)
                            Text(product.brand!,
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (product.isAvailable ?? true)
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (product.isAvailable ?? true) ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: (product.isAvailable ?? true)
                              ? const Color(0xff66BB6A)
                              : const Color(0xffEF5350),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating row
                Row(children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    (product.rating ?? 0.0).toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${product.reviewCount ?? 0} reviews)',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_bag_outlined,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${product.totalSold ?? 0} sold',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ]),
                const SizedBox(height: 20),

                // Low Stock Warning Banner
                if (isLowStock)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xffEF5350).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xffEF5350), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Low stock! Total stock ($totalStock) is at or below threshold ($threshold)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xffEF5350),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ]),
                  ),

                // Stock by Size — seller-only view
                Text('Stock by Size',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04))),
                const SizedBox(height: 12),
                sizes.isEmpty
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text('No sizes added for this product',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ]),
                )
                    : Column(
                  children: sizes.map((sizeMap) {
                    final size = sizeMap['size']?.toString() ?? '';
                    final price =
                        (sizeMap['price'] as num?)?.toDouble() ?? 0.0;
                    final stock =
                        (sizeMap['stock'] as num?)?.toInt() ?? 0;
                    final lowStockForSize = stock <= threshold;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: lowStockForSize
                              ? const Color(0xffEF5350).withOpacity(0.3)
                              : const Color(0xFFEEEEEE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xff5E1D04),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(size,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xffF6B55E))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Rs ${price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff5E1D04))),
                          ),
                          Row(
                            children: [
                              Icon(
                                lowStockForSize
                                    ? Icons.warning_amber_rounded
                                    : Icons.inventory_2_outlined,
                                size: 14,
                                color: lowStockForSize
                                    ? const Color(0xffEF5350)
                                    : const Color(0xff66BB6A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Stock: $stock',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: lowStockForSize
                                      ? const Color(0xffEF5350)
                                      : const Color(0xff66BB6A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Total stock summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Stock',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff5E1D04))),
                      Text('$totalStock units',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffD08C4A))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Discount info (if any)
                if ((product.discount ?? 0) > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.local_offer_outlined,
                          color: Color(0xff66BB6A), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${product.discount!.toStringAsFixed(0)}% discount active',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff66BB6A),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Description
                if ((product.description ?? '').isNotEmpty) ...[
                  Text('Description',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04))),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey.shade600, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                ],

                // Fragrance notes
                if (_fragranceChips(product.fragranceNotes).isNotEmpty) ...[
                  Text('Fragrance Notes',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fragranceChips(product.fragranceNotes)
                        .map((note) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff5E1D04),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(note,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xffF6B55E))),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Concentration + Category
                if ((product.concentration ?? '').isNotEmpty ||
                    (product.category ?? '').isNotEmpty) ...[
                  Row(children: [
                    if ((product.concentration ?? '').isNotEmpty)
                      _InfoChip(
                          label: product.concentration!,
                          icon: Icons.water_drop_outlined),
                    const SizedBox(width: 8),
                    if ((product.category ?? '').isNotEmpty)
                      _InfoChip(
                          label: product.category!,
                          icon: Icons.category_outlined),
                  ]),
                  const SizedBox(height: 20),
                ],

                // Threshold setting display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.tune, color: Color(0xffD08C4A), size: 18),
                    const SizedBox(width: 10),
                    Text('Low Stock Threshold',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey.shade600)),
                    const Spacer(),
                    Text('$threshold units',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04))),
                  ]),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: const Color(0xFFFFF3CD),
      child: const Center(
        child: Icon(Icons.local_florist_outlined,
            color: Color(0xffD08C4A), size: 60),
      ),
    );
  }
}

// Info Chip (concentration, category)
class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: const Color(0xffD08C4A)),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xff5E1D04))),
      ]),
    );
  }
}