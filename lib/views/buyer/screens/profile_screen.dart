import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _isUploading = false;
  String? _profileImageUrl;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  User? get _user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Pick and upload profile image
  Future<void> _uploadProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final String? imageUrl = await CloudinaryService.uploadImage(File(pickedFile.path));

    setState(() => _isUploading = false);

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
      return;
    }

    // Save URL to Firestore
    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
      'profileImage': imageUrl,
    });

    setState(() => _profileImageUrl = imageUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated!')),
    );
  }

  // Save profile changes (name, phone)
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    final Map<String, dynamic> updateData = {
      'name': _nameController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty) 'phone': _phoneController.text.trim(),
    };

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update(updateData);

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Cancel edit – reset controllers
                _nameController.clear();
                _phoneController.clear();
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = userData['name'] ?? 'No Name';
          final String phone = userData['phone'] ?? '';
          final String storedImageUrl = userData['profileImage'] ?? '';

          // Update controllers and local image URL
          if (_nameController.text.isEmpty && name.isNotEmpty) {
            _nameController.text = name;
          }
          if (_phoneController.text.isEmpty && phone.isNotEmpty) {
            _phoneController.text = phone;
          }
          if (_profileImageUrl == null && storedImageUrl.isNotEmpty) {
            _profileImageUrl = storedImageUrl;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile picture section – no asset, just icon fallback
                Stack(
                  children: [
                    // Avatar: if image URL exists, show network image; else show icon
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      child: _profileImageUrl != null
                          ? ClipOval(
                        child: Image.network(
                          _profileImageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                    // Camera icon overlay (always visible, but you can restrict to edit mode if you want)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploading ? null : _uploadProfileImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: _isUploading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Editable fields or view mode
                if (_isEditing) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // View mode: you can use your existing ProfileHeader or simple text
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  // Add any other profile fields you have (email, address, etc.)
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}