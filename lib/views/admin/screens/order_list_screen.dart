import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/filter_chip_bar.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';
import 'order_detail_screen.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() =>
      _AdminOrderListScreenState();
}

class _AdminOrderListScreenState
    extends State<AdminOrderListScreen> {
  final AdminService _adminService = AdminService();

  bool isLoading = false;
  List<OrderModel> _allOrders = [];

  final TextEditingController _searchController =
  TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery    = '';

  final List<String> _filters = [
    'All',
    'Not Delivered',
    'Returned',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => isLoading = true);
      final orders = await _adminService.getIssuedOrders();
      setState(() {
        _allOrders = orders;
        isLoading  = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError(e.toString());
    }
  }

  List<OrderModel> get _filteredOrders {
    return _allOrders.where((order) {
      final matchesFilter = _selectedFilter == 'All' ||
          order.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          (order.buyerName
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              false) ||
          (order.orderId
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'Not Delivered': return const Color(0xFFF8D7DA);
      case 'Returned':      return const Color(0xFFD0E8FF);
      case 'Cancelled':     return const Color(0xFFEEEEEE);
      default:              return const Color(0xFFEEEEEE);
    }
  }

  Color _statusTextColor(String? status) {
    switch (status) {
      case 'Not Delivered': return const Color(0xFF721C24);
      case 'Returned':      return const Color(0xFF0D47A1);
      case 'Cancelled':     return const Color(0xFF333333);
      default:              return const Color(0xFF333333);
    }
  }

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final d   = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1)  return 'Yesterday';
    if (diff.inDays < 7)   return '${diff.inDays} days ago';
    return '${d.day}/${d.month}/${d.year}';
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
    final filtered = _filteredOrders;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Order Management',
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
                hintText: 'Search by buyer or Order ID...',
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

            // Filter chips
            FilterChipBar(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (f) =>
                  setState(() => _selectedFilter = f),
            ),
            const SizedBox(height: 16),

            // Count
            Text(
              '${filtered.length} Orders Found',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),

            // Orders list
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
                            .receipt_long_outlined,
                        size: 60,
                        color:
                        Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No orders found',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors
                                .grey.shade400)),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xffD08C4A),
                onRefresh: _loadOrders,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _OrderCard(
                      order: order,
                      formattedDate: _formatDate(
                          order.createdAt),
                      statusBgColor: _statusBgColor(
                          order.status),
                      statusTextColor:
                      _statusTextColor(
                          order.status),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminOrderDetailScreen(
                                  order: order,
                                ),
                          ),
                        );
                        // Refresh after returning
                        _loadOrders();
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

// ── Order Card
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String formattedDate;
  final Color statusBgColor;
  final Color statusTextColor;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.formattedDate,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final issueText = order.status == 'Returned'
        ? (order.returnReason ?? 'Return requested')
        : (order.notDeliveredReason ?? 'Not delivered');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  // Wrap order ID with Expanded so it shrinks
                  Expanded(
                    child: Text(
                      order.orderId ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: order.status ?? '',
                    backgroundColor: statusBgColor,
                    textColor: statusTextColor,
                  ),
                ],
              ),
            ),

            // Middle row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xffD08C4A),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.buyerName ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04),
                          ),
                        ),
                        Text(
                          order.productName ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          issueText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: statusTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Bottom row – amount + view detail (unchanged)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3CD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs ${order.amount ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  Text(
                    'View Detail →',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffD08C4A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}