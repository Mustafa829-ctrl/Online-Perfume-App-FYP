import 'package:flutter/material.dart';

/// Model representing a single role option in the role selection screen.
class RoleModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? assetImage; // Path to asset image (null if using icon only)
  final bool useAsset;      // True = show asset image, False = show icon

  const RoleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.assetImage,
    required this.useAsset,
  });
}
