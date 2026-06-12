import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../../services/cloudinary_service.dart';

class SellerEditProductScreen extends StatefulWidget {
  final ProductModel product;
  final SellerModel seller;
  const SellerEditProductScreen({
    super.key,
    required this.product,
    required this.seller,
  });

  @override
  State<SellerEditProductScreen> createState() => _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
  // Services
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  // State
  bool isLoading = false;
  bool _isCategoriesLoading = true;
  File? _selectedImage;             // new image picked by user
  bool _isUploadingImage = false;

  // Editable fields (image URL now handled via picker)
  late String? _currentImageUrl;    // original or newly uploaded
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;

  // Dynamic Categories
  List<CategoryModel> _dbCategories = [];
  String? _selectedCategoryName;

  // Editable sizes
  late List<Map<String, dynamic>> _sizes;

  // Controllers for new size
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _sizePriceController = TextEditingController();
  final TextEditingController _sizeStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _currentImageUrl = widget.product.imageUrl;
    _descriptionController = TextEditingController(
        text: widget.product.description ?? '');
    _discountController = TextEditingController(
        text: widget.product.discount == 0
            ? ''
            : widget.product.discount?.toStringAsFixed(0) ?? '');

    // Deep copy sizes
    _sizes = widget.product.sizes != null
        ? widget.product.sizes!
        .map((s) => Map<String, dynamic>.from(s))
        .toList()
        : [];

