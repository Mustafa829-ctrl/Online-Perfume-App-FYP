import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/rider_model.dart';
import '../../../services/rider_auth_service.dart';
import '../../../services/cloudinary_service.dart';

class RiderProfileScreen extends StatefulWidget {
  final RiderModel rider;
  const RiderProfileScreen({super.key, required this.rider});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  final RiderAuthServices _authServices = RiderAuthServices();
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  bool isLoading = false;
  bool _isUploadingImage = false;
  String? _profileImageUrl;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rider.name ?? '');
    _phoneController = TextEditingController(text: widget.rider.phone ?? '');
    _addressController = TextEditingController(text: widget.rider.address ?? '');
    _vehicleModelController = TextEditingController(text: widget.rider.vehicleModel ?? '');
    _vehicleNumberController = TextEditingController(text: widget.rider.vehicleNumber ?? '');
    _licenseController = TextEditingController(text: widget.rider.licenseNumber ?? '');
    _profileImageUrl = widget.rider.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    _licenseController.dispose();
    super.dispose();
  }


  //  Upload profile image to Cloudinary & save URL to Firestore

  Future<void> _uploadProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    final String? imageUrl = await CloudinaryService.uploadImage(File(pickedFile.path));

    setState(() => _isUploadingImage = false);

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed', style: GoogleFonts.poppins(fontSize: 13))),
      );
      return;
    }

    // Save URL to Firestore
    await _authServices.updateRiderProfile(
      uid: widget.rider.docId!,
      data: {'profileImage': imageUrl},
    );

    setState(() => _profileImageUrl = imageUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile picture updated!', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: const Color(0xffD08C4A),
      ),
    );
  }


  //  Save all profile changes (including image URL)

  Future<void> _saveChanges() async {
    try {
      isLoading = true;
      setState(() {});

      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehicleNumber': _vehicleNumberController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        if (_profileImageUrl != null) 'profileImage': _profileImageUrl,
      };

      await _authServices.updateRiderProfile(
        uid: widget.rider.docId!,
        data: updateData,
      );

      isLoading = false;
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xffD08C4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      isLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var rider = widget.rider;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // ── Avatar + Name (updated)
          _ProfileHeader(
            name: rider.name ?? 'Rider',
            vehicleModel: rider.vehicleModel ?? '',
            vehicleNumber: rider.vehicleNumber ?? '',
            status: rider.status ?? 'active',
            isEditing: _isEditing,
            isUploading: _isUploadingImage,
            profileImage: _profileImageUrl,
            onCameraTap: _uploadProfileImage,
          ),
          const SizedBox(height: 20),

          // ── Edit / Save button (unchanged)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isEditing)
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: Text('Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13)),
                ),
              GestureDetector(
                onTap: _isEditing
                    ? (isLoading ? null : _saveChanges)
                    : () => setState(() => _isEditing = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isEditing ? const Color(0xffD08C4A) : const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isLoading
                      ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                    _isEditing ? 'Save Changes' : 'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isEditing ? Colors.white : const Color(0xffD08C4A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Personal Info (unchanged)
          _SectionTitle(title: 'Personal Information'),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_outline,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 10),
          _ProfileField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            isEditing: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          _ProfileField(
            label: 'Address',
            controller: _addressController,
            icon: Icons.location_on_outlined,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 20),

          // ── Vehicle Info
          _SectionTitle(title: 'Vehicle Information'),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'Vehicle Model',
            controller: _vehicleModelController,
            icon: Icons.two_wheeler_outlined,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 10),
          _ProfileField(
            label: 'Vehicle Number',
            controller: _vehicleNumberController,
            icon: Icons.confirmation_number_outlined,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 10),
          _ProfileField(
            label: 'License Number',
            controller: _licenseController,
            icon: Icons.badge_outlined,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 20),

          // ── Read only info
          _SectionTitle(title: 'Account Information'),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Email',
            value: rider.email ?? '',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 10),
          _ReadOnlyField(
            label: 'CNIC',
            value: rider.cnic ?? '',
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 10),
          _ReadOnlyField(
            label: 'Rider ID',
            value: rider.riderId ?? '',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String vehicleModel;
  final String vehicleNumber;
  final String status;
  final bool isEditing;
  final bool isUploading;
  final String? profileImage;
  final VoidCallback onCameraTap;

  const _ProfileHeader({
    required this.name,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.status,
    required this.isEditing,
    required this.isUploading,
    required this.profileImage,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Avatar: show network image if available, else text fallback
            CircleAvatar(
              radius: 46,
              backgroundColor: const Color(0xffD08C4A),
              child: profileImage != null
                  ? ClipOval(
                child: Image.network(
                  profileImage!,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'R',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            // Camera icon (only in edit mode)
            if (isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isUploading ? null : onCameraTap,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xff5E1D04),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: isUploading
                        ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(name,
            style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        Text('$vehicleModel • $vehicleNumber',
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xffD08C4A), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'active' ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status == 'active' ? ' Active' : ' Inactive',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status == 'active' ? const Color(0xff66BB6A) : const Color(0xffEF5350),
            ),
          ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: GoogleFonts.playfairDisplay(
              fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
    );
  }
}

// ── Editable Profile Field (unchanged)
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
                fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isEditing,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xff5E1D04)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 18),
            filled: true,
            fillColor: isEditing ? const Color(0xFFF9F9F9) : Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: isEditing ? const BorderSide(color: Color(0xFFEEEEEE)) : BorderSide.none,
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

// ── Read Only Field (unchanged)
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 18),
              const SizedBox(width: 10),
              Text(value,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}