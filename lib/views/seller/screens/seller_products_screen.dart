import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_add_product_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_edit_product_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_product_detail.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';

class SellerProductsScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerProductsScreen({super.key, required this.seller});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  bool _isCategoriesLoading = true;
  List<ProductModel> _allProducts = [];

  // Filtering states
  String _selectedStockFilter = 'All';
  String _selectedCategoryFilter = 'All';

  final List<String> _stockFilters = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  List<CategoryModel> _dbCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeScreenData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Joint initialization routine logic
  Future<void> _initializeScreenData() async {
    await Future.wait([
      loadProducts(),
      _fetchLiveCategories(),
    ]);
  }

  // ── Load products from Firebase
  Future<void> loadProducts() async {
    try {
      setState(() => isLoading = true);
      String sellerId = widget.seller.docId ?? '';
      _allProducts = await _productService.getSellerProducts(sellerId);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red.shade400);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Fetch production categories from the database setup
  Future<void> _fetchLiveCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      if (mounted) {
        setState(() {
          _dbCategories = categories;
          _isCategoriesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCategoriesLoading = false);
      _showSnackBar("Failed to sync category listings: $e", Colors.red.shade400);
    }
  }

  // ── Delete product from Firebase
  Future<void> _deleteProduct(String docId, String name) async {
    try {
      await _productService.deleteProduct(docId);
      await loadProducts();
      _showSnackBar('"$name" deleted successfully', Colors.green.shade600);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red.shade400);
    }
  }

  // ── Filtered products calculation pipeline
  List<ProductModel> get _filteredProducts {
    List<ProductModel> result = _allProducts;

    // 1. Text Search Filter
    if (_searchController.text.isNotEmpty) {
      result = result.where((p) {
        return (p.name ?? '')
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // 2. Static Stock Status Filter
    if (_selectedStockFilter == 'In Stock') {
      result = result.where((p) => !p.isLowStock && (p.stock ?? 0) > 0).toList();
    } else if (_selectedStockFilter == 'Low Stock') {
      result = result.where((p) => p.isLowStock && (p.stock ?? 0) > 0).toList();
    } else if (_selectedStockFilter == 'Out of Stock') {
      result = result.where((p) => (p.stock ?? 0) == 0).toList();
    }

    // 3. Dynamic Category Model Filter Match
    if (_selectedCategoryFilter != 'All') {
      result = result.where((p) => p.category == _selectedCategoryFilter).toList();
    }

    return result;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Delete dialog
  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Product',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product.docId ?? '', product.name ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xffD08C4A), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xffD08C4A))),
                ),
              ),
              const SizedBox(height: 12),

              // ── Inventory Stock State Filtering Chips
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stockFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _stockFilters[index];
                    final isSelected = _selectedStockFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStockFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xffD08C4A) : const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xffD08C4A) : const Color(0xFFEEEEEE),
                          ),
                        ),
                        child: Text(filter,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.grey.shade600)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // ── Real-time Database Category Filtering Row
              _isCategoriesLoading
                  ? const SizedBox(height: 32, child: Center(child: LinearProgressIndicator(color: Color(0xffD08C4A))))
                  : _dbCategories.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dbCategories.length + 1,
                  itemBuilder: (context, index) {
                    final String categoryName = index == 0 ? 'All' : _dbCategories[index - 1].categoryName;
                    final bool isSelected = _selectedCategoryFilter == categoryName;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryFilter = categoryName),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xff5E1D04) : const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xff5E1D04) : const Color(0xFFEEEEEE),
                          ),
                        ),
                        child: Text(
                          index == 0 ? 'All Categories' : categoryName,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xff5E1D04)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // ── Dynamic Summary Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_filteredProducts.length} Products Found',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04))),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SellerAddProductScreen(seller: widget.seller),
                        ),
                      );
                      _initializeScreenData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xffD08C4A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('Add Product',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Products Core Listing Area
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
              : _filteredProducts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No products match these criteria',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
              ],
            ),
          )
              : RefreshIndicator(
            color: const Color(0xffD08C4A),
            onRefresh: _initializeScreenData,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _ProductTile(
                  product: product,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerEditProductScreen(
                          product: product,
                          seller: widget.seller,
                        ),
                      ),
                    );
                    _initializeScreenData();
                  },
                  onDelete: () => _showDeleteDialog(context, product),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerProductDetailsScreen(
                            product: product,
                          seller: widget.seller,
                        ),
                      ),
                    );
                    _initializeScreenData();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Product Tile Subcomponent Component Layout
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  Map<String, dynamic> _stockStatus() {
    final int stock = product.stock ?? 0;
    if (stock == 0) {
      return {'label': 'Out of Stock', 'color': const Color(0xffEF5350)};
    } else if (product.isLowStock) {
      return {'label': 'Low Stock', 'color': const Color(0xffFFA726)};
    } else {
      return {'label': 'In Stock', 'color': const Color(0xff66BB6A)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockStatus = _stockStatus();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            // ── Product Image Frame
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.local_florist_outlined,
                      color: Color(0xffD08C4A), size: 30),
                ),
              )
                  : const Icon(Icons.local_florist_outlined, color: Color(0xffD08C4A), size: 30),
            ),
            const SizedBox(width: 12),

            // ── Product Metadata Core Container
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(product.name ?? '',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff5E1D04)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (stockStatus['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(stockStatus['label'],
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: stockStatus['color'])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Category & Brand Metrics tags
                  Text(
                    '${product.category ?? 'Unassigned'} • ${product.brand ?? ''}',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),

                  // Multi-size variations list chips
                  if (product.sizes != null && product.sizes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: product.sizes!.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${s['size']} - Rs ${s['price']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff5E1D04)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Performance KPIs and contextual controls
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text('${product.stock ?? 0} left',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                      const SizedBox(width: 10),
                      const Icon(Icons.star, size: 12, color: Color(0xffD08C4A)),
                      const SizedBox(width: 3),
                      Text('${product.rating ?? 0.0}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                      const Spacer(),

                      // Edit Command Link Button
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Edit',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xffD08C4A))),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Delete Command Link Button
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Delete',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade400)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}