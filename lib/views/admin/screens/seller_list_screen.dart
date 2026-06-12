import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/filter_chip_bar.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/user_card.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/seller_detail_screen.dart';

class AdminSellerListScreen extends StatefulWidget {
  final String initialFilter;

  const AdminSellerListScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<AdminSellerListScreen> createState() => _AdminSellerListScreenState();
}

class _AdminSellerListScreenState extends State<AdminSellerListScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  late String _selectedFilter;
  String _searchQuery = '';
  bool isLoading = false;
  List<SellerModel> _allSellers = [];

  final List<String> _filters = ['All', 'Verified', 'Unverified', 'Blocked'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    loadSellers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Load sellers from Firebase
  Future<void> loadSellers() async {
    try {
      isLoading = true;
      setState(() {});

      // Use AdminService.getAllSellers()
      _allSellers = await _adminService.getAllSellers();

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Filtered sellers
  List<SellerModel> get _filteredSellers {
    List<SellerModel> result = _allSellers;

    // Apply filter
    if (_selectedFilter == 'Blocked') {
      result = result.where((s) => s.isBlocked == true).toList();
    } else if (_selectedFilter == 'Verified') {
      result = result
          .where((s) => s.isVerified == true && s.isBlocked == false)
          .toList();
    } else if (_selectedFilter == 'Unverified') {
      result = result
          .where((s) => s.isVerified == false && s.isBlocked == false)
          .toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) {
        return (s.name?.toLowerCase().contains(q) ?? false) ||
            (s.email?.toLowerCase().contains(q) ?? false) ||
            (s.businessName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Seller Management',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
        // Refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xffD08C4A)),
            onPressed: loadSellers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Summary chips
            if (!isLoading) ...[
              Row(
                children: [
                  _SummaryChip(
                    label: 'Total',
                    count: _allSellers.length,
                    color: const Color(0xffD08C4A),
                    bgColor: const Color(0xFFFFF3CD),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Verified',
                    count: _allSellers
                        .where((s) =>
                    s.isVerified == true && s.isBlocked == false)
                        .length,
                    color: const Color(0xff66BB6A),
                    bgColor: const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Pending',
                    count: _allSellers
                        .where((s) =>
                    s.isVerified == false && s.isBlocked == false)
                        .length,
                    color: const Color(0xFF856404),
                    bgColor: const Color(0xFFFFF3CD),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Blocked',
                    count: _allSellers
                        .where((s) => s.isBlocked == true)
                        .length,
                    color: const Color(0xFF721C24),
                    bgColor: const Color(0xFFF8D7DA),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // ── Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xff5E1D04)),
              decoration: InputDecoration(
                hintText: 'Search by name, email or shop...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04).withOpacity(0.4),
                ),
                prefixIcon:
                const Icon(Icons.search, color: Color(0xffD08C4A)),
                filled: true,
                fillColor: const Color(0xFFFFF3CD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // ── Filter Chips
            FilterChipBar(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: 16),

            // ── Count
            Text(
              '${_filteredSellers.length} Sellers Found',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),

            // ── Seller List
            Expanded(
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xffD08C4A)))
                  : _filteredSellers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined,
                        size: 56, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No sellers found',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade400)),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xffD08C4A),
                onRefresh: loadSellers,
                child: ListView.builder(
                  itemCount: _filteredSellers.length,
                  itemBuilder: (context, index) {
                    final seller = _filteredSellers[index];
                    return UserCard(
                      name: seller.name ?? '',
                      email: seller.email ?? '',
                      role: 'Seller',
                      isBlocked: seller.isBlocked ?? false,
                      subtitle: seller.businessName ?? '',
                      onTap: () async {
                        // Pass SellerModel to detail screen
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminSellerDetailScreen(
                                  seller: seller,
                                ),
                          ),
                        );
                        // Reload after returning
                        loadSellers();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Chip
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text('$count',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}