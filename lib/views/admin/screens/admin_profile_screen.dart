import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_perfume_app_fyp/models/admin_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/services/cloudinary_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/section_title.dart';
import '../auth/admin_change_password_screen.dart';
import '../auth/admin_login_screen.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final AdminService _adminService = AdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker(); // For picking image

  bool _isEditing = false;
  bool isLoading = false;
  bool isSaving = false;
  bool _isUploadingImage = false; // Show loader while uploading
  AdminModel? _admin;
  String? _profileImageUrl; // Store Cloudinary URL

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAdminProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Load admin profile from Firebase
  Future<void> loadAdminProfile() async {
    try {
      isLoading = true;
      setState(() {});

      _admin = await _adminService.getCurrentAdmin();

      _nameController.text = _admin?.name ?? '';
      _emailController.text = _admin?.email ?? '';
      _phoneController.text = _admin?.phone ?? '';
      _profileImageUrl = _admin?.profileImage; // Load existing image URL

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
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

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    // If cancelling edit — reset controllers to original values
    if (!_isEditing) {
      _nameController.text = _admin?.name ?? '';
      _emailController.text = _admin?.email ?? '';
      _phoneController.text = _admin?.phone ?? '';
      _profileImageUrl = _admin?.profileImage; // Revert image
    }
  }

  // ── Pick image from gallery and upload to Cloudinary
  Future<void> _uploadProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress to reduce size
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      // Upload to Cloudinary using your service
      final String? imageUrl = await CloudinaryService.uploadImage(
          File(pickedFile.path)
      );

      if (imageUrl != null) {
        setState(() => _profileImageUrl = imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image uploaded!'), backgroundColor: Colors.green),
        );
      } else {
        throw 'Upload failed';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  // ── Save profile to Firebase (includes image URL)
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Name cannot be empty', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    try {
      isSaving = true;
      setState(() {});

      final uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) throw "Admin UID not found";

      await _adminService.updateAdminProfile(
        adminId: uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        profileImage: _profileImageUrl, // 👈 Pass the uploaded URL
      );

      // Refresh local data
      await loadAdminProfile();

      isSaving = false;
      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      isSaving = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await _auth.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                        (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
                    backgroundColor: Colors.red.shade400,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD08C4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Logout', style: GoogleFonts.poppins(color: const Color(0xff5E1D04), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xff5E1D04)),
        ),
        title: Text('Admin Profile', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _toggleEdit,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                _isEditing ? Icons.close : Icons.edit_outlined,
                color: const Color(0xffD08C4A),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Profile Avatar (with image support)
            Center(
              child: Stack(
                children: [
                  // Avatar: show uploaded image if available, else text avatar
                  if (_profileImageUrl != null)
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage(_profileImageUrl!),
                      backgroundColor: const Color(0xffD08C4A),
                    )
                  else
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xffD08C4A),
                      child: Text(
                        (_admin?.name ?? 'A')[0].toUpperCase(),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Camera icon (only in edit mode)
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _uploadProfileImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xff5E1D04),
                            shape: BoxShape.circle,
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Name + Role Badge
            Center(
              child: Column(
                children: [
                  Text(
                    _admin?.name ?? 'Admin',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Administrator',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Profile Info Section
            const SectionTitle(title: 'Profile Info'),
            const SizedBox(height: 12),

            // View Mode
            if (!_isEditing) ...[
              _InfoTile(icon: Icons.person_outline, label: 'Name', value: _admin?.name ?? '—'),
              _InfoTile(icon: Icons.email_outlined, label: 'Email', value: _admin?.email ?? '—'),
              _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: _admin?.phone ?? '—'),
              _InfoTile(icon: Icons.badge_outlined, label: 'Role', value: _admin?.role ?? 'admin'),
            ],

            // Edit Mode
            if (_isEditing) ...[
              AuthTextField(
                label: 'Name',
                hint: 'Enter your name',
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Email (Read Only)',
                hint: 'Email cannot be changed',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // make it read-only
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Phone',
                hint: 'Enter your phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              isSaving
                  ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
                  : AuthButton(
                label: 'Save Changes',
                onPressed: _saveProfile,
              ),
            ],
            const SizedBox(height: 28),

            // ── Account Settings
            const SectionTitle(title: 'Account Settings'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminChangePasswordScreen()),
              ),
            ),
            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.logout,
              label: 'Logout',
              textColor: const Color(0xFF721C24),
              iconColor: const Color(0xFF721C24),
              onTap: _showLogoutDialog,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ── Info Tile (unchanged, keep as is)
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffD08C4A), size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// ── Settings Tile (unchanged)
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.textColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xffD08C4A), size: 20),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor ?? const Color(0xff5E1D04))),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: textColor ?? Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}