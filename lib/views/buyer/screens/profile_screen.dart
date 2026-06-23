import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploading = false;
  UserModel? _userData;
  File? _pickedImage;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  int _totalOrders = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _userData = user;
        _nameController.text = user.name ?? '';
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
      });
      await _loadOrderCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadOrderCount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: userId)
          .get();
      setState(() => _totalOrders = ordersSnapshot.docs.length);
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 600);
      if (picked != null) setState(() => _pickedImage = File(picked.path));
    } catch (e) {
      _showError('Could not pick image: $e');
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Update Profile Photo', style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        const Icon(Icons.camera_alt_outlined, color: Color(0xffD08C4A), size: 30),
                        const SizedBox(height: 8),
                        Text('Camera', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        const Icon(Icons.photo_library_outlined, color: Color(0xff42A5F5), size: 30),
                        const SizedBox(height: 8),
                        Text('Gallery', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
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

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return;
    }
    setState(() => _isLoading = true);

    String? uploadedImageUrl;
    if (_pickedImage != null) {
      setState(() => _isUploading = true);
      uploadedImageUrl = await CloudinaryService.uploadImage(_pickedImage!);
      setState(() => _isUploading = false);
      if (uploadedImageUrl == null) _showError('Image upload failed. Profile saved without new photo.');
    }

    try {
      await _userService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        profileImageUrl: uploadedImageUrl ?? _userData?.profileImageUrl,
      );
      setState(() {
        _isLoading = false;
        _isEditing = false;
        _pickedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully'), backgroundColor: const Color(0xff66BB6A)),
      );
      await _loadData();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade400),
      );
    }
  }

  Widget _buildAvatar() {
    final String? imageUrl = _pickedImage != null
        ? null
        : (_userData?.profileImageUrl != null && _userData!.profileImageUrl!.isNotEmpty ? _userData!.profileImageUrl : null);
    final initials = (_userData?.name ?? 'U').isNotEmpty ? (_userData?.name ?? 'U')[0].toUpperCase() : 'U';

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xffD08C4A),
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : (imageUrl != null ? NetworkImage(imageUrl) as ImageProvider : null),
          child: (_pickedImage == null && imageUrl == null)
              ? Text(initials, style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))
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
                child: _isUploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please login to view your profile.'));
    }

    // ✅ Fixed: wrapped in Material to provide a Material ancestor for
    // TextField widgets, since this screen has no Scaffold of its own
    // (it's used as a tab body inside another screen's Scaffold).
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(child: _buildAvatar()),
            const SizedBox(height: 12),
            Text(_userData?.name ?? '', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
            Text(_userData?.email ?? '', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xffD08C4A), fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Orders', value: '$_totalOrders'),
                  _VerticalDivider(),
                  _StatItem(label: 'Wishlist', value: '0'), // fetch wishlist count if needed
                  _VerticalDivider(),
                  _StatItem(label: 'Member Since', value: _userData?.createdAt != null
                      ? '${DateTime.fromMillisecondsSinceEpoch(_userData!.createdAt!).day}/${DateTime.fromMillisecondsSinceEpoch(_userData!.createdAt!).month}/${DateTime.fromMillisecondsSinceEpoch(_userData!.createdAt!).year}'
                      : 'New'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Info Section
            _SectionTitle(title: 'Personal Information'),
            const SizedBox(height: 12),
            _ProfileField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline, isEditing: _isEditing),
            const SizedBox(height: 12),
            _ProfileField(
              label: 'Email Address',
              controller: TextEditingController(text: _userData?.email ?? ''),
              icon: Icons.email_outlined,
              isEditing: false,
              enabled: false,
            ),
            const SizedBox(height: 12),
            _ProfileField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, isEditing: _isEditing, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _ProfileField(label: 'Address', controller: _addressController, icon: Icons.location_on_outlined, isEditing: _isEditing),
            const SizedBox(height: 24),

            if (_isEditing) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Changes', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _isEditing = false;
                  _pickedImage = null;
                  _nameController.text = _userData?.name ?? '';
                  _phoneController.text = _userData?.phone ?? '';
                  _addressController.text = _userData?.address ?? '';
                }),
                child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
              ),
            ] else ...[
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit, color: Color(0xffD08C4A)),
                  label: Text('Edit Profile', style: GoogleFonts.poppins(color: const Color(0xffD08C4A))),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Reusable stat item (same as before)
class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500)),
    ]);
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: const Color(0xffD08C4A).withOpacity(0.3));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))));
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isEditing;
  final TextInputType keyboardType;
  final bool enabled;
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled && isEditing,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xff5E1D04)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 18),
            filled: true,
            fillColor: enabled && isEditing ? const Color(0xFFF9F9F9) : Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: enabled && isEditing ? const BorderSide(color: Color(0xFFEEEEEE)) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffD08C4A)),
            ),
          ),
        ),
      ],
    );
  }
}