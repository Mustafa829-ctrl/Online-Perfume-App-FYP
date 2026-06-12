import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../../services/cloudinary_service.dart';

class SellerAddCategoryScreen extends StatefulWidget {
  const SellerAddCategoryScreen({super.key});

  @override
  State<SellerAddCategoryScreen> createState() => _SellerAddCategoryScreenState();
}

class _SellerAddCategoryScreenState extends State<SellerAddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  File? _selectedImage;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _categoryNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Pick an image using image_picker (no longer required)
  Future<void> _pickCategoryImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // Upload image to Cloudinary (returns URL or null if no image)
  Future<String?> _uploadImageIfSelected() async {
    if (_selectedImage == null) return null;

    setState(() => _isUploadingImage = true);
    final String? imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
    setState(() => _isUploadingImage = false);

    if (imageUrl == null) {
      _showSnackBar("Image upload failed. Category will be saved without image.", isError: true);
    }
    return imageUrl;
  }

  // Save workflow (image optional)
  Future<void> _saveCategoryToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    // ❌ Removed the forced image check – now optional

    setState(() => _isSaving = true);

    try {
      // 1. Upload image to Cloudinary (only if selected)
      String? uploadedUrl = await _uploadImageIfSelected();

      // 2. Generate a fresh document ID
      String newDocId = FirebaseFirestore.instance.collection('categories').doc().id;

      // 3. Build CategoryModel (imageUrl can be null)
      CategoryModel newCategory = CategoryModel(
        docId: newDocId,
        categoryName: _categoryNameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: uploadedUrl,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // 4. Save to Firestore
      await _categoryService.createCategory(newCategory);

      _showSnackBar("Category added successfully!", isError: false);

      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      _showSnackBar("Failed to save category: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff5E1D04)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Category",
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSaving
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xffD08C4A)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Banner Image (optional)
              Text(
                "Category Banner Image (Optional)",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E1D04),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickCategoryImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xffD08C4A).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: _selectedImage != null
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                      // Remove image button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      if (_isUploadingImage)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
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
                        "Tap to upload media from gallery",
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
              const SizedBox(height: 24),

              // Category Title Name (required)
              Text(
                "Category Title Name *",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E1D04),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryNameController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _inputDecoration("Enter category name (e.g., Woody, Floral)"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please input a valid category title name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description (optional)
              Text(
                "Description (Optional)",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E1D04),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(fontSize: 14),
                maxLines: 3,
                decoration: _inputDecoration("Enter a brief description for this scent segment"),
              ),
              const SizedBox(height: 35),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveCategoryToFirestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isUploadingImage
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xff5E1D04),
                    ),
                  )
                      : Text(
                    "Save Category",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xff5E1D04),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffD08C4A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }
}