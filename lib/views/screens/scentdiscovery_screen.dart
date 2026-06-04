import 'package:flutter/material.dart';

class ScentDiscoveryScreen extends StatefulWidget {
  const ScentDiscoveryScreen({super.key});

  @override
  State<ScentDiscoveryScreen> createState() => _ScentDiscoveryScreenState();
}

class _ScentDiscoveryScreenState extends State<ScentDiscoveryScreen> {
  static const Color bgColor   = Colors.white;
  static const Color darkBrown = Color(0xFF5C1A1A);
  static const Color goldColor = Color(0xFFCC8833);

  int? _selectedIndex;

  final List<Map<String, dynamic>> _moods = [
    {
      'title':    'Intense',
      'subtitle': 'Powerful',
      'image':    'assets/images/mood1.jpg',
      'subtitleColor': goldColor,
    },
    {
      'title':    'Romantic & Soft',
      'subtitle': null,
      'image':    'assets/images/mood2.jpg',
      'subtitleColor': goldColor,
    },
    {
      'title':    'Fresh  & Energetic',
      'subtitle': null,
      'image':    'assets/images/mood3.jpg',
      'subtitleColor': darkBrown,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const SizedBox(height: 10),

            _buildTitle(),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(_moods.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _MoodCard(
                        title:         _moods[i]['title'] as String,
                        subtitle:      _moods[i]['subtitle'] as String?,
                        image:         _moods[i]['image'] as String,
                        subtitleColor: _moods[i]['subtitleColor'] as Color,
                        selected:      _selectedIndex == i,
                        onTap: () => setState(() => _selectedIndex = i),
                      ),
                    );
                  }),
                ),
              ),
            ),

            _buildRevealButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left, color: darkBrown, size: 30),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Step 6 of 6',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.help_outline_rounded, color: darkBrown, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'What mode do you want evoke',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkBrown,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Select the atmosphere that defines you today',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedIndex != null ? () {} : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC8833),
            disabledBackgroundColor: const Color(0xFFCC8833).withOpacity(0.5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Reveal My Scent',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String image;
  final Color subtitleColor;
  final bool selected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.title,
    required this.image,
    required this.subtitleColor,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  static const Color darkBrown = Color(0xFF5C1A1A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: selected
              ? Border.all(color: const Color(0xFFCC8833), width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: selected
              ? [BoxShadow(
            color: const Color(0xFFCC8833).withOpacity(0.35),
            blurRadius: 12,
            spreadRadius: 2,
          )]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8CECE),
                  child: const Icon(Icons.image_not_supported,
                      color: Color(0xFF5C1A1A), size: 40),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: subtitleColor,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              if (selected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCC8833),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}