import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';

class SellerProfileScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerProfileScreen({super.key, required this.seller});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing  = false;
  bool _isLoading  = false;
  String _selectedTab = 'Personal';

  // Profile image (local picked file — not uploaded yet)
  File? _pickedImage;

  // ── Personal Info Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cnicController;

  // ── Business Info Controllers
  late final TextEditingController _businessNameController;
  late final TextEditingController _businessAddressController;
  late final TextEditingController _businessTypeController;
  late final TextEditingController _shopTaglineController;
  late final TextEditingController _businessEmailController;
  late final TextEditingController _businessPhoneController;

  // ── Stats (loaded from Firestore)
  int _totalProducts = 0;
  int _totalOrders   = 0;
  int _totalRiders   = 0;

  @override
  void initState() {
    super.initState();

    // Pre-fill from widget.seller
    _nameController           = TextEditingController(text: widget.seller.name            ?? '');
    _emailController          = TextEditingController(text: widget.seller.email           ?? '');
    _phoneController          = TextEditingController(text: widget.seller.phone           ?? '');
    _addressController        = TextEditingController(text: widget.seller.address         ?? '');
    _cnicController           = TextEditingController(text: widget.seller.cnic            ?? '');
    _businessNameController   = TextEditingController(text: widget.seller.businessName    ?? '');
    _businessAddressController= TextEditingController(text: widget.seller.businessAddress ?? '');
    _businessTypeController   = TextEditingController(text: widget.seller.businessType    ?? '');
    _shopTaglineController    = TextEditingController(text: widget.seller.shopTagline     ?? '');
    _businessEmailController  = TextEditingController(text: widget.seller.businessEmail   ?? '');
    _businessPhoneController  = TextEditingController(text: widget.seller.businessPhone   ?? '');

    _loadStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cnicController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessTypeController.dispose();
    _shopTaglineController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    super.dispose();
  }

  // ── Load stats from Firestore
  Future<void> _loadStats() async {
    try {
      final sellerId = widget.seller.docId ?? '';

      final results = await Future.wait([
        _firestore
            .collection('products')
            .where('sellerId', isEqualTo: sellerId)
            .count()
            .get(),
        _firestore
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .count()
            .get(),
        _firestore
            .collection('riders')
            .where('sellerId', isEqualTo: sellerId)
            .count()
            .get(),
      ]);

      setState(() {
        _totalProducts = results[0].count ?? 0;
        _totalOrders   = results[1].count ?? 0;
        _totalRiders   = results[2].count ?? 0;
      });
    } catch (_) {
      // Stats failing silently is acceptable — not critical
    }
  }

  // ── Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not pick image: ${e.toString()}',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Show camera/gallery bottom sheet
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Update Profile Photo',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 20),
            Row(
              children: [
                // Camera
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        const Icon(Icons.camera_alt_outlined,
                            color: Color(0xffD08C4A), size: 30),
                        const SizedBox(height: 8),
                        Text('Camera',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff5E1D04))),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Gallery
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        const Icon(Icons.photo_library_outlined,
                            color: Color(0xff42A5F5), size: 30),
                        const SizedBox(height: 8),
                        Text('Gallery',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff5E1D04))),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Save changes to Firestore
  Future<void> _saveChanges() async {
    try {
      setState(() => _isLoading = true);

      final sellerId = widget.seller.docId ?? '';

      // TODO: When image URL API is connected:
      // 1. Upload _pickedImage to your image storage API
      // 2. Get back the URL string
      // 3. Add 'profileImageUrl': uploadedUrl to the update map below
      // String? uploadedUrl;
      // if (_pickedImage != null) {
      //   uploadedUrl = await YourImageService.upload(_pickedImage!);
      // }

      await _firestore.collection('sellers').doc(sellerId).update({
        'name':            _nameController.text.trim(),
        'email':           _emailController.text.trim(),
        'phone':           _phoneController.text.trim(),
        'address':         _addressController.text.trim(),
        'businessName':    _businessNameController.text.trim(),
        'businessAddress': _businessAddressController.text.trim(),
        'businessType':    _businessTypeController.text.trim(),
        'shopTagline':     _shopTaglineController.text.trim(),
        'businessEmail':   _businessEmailController.text.trim(),
        'businessPhone':   _businessPhoneController.text.trim(),
        'updatedAt':       DateTime.now().millisecondsSinceEpoch,
        // 'profileImageUrl': uploadedUrl ?? widget.seller.profileImageUrl ?? '',
      });

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xffD08C4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Avatar widget
  Widget _buildAvatar() {
    final initials = (widget.seller.name ?? 'S').isNotEmpty
        ? (widget.seller.name ?? 'S')[0].toUpperCase()
        : 'S';

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xffD08C4A),
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : (widget.seller.profileImageUrl ?? '').isNotEmpty
              ? NetworkImage(widget.seller.profileImageUrl!) as ImageProvider
              : null,
          child: (_pickedImage == null &&
              (widget.seller.profileImageUrl ?? '').isEmpty)
              ? Text(initials,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))
              : null,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xff5E1D04),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating = widget.seller.rating ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
        ),
        title: Text(
          _isEditing ? 'Edit Profile' : 'My Profile',
          style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04)),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _isLoading
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xffD08C4A), strokeWidth: 2))
                  : Text(
                _isEditing ? 'Save' : 'Edit',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffD08C4A)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Avatar
            Center(child: _buildAvatar()),
            const SizedBox(height: 12),

            // Name + business name
            Text(
              widget.seller.name ?? '',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04)),
            ),
            Text(
              widget.seller.businessName ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xffD08C4A),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            // Verified / Unverified badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (widget.seller.isVerified ?? false)
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (widget.seller.isVerified ?? false)
                        ? Icons.verified
                        : Icons.access_time_outlined,
                    color: (widget.seller.isVerified ?? false)
                        ? const Color(0xff66BB6A)
                        : const Color(0xffD08C4A),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    (widget.seller.isVerified ?? false)
                        ? 'Verified Seller'
                        : 'Pending Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: (widget.seller.isVerified ?? false)
                          ? const Color(0xff66BB6A)
                          : const Color(0xffD08C4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats row — live from Firestore
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Products', value: '$_totalProducts'),
                  _VerticalDivider(),
                  _StatItem(label: 'Orders',   value: '$_totalOrders'),
                  _VerticalDivider(),
                  _StatItem(label: 'Rating',   value: rating.toStringAsFixed(1)),
                  _VerticalDivider(),
                  _StatItem(label: 'Riders',   value: '$_totalRiders'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE))),
              child: Row(
                children: ['Personal', 'Business'].map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffD08C4A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(tab,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade500)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Personal Tab
            if (_selectedTab == 'Personal') ...[
              _SectionTitle(title: 'Personal Information'),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  isEditing: _isEditing),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Email Address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Address',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  isEditing: _isEditing),
              const SizedBox(height: 12),
              // CNIC — always read only
              _ProfileField(
                  label: 'CNIC',
                  controller: _cnicController,
                  icon: Icons.credit_card_outlined,
                  isEditing: false),
            ],

            // ── Business Tab
            if (_selectedTab == 'Business') ...[
              _SectionTitle(title: 'Business Information'),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Business Name',
                  controller: _businessNameController,
                  icon: Icons.storefront_outlined,
                  isEditing: _isEditing),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Business Address',
                  controller: _businessAddressController,
                  icon: Icons.location_city_outlined,
                  isEditing: _isEditing),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Business Type',
                  controller: _businessTypeController,
                  icon: Icons.category_outlined,
                  isEditing: _isEditing),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Store Tagline',
                  controller: _shopTaglineController,
                  icon: Icons.format_quote_outlined,
                  isEditing: _isEditing),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Support Email',
                  controller: _businessEmailController,
                  icon: Icons.email_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _ProfileField(
                  label: 'Business Phone',
                  controller: _businessPhoneController,
                  icon: Icons.phone_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.phone),
            ],

            const SizedBox(height: 24),

            // Save button
            if (_isEditing) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD08C4A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0),
                  child: _isLoading
                      ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text('Save Changes',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _isEditing   = false;
                  _pickedImage = null;
                  // Reset controllers to original values
                  _nameController.text            = widget.seller.name            ?? '';
                  _emailController.text           = widget.seller.email           ?? '';
                  _phoneController.text           = widget.seller.phone           ?? '';
                  _addressController.text         = widget.seller.address         ?? '';
                  _businessNameController.text    = widget.seller.businessName    ?? '';
                  _businessAddressController.text = widget.seller.businessAddress ?? '';
                  _businessTypeController.text    = widget.seller.businessType    ?? '';
                  _shopTaglineController.text     = widget.seller.shopTagline     ?? '';
                  _businessEmailController.text   = widget.seller.businessEmail   ?? '';
                  _businessPhoneController.text   = widget.seller.businessPhone   ?? '';
                }),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey.shade500)),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Stat Item
class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04))),
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10, color: Colors.grey.shade500)),
    ]);
  }
}

// ── Vertical Divider
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 30,
        color: const Color(0xffD08C4A).withOpacity(0.3));
  }
}

// ── Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04))),
    );
  }
}

// ── Profile Field
class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isEditing;
  final TextInputType keyboardType;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isEditing,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
              fontSize: 13, color: const Color(0xff5E1D04)),
          decoration: InputDecoration(
            prefixIcon:
            Icon(icon, color: const Color(0xffD08C4A), size: 18),
            filled: true,
            fillColor:
            isEditing ? const Color(0xFFF9F9F9) : Colors.transparent,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: isEditing
                    ? const BorderSide(color: Color(0xFFEEEEEE))
                    : BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffD08C4A))),
          ),
        ),
      ],
    );
  }
}