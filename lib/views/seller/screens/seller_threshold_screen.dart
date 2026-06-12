import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/services/threshold_service.dart';

class SellerThresholdScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerThresholdScreen({super.key, required this.seller});

  @override
  State<SellerThresholdScreen> createState() => _SellerThresholdScreenState();
}

class _SellerThresholdScreenState extends State<SellerThresholdScreen> {
  // Services
  final ProductService _productService = ProductService();
  final ThresholdService _thresholdService = ThresholdService();

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // State
  bool isLoading = false;
  List<ProductModel> allProducts = [];

  // Selected filter
  String _selectedFilter = 'All';

  // Filter options
  final List<String> _filters = ['All', 'Low Stock', 'Critical', 'OK'];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load products from Firebase
  Future<void> loadProducts() async {
    try {
      isLoading = true;
      setState(() {});

      String sellerId = widget.seller.docId ?? '';
      allProducts = await _productService.getSellerProducts(sellerId);

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Stock status helper using ProductModel fields
  Map<String, dynamic> _stockStatus(ProductModel product) {
    final int stock = product.stock ?? 0;
    final int threshold = product.threshold ?? 5;

    if (stock == 0) {
      return {
        'label': 'Critical',
        'color': const Color(0xffEF5350),
        'bgColor': const Color(0xFFFCE4EC),
      };
    } else if (stock <= threshold) {
      return {
        'label': 'Low Stock',
        'color': const Color(0xffFFA726),
        'bgColor': const Color(0xFFFFF3CD),
      };
    } else {
      return {
        'label': 'OK',
        'color': const Color(0xff66BB6A),
        'bgColor': const Color(0xFFE8F5E9),
      };
    }
  }

  // Filtered products
  List<ProductModel> get _filteredProducts {
    List<ProductModel> result = allProducts;

    // Search
    if (_searchController.text.isNotEmpty) {
      result = result.where((p) {
        return (p.name ?? '')
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Filter by stock status
    if (_selectedFilter == 'Low Stock') {
      result = result.where((p) {
        final stock = p.stock ?? 0;
        final threshold = p.threshold ?? 5;
        return stock > 0 && stock <= threshold;
      }).toList();
    } else if (_selectedFilter == 'Critical') {
      result = result.where((p) => (p.stock ?? 0) == 0).toList();
    } else if (_selectedFilter == 'OK') {
      result = result.where((p) {
        final stock = p.stock ?? 0;
        final threshold = p.threshold ?? 5;
        return stock > threshold;
      }).toList();
    }

    return result;
  }

  // Low stock count
  int get _lowStockCount => allProducts.where((p) {
        final stock = p.stock ?? 0;
        final threshold = p.threshold ?? 5;
        return stock > 0 && stock <= threshold;
      }).length;

  // Critical count
  int get _criticalCount =>
      allProducts.where((p) => (p.stock ?? 0) == 0).length;

  // Show set/edit threshold bottom sheet
  void _showThresholdSheet(ProductModel product) {
    final TextEditingController thresholdController =
        TextEditingController(text: (product.threshold ?? 5).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Set Stock Threshold',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name ?? '',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xffD08C4A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Current stock info box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    label: 'Current Stock',
                    value: '${product.stock ?? 0}',
                    color: const Color(0xff5E1D04),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xffD08C4A).withOpacity(0.3),
                  ),
                  _InfoChip(
                    label: 'Current Threshold',
                    value: '${product.threshold ?? 5}',
                    color: const Color(0xffD08C4A),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Threshold input
            Text(
              'New Threshold Quantity',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: thresholdController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. 10',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: const Icon(
                  Icons.warning_amber_outlined,
                  color: Color(0xffD08C4A),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xffD08C4A)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive an alert when stock reaches this level.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final int? newThreshold =
                      int.tryParse(thresholdController.text);
                  if (newThreshold == null || newThreshold < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a valid number',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  try {
                    isLoading = true;
                    setState(() {});

                    // ✅ Save threshold to Firebase
                    await _thresholdService.setThreshold(
                      productId: product.docId!,
                      threshold: newThreshold,
                    );

                    await loadProducts();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Threshold updated for ${product.name}',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        backgroundColor: const Color(0xffD08C4A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } catch (e) {
                    isLoading = false;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Threshold',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5E1D04),
            size: 20,
          ),
        ),
        title: Text(
          'Stock Threshold',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffD08C4A)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      // ── Alert Banner
                      if (_lowStockCount > 0 || _criticalCount > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  Icons.notifications_active_outlined,
                                  color: Colors.red.shade400,
                                  size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red.shade400,
                                    ),
                                    children: [
                                      if (_criticalCount > 0)
                                        TextSpan(
                                          text:
                                              '$_criticalCount product(s) out of stock. ',
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                      if (_lowStockCount > 0)
                                        TextSpan(
                                          text:
                                              '$_lowStockCount product(s) below threshold.',
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xffD08C4A),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEEEEEE)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xffD08C4A)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Filter Chips
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected =
                                _selectedFilter == filter;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedFilter = filter),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xffD08C4A)
                                      : const Color(0xFFF9F9F9),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xffD08C4A)
                                        : const Color(0xFFEEEEEE),
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Count
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_filteredProducts.length} Products',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // ── Products Threshold List
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 60,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'No products found',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xffD08C4A),
                          onRefresh: loadProducts,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                20, 0, 20, 20),
                            itemCount: _filteredProducts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _ThresholdTile(
                                product: product,
                                stockStatus: _stockStatus(product),
                                onSetThreshold: () =>
                                    _showThresholdSheet(product),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ── Threshold Tile
class _ThresholdTile extends StatelessWidget {
  final ProductModel product;
  final Map<String, dynamic> stockStatus;
  final VoidCallback onSetThreshold;

  const _ThresholdTile({
    required this.product,
    required this.stockStatus,
    required this.onSetThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final int stock = product.stock ?? 0;
    final int threshold = product.threshold ?? 5;

    // Stock bar percentage — capped at 100%
    final double stockRatio =
        threshold == 0 ? 1.0 : (stock / (threshold * 3)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row
          Row(
            children: [
              // Product icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: stockStatus['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: product.imageUrl != null &&
                        product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.local_florist_outlined,
                            color: stockStatus['color'] as Color,
                            size: 22,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.local_florist_outlined,
                        color: stockStatus['color'] as Color,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                    Text(
                      product.category ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stockStatus['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stockStatus['label'],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: stockStatus['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stock Progress Bar
          Row(
            children: [
              Text(
                'Stock: $stock',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff5E1D04),
                ),
              ),
              const Spacer(),
              Text(
                'Threshold: $threshold',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stockRatio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                stockStatus['color'] as Color,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Set Threshold Button
          GestureDetector(
            onTap: onSetThreshold,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: Color(0xffD08C4A),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Set Threshold',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffD08C4A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Chip
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