    _selectedCategoryName = widget.product.category;
    _fetchLiveCategories();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _discountController.dispose();
    _sizeController.dispose();
    _sizePriceController.dispose();
    _sizeStockController.dispose();
    super.dispose();
  }

  /// Fetch categories from Firestore
  Future<void> _fetchLiveCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _dbCategories = categories;
        // Ensure current category still exists
        bool containsCurrent = _dbCategories.any(
                (element) => element.categoryName == widget.product.category);
        if (!containsCurrent && _dbCategories.isNotEmpty) {
          _selectedCategoryName = _dbCategories.first.categoryName;
        }
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
      _showError("Failed to fetch categories: $e");
    }
  }


  //  Image picker & Cloudinary upload
  Future<void> _pickProductImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;   // remove both local and existing
    });
  }

  Future<String?> _uploadNewImageIfSelected() async {
    if (_selectedImage == null) return null;
    setState(() => _isUploadingImage = true);
    final String? url = await CloudinaryService.uploadImage(_selectedImage!);
    setState(() => _isUploadingImage = false);
    if (url == null) {
      _showError("Image upload failed. Old image will be kept.");
    }
    return url;
  }


  //  Size helpers

  int get _totalStock =>
      _sizes.fold(0, (sum, s) => sum + ((s['stock'] as int?) ?? 0));

  double get _basePrice {
    if (_sizes.isEmpty) return widget.product.price ?? 0.0;
    return _sizes
        .map((s) => (s['price'] as double?) ?? 0.0)
        .reduce((a, b) => a < b ? a : b);
  }

  void _addSize() {
    if (_sizeController.text.isEmpty ||
        _sizePriceController.text.isEmpty ||
        _sizeStockController.text.isEmpty) return;

    final double? price = double.tryParse(_sizePriceController.text);
    final int? stock = int.tryParse(_sizeStockController.text);
    if (price == null || stock == null) return;

    setState(() {
      _sizes.add({
        'size': _sizeController.text.trim(),
        'price': price,
        'stock': stock,
      });
      _sizeController.clear();
      _sizePriceController.clear();
      _sizeStockController.clear();
    });
  }

  void _removeSize(int index) {
    setState(() => _sizes.removeAt(index));
  }

  void _showEditStockDialog(int index) {
    final TextEditingController stockController =
    TextEditingController(text: _sizes[index]['stock'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Stock — ${_sizes[index]['size']}',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
        ),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter new stock quantity',
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              final int? newStock = int.tryParse(stockController.text);
              if (newStock == null) return;
              Navigator.pop(context);
              setState(() => _sizes[index]['stock'] = newStock);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD08C4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Update',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }


  //  Save changes (including optional new image)

  Future<void> _saveChanges() async {
    if (_descriptionController.text.isEmpty) {
      _showError('Please enter product description');
      return;
    }
    if (_selectedCategoryName == null) {
      _showError('Please choose a valid product category');
      return;
    }
    if (_sizes.isEmpty) {
      _showError('Please add at least one size');
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Upload new image if selected (otherwise keep old)
      String? finalImageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        final String? newUrl = await _uploadNewImageIfSelected();
        if (newUrl != null) finalImageUrl = newUrl;
      }

      // 2. Parse discount
      final double? discount = double.tryParse(_discountController.text);

      // 3. Update product in Firestore
      await _productService.updateProduct(
        widget.product.docId!,
        {
          if (finalImageUrl != null) 'imageUrl': finalImageUrl,
          'description': _descriptionController.text.trim(),
          'category': _selectedCategoryName!,
          'discount': discount ?? 0.0,
          'sizes': _sizes,
          'price': _basePrice,
          'stock': _totalStock,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully', style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: const Color(0xff66BB6A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          child: const Icon(Icons.arrow_back_ios, color: Color(0xff5E1D04), size: 20),
        ),
        title: Text(
          'Edit Product',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Read-only Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Info (Read Only)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ReadOnlyRow(label: 'Product Name', value: widget.product.name ?? ''),
                  const SizedBox(height: 6),
                  _ReadOnlyRow(label: 'Product ID', value: widget.product.docId ?? ''),
                  const SizedBox(height: 6),
                  _ReadOnlyRow(label: 'Brand', value: widget.product.brand ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Category Dropdown
            _SectionTitle(title: 'Category'),
            const SizedBox(height: 8),
            _isCategoriesLoading
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(child: LinearProgressIndicator(color: Color(0xffD08C4A))),
            )
                : _dbCategories.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No active categories found.",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade400),
              ),
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategoryName,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffD08C4A)),
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xff5E1D04)),
                  items: _dbCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.categoryName,
                      child: Text(cat.categoryName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategoryName = value),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Product Image (Optional) – replaces URL text field
            _SectionTitle(title: 'Product Image (Optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickProductImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xffD08C4A).withOpacity(0.5), width: 1.5),
                ),
                child: (_selectedImage != null)
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    if (_isUploadingImage)
                      Container(
                        color: Colors.black54,
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                  ],
                )
                    : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(_currentImageUrl!, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 44, color: Color(0xffD08C4A)),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to upload new image",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "(Optional)",
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description
            _SectionTitle(title: 'Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe your product...',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
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
            const SizedBox(height: 16),

            // ── Discount
            _SectionTitle(title: 'Discount % (Optional)'),
            const SizedBox(height: 8),
            _InputField(
              controller: _discountController,
              hint: 'e.g. 10 (for 10%)',
              icon: Icons.discount_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // ── Sizes & Stock Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: 'Sizes & Stock'),
                Text(
                  'Total Stock: $_totalStock',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffD08C4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Existing sizes with edit/remove
            if (_sizes.isNotEmpty)
              Column(
                children: _sizes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xffD08C4A).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten_outlined, size: 16, color: Color(0xffD08C4A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${s['size']}  •  Rs ${s['price']}  •  ${s['stock']} units',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff5E1D04),
                            ),
                          ),
                        ),
                        // Edit stock
                        GestureDetector(
                          onTap: () => _showEditStockDialog(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Edit Stock',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff42A5F5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Remove size
                        GestureDetector(
                          onTap: () => _removeSize(i),
                          child: const Icon(Icons.close, size: 16, color: Color(0xffEF5350)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),

            // Add new size row
            Text(
              'Add New Size',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(flex: 3, child: _InputField(controller: _sizeController, hint: '100ml', icon: Icons.straighten_outlined)),
                const SizedBox(width: 8),
                Expanded(flex: 3, child: _InputField(controller: _sizePriceController, hint: 'Price', icon: Icons.payments_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: _InputField(controller: _sizeStockController, hint: 'Qty', icon: Icons.inventory_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addSize,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xffD08C4A), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ── Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isUploadingImage || isLoading) ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5E1D04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isUploadingImage
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Save Changes', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Read Only Row (unchanged)
class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
        ),
        Expanded(
          child: Text(value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff5E1D04))),
        ),
      ],
    );
  }
}

// ── Section Title (unchanged)
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)),
    );
  }
}

// ── Input Field (unchanged, kept for discount and size fields)
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffD08C4A))),
      ),
    );
  }
}