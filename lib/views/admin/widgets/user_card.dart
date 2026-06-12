import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool isBlocked;
  final String? profileImage;
  final String? subtitle; // ← optional now
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.onTap,
    this.subtitle,       // ← optional
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFF5E6E6),
              backgroundImage:
                  profileImage != null ? AssetImage(profileImage!) : null,
              child: profileImage == null
                  ? Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Name, Email & optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  // Show subtitle (shopName) if available, else show email
                  Text(
                    subtitle ?? email,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Role & Status badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge.role(role),
                const SizedBox(height: 4),
                isBlocked ? StatusBadge.blocked() : StatusBadge.active(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
