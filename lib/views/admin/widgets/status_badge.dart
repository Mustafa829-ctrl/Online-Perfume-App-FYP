import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.active() => const StatusBadge(
        label: 'Active',
        backgroundColor: Color(0xFFD4EDDA),
        textColor: Color(0xFF155724),
      );

  factory StatusBadge.blocked() => const StatusBadge(
        label: 'Blocked',
        backgroundColor: Color(0xFFF8D7DA),
        textColor: Color(0xFF721C24),
      );

  factory StatusBadge.role(String role) {
    final Map<String, List<Color>> roleColors = {
      'Customer': [const Color(0xFFD0E8FF), const Color(0xFF0D47A1)],
      'Seller':   [const Color(0xFFFFF3CD), const Color(0xFF856404)],
      'Rider':    [const Color(0xFFE2D9F3), const Color(0xFF4A235A)],
    };
    final colors = roleColors[role] ?? [const Color(0xFFE0E0E0), const Color(0xFF333333)];
    return StatusBadge(
      label: role,
      backgroundColor: colors[0],
      textColor: colors[1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
