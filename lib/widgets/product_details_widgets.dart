import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VolumeSelector extends StatelessWidget {
  final String volume;
  final bool isSelected;
  final VoidCallback onTap;

  const VolumeSelector({
    super.key,
    required this.volume,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffF6B55E)
              : const Color(0xff1A0A1F), // Yellow if selected, Dark brown otherwise
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          volume,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xff5E1D04)
                : const Color(0xffF6B55E), // Reverse text color
          ),
        ),
      ),
    );
  }
}

class ScentSelector extends StatelessWidget {
  final String scent;
  final bool isSelected;
  final String? imagePath;
  final VoidCallback onTap;

  const ScentSelector({
    super.key,
    required this.scent,
    required this.isSelected,
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xffF6B55E)
                : const Color(0xff5E1D04), // Yellow if selected, Dark brown otherwise
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? const Color(0xffD08C4A) : Colors.transparent,
                width: 2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scent,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xff5E1D04)
                    : const Color(0xffF6B55E),
              ),
            ),
            if (imagePath != null) ...[
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(imagePath!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
