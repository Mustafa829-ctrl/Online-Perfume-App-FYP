import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/rider_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/rider_detail_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/filter_chip_bar.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/user_card.dart';

class AdminRiderListScreen extends StatefulWidget {
  const AdminRiderListScreen({super.key});

  @override
  State<AdminRiderListScreen> createState() =>
      _AdminRiderListScreenState();
}

class _AdminRiderListScreenState
    extends State<AdminRiderListScreen> {
  final AdminService _adminService = AdminService();

  bool isLoading = false;
  List<RiderModel> _allRiders = [];

  // Seller name cache: sellerId → businessName
  final Map<String, String> _sellerNames = {};

  final TextEditingController _searchController =
  TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery    = '';

  final List<String> _filters = ['All', 'Active', 'Blocked'];

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRiders() async {
    try {
      setState(() => isLoading = true);
      final riders = await _adminService.getAllRiders();
      setState(() {
        _allRiders = riders;
        isLoading  = false;
      });
      // Fetch seller names for all unique sellerIds
      await _loadSellerNames();
    } catch (e) {
      setState(() => isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _loadSellerNames() async {
    final uniqueIds = _allRiders
        .map((r) => r.sellerId ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final sellerId in uniqueIds) {
      if (_sellerNames.containsKey(sellerId)) continue;
      try {
        final seller =
        await _adminService.getSellerById(sellerId);
        if (mounted) {
          setState(() {
            _sellerNames[sellerId] =
                seller.businessName ?? seller.name ?? '';
          });
        }
      } catch (_) {
        _sellerNames[sellerId] = '';
      }
    }
  }

  List<RiderModel> get _filteredRiders {
    return _allRiders.where((rider) {
      final matchesFilter = _selectedFilter == 'All'
          ? true
          : _selectedFilter == 'Blocked'
          ? rider.isBlocked == true
          : rider.isBlocked == false;
      final matchesSearch = _searchQuery.isEmpty ||
          (rider.name
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              false) ||
          (rider.phone?.contains(_searchQuery) ?? false) ||
          (rider.email
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRiders;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Rider Management',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04)),
              decoration: InputDecoration(
                hintText: 'Search by name, phone or email...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xff5E1D04)
                        .withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xffD08C4A)),
                filled: true,
                fillColor: const Color(0xFFFFF3CD),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Filter chips
            FilterChipBar(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (f) =>
                  setState(() => _selectedFilter = f),
            ),
            const SizedBox(height: 16),

            // Count
            Text('${filtered.length} Riders Found',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500)),
            const SizedBox(height: 10),

            // Riders list
            Expanded(
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xffD08C4A)))
                  : filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                        Icons
                            .delivery_dining_outlined,
                        size: 60,
                        color:
                        Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No riders found',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors
                                .grey.shade400)),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xffD08C4A),
                onRefresh: _loadRiders,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final rider = filtered[index];
                    final sellerName =
                        _sellerNames[
                        rider.sellerId ??
                            ''] ??
                            '';
                    return UserCard(
                      name: rider.name ?? '',
                      email: rider.email ?? '',
                      role: 'Rider',
                      isBlocked:
                      rider.isBlocked ?? false,
                      subtitle: sellerName
                          .isNotEmpty
                          ? sellerName
                          : null,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminRiderDetailScreen(
                                  rider: rider,
                                  sellerName:
                                  sellerName,
                                ),
                          ),
                        );
                        // Refresh after returning
                        _loadRiders();
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