import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/admin_model.dart';
import 'package:online_perfume_app_fyp/models/complaint_model.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/section_title.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/admin_drawer.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/user_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/seller_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/rider_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/order_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/complaint_list_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/complaint_detail_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/order_detail_screen.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/seller_detail_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final AdminModel admin;
  const AdminHomeScreen({super.key, required this.admin});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Service
  final AdminService _adminService = AdminService();

  // State for dashboard stats
  bool isStatsLoading = false;
  Map<String, int> stats = {
    'totalSellers':         0,
    'totalBuyers':          0,
    'totalRiders':          0,
    'totalOrders':          0,
    'totalProducts':        0,
    'pendingComplaints':    0,
    'pendingVerifications': 0,
    'issuedOrders':         0,
  };

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  // Load dashboard stats
  Future<void> loadStats() async {
    try {
      isStatsLoading = true;
      setState(() {});

      stats = await _adminService.getDashboardStats();

      isStatsLoading = false;
      setState(() {});
    } catch (e) {
      isStatsLoading = false;
      setState(() {});
    }
  }

  // Format number for display
  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  // Complaint status colors
  Map<String, Color> _complaintStatusColors(String? status) {
    switch (status) {
      case 'Pending':
        return {'bg': const Color(0xFFF8D7DA), 'text': const Color(0xFF721C24)};
      case 'In Progress':
        return {'bg': const Color(0xFFE3F2FD), 'text': const Color(0xff42A5F5)};
      case 'Resolved':
        return {'bg': const Color(0xFFE8F5E9), 'text': const Color(0xff66BB6A)};
      default:
        return {'bg': const Color(0xFFF5F5F5), 'text': Colors.grey};
    }
  }

  // Order status colors
  Map<String, Color> _orderStatusColors(String? status) {
    switch (status) {
      case 'Not Delivered':
        return {'bg': const Color(0xFFFCE4EC), 'text': const Color(0xffEF5350)};
      case 'Cancelled':
        return {'bg': const Color(0xFFF8D7DA), 'text': const Color(0xFF721C24)};
      case 'Returned':
        return {'bg': const Color(0xFFFFF3CD), 'text': const Color(0xffFFA726)};
      default:
        return {'bg': const Color(0xFFF5F5F5), 'text': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu, color: Color(0xff5E1D04)),
          ),
        ),
      ),
      drawer: AdminDrawer(admin: widget.admin),
      body: RefreshIndicator(
        color: const Color(0xffD08C4A),
        onRefresh: loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── Overview Stat Cards
              const SectionTitle(title: 'Overview'),
              const SizedBox(height: 12),
              isStatsLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                            color: Color(0xffD08C4A)),
                      ),
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.4,
                      children: [
                        _TappableStatCard(
                          label: 'Total Users',
                          value: _formatCount(stats['totalBuyers'] ?? 0),
                          icon: Icons.people_outline,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminUserListScreen())),
                        ),
                        _TappableStatCard(
                          label: 'Total Sellers',
                          value: _formatCount(stats['totalSellers'] ?? 0),
                          icon: Icons.store_outlined,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminSellerListScreen())),
                        ),
                        _TappableStatCard(
                          label: 'Total Riders',
                          value: _formatCount(stats['totalRiders'] ?? 0),
                          icon: Icons.delivery_dining_outlined,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminRiderListScreen())),
                        ),
                        _TappableStatCard(
                          label: 'Blocked Users',
                          value: _formatCount(stats['totalOrders'] ?? 0),
                          icon: Icons.block_outlined,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminUserListScreen(
                                      initialFilter: 'Blocked'))),
                        ),
                        // ── Live badge: pending complaints
                        StreamBuilder<int>(
                          stream:
                              _adminService.pendingComplaintsStream(),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return _TappableStatCard(
                              label: 'Pending Complaints',
                              value: _formatCount(count),
                              icon: Icons.report_outlined,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminComplaintListScreen(
                                              initialFilter: 'Pending'))),
                            );
                          },
                        ),
                        // ── Live badge: flagged orders
                        _TappableStatCard(
                          label: 'Flagged Orders',
                          value: _formatCount(stats['issuedOrders'] ?? 0),
                          icon: Icons.warning_amber_outlined,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminOrderListScreen())),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // ── Recent Complaints — StreamBuilder (live)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'Recent Complaints'),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AdminComplaintListScreen())),
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffD08C4A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<ComplaintModel>>(
                stream: _adminService.complaintsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xffD08C4A)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _EmptyState(
                      icon: Icons.report_outlined,
                      message: 'No complaints yet',
                    );
                  }
                  // Show only latest 2
                  final complaints = snapshot.data!.take(2).toList();
                  return Column(
                    children: complaints.map((complaint) {
                      final colors =
                          _complaintStatusColors(complaint.status);
                      return _RecentComplaintTile(
                        complaint: complaint,
                        statusBgColor: colors['bg']!,
                        statusTextColor: colors['text']!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminComplaintDetailScreen(
                              complaint: complaint,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Flagged Orders — StreamBuilder (live)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'Flagged Orders'),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminOrderListScreen())),
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffD08C4A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<OrderModel>>(
                stream: _adminService.issuedOrdersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xffD08C4A)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _EmptyState(
                      icon: Icons.warning_amber_outlined,
                      message: 'No flagged orders',
                    );
                  }
                  // Show only latest 2
                  final orders = snapshot.data!.take(2).toList();
                  return Column(
                    children: orders.map((order) {
                      final colors =
                          _orderStatusColors(order.status);
                      return _RecentOrderTile(
                        order: order,
                        statusBgColor: colors['bg']!,
                        statusTextColor: colors['text']!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminOrderDetailScreen(order: order),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Pending Verifications — StreamBuilder (live)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'Pending Verifications'),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminSellerListScreen(
                                initialFilter: 'Unverified'))),
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffD08C4A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<SellerModel>>(
                stream: _adminService.sellersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xffD08C4A)),
                    );
                  }
                  if (!snapshot.hasData) {
                    return _EmptyState(
                      icon: Icons.store_outlined,
                      message: 'No pending verifications',
                    );
                  }
                  // Filter unverified sellers
                  final unverified = snapshot.data!
                      .where((s) =>
                          (s.isVerified == false) &&
                          (s.isBlocked == false))
                      .take(2)
                      .toList();

                  if (unverified.isEmpty) {
                    return _EmptyState(
                      icon: Icons.store_outlined,
                      message: 'No pending verifications',
                    );
                  }

                  return Column(
                    children: unverified
                        .map((seller) => _UnverifiedSellerTile(
                              seller: seller,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminSellerDetailScreen(
                                          seller: seller),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tappable Stat Card
class _TappableStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TappableStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xffD08C4A), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
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

// ── Recent Complaint Tile
class _RecentComplaintTile extends StatelessWidget {
  final ComplaintModel complaint;
  final Color statusBgColor;
  final Color statusTextColor;
  final VoidCallback onTap;

  const _RecentComplaintTile({
    required this.complaint,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF5E6E6),
              child: Text(
                (complaint.buyerName ?? 'B')[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint.buyerName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  Text(
                    complaint.issue ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: complaint.status ?? 'Pending',
              backgroundColor: statusBgColor,
              textColor: statusTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Order Tile
class _RecentOrderTile extends StatelessWidget {
  final OrderModel order;
  final Color statusBgColor;
  final Color statusTextColor;
  final VoidCallback onTap;

  const _RecentOrderTile({
    required this.order,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Color(0xffD08C4A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderId ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  Text(
                    '${order.buyerName ?? ''} • Rs ${order.amount ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
    );
  }
}

// ── Unverified Seller Tile
class _UnverifiedSellerTile extends StatelessWidget {
  final SellerModel seller;
  final VoidCallback onTap;

  const _UnverifiedSellerTile({
    required this.seller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF5E6E6),
              child: Text(
                (seller.name ?? 'S')[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.name ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  Text(
                    seller.businessName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const StatusBadge(
              label: 'Unverified',
              backgroundColor: Color(0xFFFFF3CD),
              textColor: Color(0xFF856404),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
