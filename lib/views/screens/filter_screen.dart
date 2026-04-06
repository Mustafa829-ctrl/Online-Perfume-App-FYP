import 'package:flutter/material.dart';
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const Color bgColor   = Color(0xFFFCE8E8);
  static const Color darkBrown = Color(0xFF5C1A1A);
  static const Color cardBrown = Color(0xFF6B2020);
  static const Color goldBtn   = Color(0xFFCC8833);

  final List<String> _scents = ['Floral', 'Spicy', 'Woody', 'Citrus', 'Oriental', 'Fresh'];
  final Set<String> _selectedScents = {'Floral', 'Spicy', 'Woody', 'Citrus', 'Oriental', 'Fresh'};

  RangeValues _priceRange = const RangeValues(125, 445);

  String? _selectedOccasion;

  final List<Map<String, dynamic>> _occasions = [
    {'label': 'Night Out',          'icon': Icons.nightlight_round},
    {'label': 'Day Wear',           'icon': Icons.wb_sunny_rounded},
    {'label': 'Professional/Office','icon': Icons.business},
  ];

  final List<String> _brandImages = [
    'assets/images/brand1.jpg',
    'assets/images/brand2.jpg',
    'assets/images/brand3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildHeader(context),
                    const SizedBox(height: 28),

                    _buildSectionLabel('SCENT TYPE'),
                    const SizedBox(height: 14),
                    _buildScentChips(),
                    const SizedBox(height: 28),

                    _buildPriceRange(),
                    const SizedBox(height: 24),

                    _buildOccasionCards(),
                    const SizedBox(height: 28),

                    _buildBrandSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: darkBrown,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.close, color: darkBrown, size: 26),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: darkBrown,
      ),
    );
  }

  Widget _buildScentChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _scents.map((scent) {
        final selected = _selectedScents.contains(scent);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedScents.remove(scent);
              } else {
                _selectedScents.add(scent);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            decoration: BoxDecoration(
              color: selected ? darkBrown : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? darkBrown : darkBrown.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: Text(
              scent,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : darkBrown,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: darkBrown,
              ),
            ),
            Text(
              '\$${_priceRange.start.round()}–\$${_priceRange.end.round()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: darkBrown,
            inactiveTrackColor: darkBrown.withOpacity(0.2),
            thumbColor: darkBrown,
            overlayColor: darkBrown.withOpacity(0.1),
            trackHeight: 3,
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            onChanged: (val) => setState(() => _priceRange = val),
          ),
        ),
      ],
    );
  }

  Widget _buildOccasionCards() {
    return Column(
      children: _occasions.map((occ) {
        final selected = _selectedOccasion == occ['label'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedOccasion = selected ? null : occ['label'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: selected ? cardBrown.withOpacity(0.75) : darkBrown,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(occ['icon'] as IconData, color: Colors.white, size: 24),
                const SizedBox(width: 16),
                Text(
                  occ['label'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prepared Brand',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: _brandImages.map((img) {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withOpacity(0.25),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(img),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: bgColor,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedScents.clear();
                _priceRange = const RangeValues(125, 445);
                _selectedOccasion = null;
              });
            },
            child: const Text(
              'CLEAR ALL',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkBrown,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldBtn,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}