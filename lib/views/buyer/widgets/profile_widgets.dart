import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Add this package to pubspec.yaml

class ProfileHeader extends StatelessWidget {
  final String name;
  final String imagePath; // Can be an asset path or a network URL
  final VoidCallback? onEditImage; // Callback to trigger image picking

  const ProfileHeader({
    super.key,
    required this.name,
    required this.imagePath,
    this.onEditImage,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the image is a URL or a local asset
    final bool isNetwork = imagePath.startsWith('http');

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xffF6B55E),
                    const Color(0xffF6B55E).withOpacity(0.3),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: isNetwork
                    ? NetworkImage(imagePath)
                    : AssetImage(imagePath) as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
            ),
            GestureDetector(
              onTap: onEditImage, // Trigger the picker here
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xffF6B55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 18, color: Color(0xff5E1D04)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
      ],
    );
  }
}