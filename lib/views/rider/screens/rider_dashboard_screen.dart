import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../models/rider_model.dart';
import '../../../services/order_service.dart';

class RiderDashboardScreen extends StatefulWidget {
  final RiderModel rider;
  const RiderDashboardScreen({super.key, required this.rider});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  // Service
  final OrderService _orderService = OrderService();

  // State
  bool isLoading = false;
  List<OrderModel> allOrders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // Load all assigned orders
  Future<void> loadOrders() async {
    try {
      isLoading = true;
      setState(() {});

      String riderId = widget.rider.docId ?? '';

      allOrders = await _orderService.getAssignedOrders(riderId);

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Count orders by status
  int _countByStatus(String status) =>
      allOrders.where((o) => o.status == status).length;

  // Total COD collected today
  int get _todayEarnings {
    final today = DateTime.now();
    return allOrders
        .where((o) =>
    o.status == 'Delivered' &&
        o.deliveredAt != null &&
        DateTime.fromMillisecondsSinceEpoch(o.deliveredAt!)
            .day ==
            today.day)
        .fold(0, (sum, o) => sum + (o.amount ?? 0));
  }

  // Recent 3 orders
  List<OrderModel> get _recentOrders => allOrders.take(3).toList();

  @override
  Widget build(BuildContext context) {
    var rider = widget.rider;

    return isLoading
        ? const Center(
      child: CircularProgressIndicator(
        color: Color(0xffD08C4A),
      ),
    )
        : RefreshIndicator(
      color: const Color(0xffD08C4A),
      onRefresh: loadOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Welcome Banner
            _WelcomeBanner(riderName: rider.name ?? 'Rider'),
            const SizedBox(height: 24),

            // ── Stats Grid
            _SectionTitle(title: 'Overview'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _StatCard(
                  label: 'Assigned',
                  value: '${_countByStatus('Assigned')}',
                  icon: Icons.assignment_outlined,
                  bgColor: const Color(0xFFFFF3CD),
                  iconColor: const Color(0xffD08C4A),
                ),
                _StatCard(
                  label: 'In Transit',
                  value: '${_countByStatus('In Transit')}',
                  icon: Icons.delivery_dining_outlined,
                  bgColor: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xff42A5F5),
                ),
                _StatCard(
                  label: 'Delivered',
                  value: '${_countByStatus('Delivered')}',
                  icon: Icons.check_circle_outline,
                  bgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xff66BB6A),
                ),
                _StatCard(
                  label: "Today's COD",
                  value: 'Rs $_todayEarnings',
                  icon: Icons.payments_outlined,
                  bgColor: const Color(0xFFFCE4EC),
                  iconColor: const Color(0xffEF5350),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: 'Recent Orders'),
                Text(
                  'Pull to refresh',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _recentOrders.isEmpty
                ? _EmptyState(
              icon: Icons.delivery_dining_outlined,
              message: 'No orders assigned yet',
            )
                : Column(
              children: _recentOrders
                  .map((order) => _RecentOrderTile(order: order))
                  .toList(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Welcome Banner
class _WelcomeBanner extends StatelessWidget {
  final String riderName;
  const _WelcomeBanner({required this.riderName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff5E1D04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  riderName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready for deliveries today?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xffD08C4A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: const Color(0xff5E1D04),
      ),
    );
  }
}

// ── Stat Card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
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
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

// ── Recent Order Tile
class _RecentOrderTile extends StatelessWidget {
  final OrderModel order;
  const _RecentOrderTile({required this.order});

  Color _statusColor(String? status) {
    switch (status) {
      case 'Assigned':
        return const Color(0xffFFA726);
      case 'Accepted':
        return const Color(0xffD08C4A);
      case 'Picked':
        return const Color(0xff42A5F5);
      case 'In Transit':
        return const Color(0xff7E57C2);
      case 'Delivered':
        return const Color(0xff66BB6A);
      case 'Not Delivered':
        return const Color(0xffEF5350);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xffD08C4A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Order info
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

          // Status badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status ?? '',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}