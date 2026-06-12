import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/user_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/models/rider_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/filter_chip_bar.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/user_card.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/user_detail_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/add_user.dart';

class AdminUserListScreen extends StatefulWidget {
  final String initialFilter;

  const AdminUserListScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  // Service
  final AdminService _adminService = AdminService();

  // Controllers
  final TextEditingController _searchController = TextEditingController();

  // State
  bool isLoading = false;
  late String _selectedFilter;
  String _searchQuery = '';

  // All lists
  List<UserModel> allBuyers = [];
  List<SellerModel> allSellers = [];
  List<RiderModel> allRiders = [];

  final List<String> _filters = [
    'All',
    'Customer',
    'Seller',
    'Rider',
    'Blocked',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load all users from Firebase
  Future<void> loadUsers() async {
    try {
      isLoading = true;
      setState(() {});

      final results = await Future.wait([
        _adminService.getAllBuyers(),
        _adminService.getAllSellers(),
        _adminService.getAllRiders(),
      ]);

      allBuyers  = results[0] as List<UserModel>;
      allSellers = results[1] as List<SellerModel>;
      allRiders  = results[2] as List<RiderModel>;

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Combined filtered list based on selected filter
  List<Map<String, dynamic>> get _filteredUsers {
    List<Map<String, dynamic>> combined = [];

    // Build combined list based on filter
    if (_selectedFilter == 'All' || _selectedFilter == 'Customer') {
      for (final u in allBuyers) {
        combined.add({
          'type':      'buyer',
          'docId':     u.docId,
          'name':      u.name ?? '',
          'email':     u.email ?? '',
          'phone':     u.phone ?? '',
          'address':   u.address ?? '',
          'role':      'Customer',
          'isBlocked': u.isBlocked ?? false,
          'profileImageUrl': u.profileImageUrl,
          'createdAt': u.createdAt,
          'model':     u,
        });
      }
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Seller') {
      for (final s in allSellers) {
        combined.add({
          'type':      'seller',
          'docId':     s.docId,
          'name':      s.name ?? '',
          'email':     s.email ?? '',
          'phone':     s.phone ?? '',
          'address':   s.address ?? '',
          'role':      'Seller',
          'subtitle':  s.businessName ?? '',
          'isBlocked': s.isBlocked ?? false,
          'profileImageUrl': s.profileImageUrl,
          'createdAt': s.createdAt,
          'model':     s,
        });
      }
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Rider') {
      for (final r in allRiders) {
        combined.add({
          'type':      'rider',
          'docId':     r.docId,
          'name':      r.name ?? '',
          'email':     r.email ?? '',
          'phone':     r.phone ?? '',
          'address':   r.address ?? '',
          'role':      'Rider',
          'isBlocked': r.isBlocked ?? false,
          'profileImageUrl': r.profileImage,
          'createdAt': r.createdAt,
          'model':     r,
        });
      }
    }

    // Blocked filter — all types
    if (_selectedFilter == 'Blocked') {
      for (final u in allBuyers) {
        if (u.isBlocked == true) {
          combined.add({
            'type':      'buyer',
            'docId':     u.docId,
            'name':      u.name ?? '',
            'email':     u.email ?? '',
            'phone':     u.phone ?? '',
            'role':      'Customer',
            'isBlocked': true,
            'model':     u,
          });
        }
      }
      for (final s in allSellers) {
        if (s.isBlocked == true) {
          combined.add({
            'type':      'seller',
            'docId':     s.docId,
            'name':      s.name ?? '',
            'email':     s.email ?? '',
            'phone':     s.phone ?? '',
            'role':      'Seller',
            'subtitle':  s.businessName ?? '',
            'isBlocked': true,
            'model':     s,
          });
        }
      }
      for (final r in allRiders) {
        if (r.isBlocked == true) {
          combined.add({
            'type':      'rider',
            'docId':     r.docId,
            'name':      r.name ?? '',
            'email':     r.email ?? '',
            'phone':     r.phone ?? '',
            'role':      'Rider',
            'isBlocked': true,
            'model':     r,
          });
        }
      }
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      combined = combined.where((u) {
        return (u['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            (u['email'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return combined;
  }

  int get _totalCount =>
      allBuyers.length + allSellers.length + allRiders.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'User Management',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
        actions: [
          // ── Add User button
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddUserScreen()),
              );
              loadUsers();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+ Add User',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xffD08C4A)),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val),
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04)),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04)
                            .withOpacity(0.4),
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xffD08C4A)),
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
                    '${_filteredUsers.length} Users Found',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── User List
                  Expanded(
                    child: _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              'No users found',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xffD08C4A),
                            onRefresh: loadUsers,
                            child: ListView.builder(
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return UserCard(
                                  name: user['name'],
                                  email: user['email'],
                                  role: user['role'],
                                  isBlocked: user['isBlocked'],
                                  subtitle: user['subtitle'],
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminUserDetailScreen(
                                          user: user,
                                        ),
                                      ),
                                    );
                                    loadUsers();
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
