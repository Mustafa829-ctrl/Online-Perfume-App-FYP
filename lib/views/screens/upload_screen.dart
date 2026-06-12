import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';

class UploadScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUpload(BuildContext context) async {
    // 1. Pick image from gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // 2. Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading image...')),
    );

    // 3. Upload to Cloudinary
    final String? imageUrl = await CloudinaryService.uploadImage(File(pickedFile.path));

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
      return;
    }

    // 4. Save URL to Firestore (example: 'images' collection)
    await FirebaseFirestore.instance.collection('images').add({
      'url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 5. Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploaded! URL: $imageUrl')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickAndUpload(context),
          child: const Text('Pick & Upload Image'),
        ),
      ),
    );
  }
}