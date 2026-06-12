import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_add_product_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_expenses_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_orders_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerDashboardScreen({super.key, required this.seller});

  @override
  State<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // ── Dashboard stats
  int totalOrders = 0;
  int pendingOrders = 0;
  int totalProducts = 0;
  int lowStockProducts = 0;
  double totalSales = 0;

  // ── Recent orders (last 3)
  List<Map<String, dynamic>> recentOrders = [];

  // ── Weekly sales data for chart
  List<Map<String, dynamic>> weeklySales = [
    {'day': 'Mon', 'amount': 0},
    {'day': 'Tue', 'amount': 0},
    {'day': 'Wed', 'amount': 0},
    {'day': 'Thu', 'amount': 0},
    {'day': 'Fri', 'amount': 0},
    {'day': 'Sat', 'amount': 0},
    {'day': 'Sun', 'amount': 0},
  ];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      setState(() {});

      String sellerId = widget.seller.docId ?? '';

      // Run all queries in parallel
      await Future.wait([
        _loadOrderStats(sellerId),
        _loadProductStats(sellerId),
        _loadRecentOrders(sellerId),
        _loadWeeklySales(sellerId),
      ]);

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

  // ── Load order stats
  Future<void> _loadOrderStats(String sellerId) async {
    QuerySnapshot snap = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    totalOrders = snap.docs.length;
    totalSales = snap.docs.fold(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + ((data['totalAmount'] ?? 0)).toDouble();
    });
    pendingOrders = snap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['orderStatus'] == 'pending' ||
          data['orderStatus'] == 'processing';
    }).length;
  }

  // ── Load product stats
  Future<void> _loadProductStats(String sellerId) async {
    QuerySnapshot snap = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    totalProducts = snap.docs.length;

    // Count low stock — where quantity <= threshold
    lowStockProducts = snap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      int quantity = data['quantity'] ?? 0;
      int threshold = data['threshold'] ?? 5;
      return quantity <= threshold;
    }).length;
  }

  // ── Load recent 3 orders
  Future<void> _loadRecentOrders(String sellerId) async {
    QuerySnapshot snap = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

    recentOrders = snap.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id;
      return data;
    }).toList();
  }

  // ── Load weekly sales for chart
  Future<void> _loadWeeklySales(String sellerId) async {
    // Get last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    QuerySnapshot snap = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('orderStatus', isEqualTo: 'delivered')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .get();

    // Reset weekly sales
    Map<int, double> daySales = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['createdAt'] != null) {
        DateTime date = (data['createdAt'] as Timestamp).toDate();
        int weekday = date.weekday - 1; // 0=Mon, 6=Sun
        daySales[weekday] =
            (daySales[weekday] ?? 0) + (data['totalAmount'] ?? 0).toDouble();
      }
    }

    weeklySales = [
      {'day': 'Mon', 'amount': daySales[0]!.toInt()},
      {'day': 'Tue', 'amount': daySales[1]!.toInt()},
      {'day': 'Wed', 'amount': daySales[2]!.toInt()},
      {'day': 'Thu', 'amount': daySales[3]!.toInt()},
      {'day': 'Fri', 'amount': daySales[4]!.toInt()},
      {'day': 'Sat', 'amount': daySales[5]!.toInt()},
      {'day': 'Sun', 'amount': daySales[6]!.toInt()},
    ];
  }

  // ── Format timestamp to readable string
  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '';
    DateTime date = (createdAt as Timestamp).toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return 'Just now';
    if (diff.inHours < 24) return '${diff.inHours} Hours Ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} Days Ago';
  }

  // ── Format amount
  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return 'Rs ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'Rs ${amount.toStringAsFixed(0)}';
  }

  // ── Status from orderStatus field
  String _getStatus(String? status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'processing': return 'Processing';
      case 'dispatched_rider':
      case 'dispatched_courier': return 'Shipped';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      case 'return_requested': return 'Return';
      default: return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Max weekly sales for chart ratio
    final int maxSales = weeklySales.isEmpty
        ? 1
        : weeklySales
            .map((d) => d['amount'] as int)
            .reduce((a, b) => a > b ? a : b);
    final int chartMax = maxSales == 0 ? 1 : maxSales;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xffD08C4A)))
        : RefreshIndicator(
            color: const Color(0xffD08C4A),
            onRefresh: loadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── Welcome Banner
                  Container(
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
                              Text('Welcome Back!',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white60)),
                              // ✅ Real seller business name
                              Text(
                                widget.seller.businessName ?? 'My Store',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text('Here\'s your store overview',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white60)),
                            ],
                          ),
                        ),
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xffD08C4A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.storefront_outlined,
                              color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Stats Cards
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
                      // ✅ Real data from Firebase
                      _StatCard(
                        label: 'Total Sales',
                        value: _formatAmount(totalSales),
                        icon: Icons.trending_up,
                        bgColor: const Color(0xFFFFF3CD),
                        iconColor: const Color(0xffD08C4A),
                      ),
                      _StatCard(
                        label: 'Pending Orders',
                        value: '$pendingOrders',
                        icon: Icons.hourglass_empty_outlined,
                        bgColor: const Color(0xFFFCE4EC),
                        iconColor: const Color(0xffE57373),
                      ),
                      _StatCard(
                        label: 'Total Products',
                        value: '$totalProducts',
                        icon: Icons.inventory_2_outlined,
                        bgColor: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xff66BB6A),
                      ),
                      _StatCard(
                        label: 'Low Stock',
                        value: '$lowStockProducts',
                        icon: Icons.warning_amber_outlined,
                        bgColor: const Color(0xFFFFF3CD),
                        iconColor: const Color(0xffFFA726),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Weekly Revenue Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(title: 'Revenue Analytics'),
                      Text('This Week',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xffD08C4A),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: weeklySales.map((data) {
                              // ✅ Dynamic ratio from real data
                              final double ratio =
                                  (data['amount'] as int) / chartMax;
                              final bool isHighest =
                                  data['amount'] == chartMax &&
                                      chartMax > 0;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isHighest)
                                    Text(
                                      'Rs ${((data['amount'] as int) / 1000).toStringAsFixed(1)}k',
                                      style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color:
                                              const Color(0xffD08C4A),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 28,
                                    height: ratio == 0
                                        ? 4
                                        : 100 * ratio,
                                    decoration: BoxDecoration(
                                      color: isHighest
                                          ? const Color(0xffD08C4A)
                                          : const Color(0xFFFCE4EC),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: weeklySales.map((data) {
                            return Text(data['day'],
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey.shade500));
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Recent Orders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(title: 'Recent Orders'),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SellerOrdersScreen(
                                seller: widget.seller),
                          ),
                        ),
                        child: Text('View All',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffD08C4A))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ✅ Real orders from Firebase
                  recentOrders.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('No orders yet',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade400)),
                          ),
                        )
                      : Column(
                          children: recentOrders.map((order) {
                            return _RecentOrderTile(
                              orderId: order['orderId'] ?? '',
                              product: (order['products'] != null &&
                                      (order['products'] as List)
                                          .isNotEmpty)
                                  ? order['products'][0]['name'] ?? ''
                                  : '',
                              amount:
                                  'Rs ${order['totalAmount'] ?? 0}',
                              status: _getStatus(order['orderStatus']),
                              date: _formatDate(order['createdAt']),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // ── Quick Actions
                  _SectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_box_outlined,
                          label: 'Add Product',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SellerAddProductScreen(
                                  seller: widget.seller),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.person_add_outlined,
                          label: 'Add Rider',
                          onTap: () {
                            // TODO: Navigate to Add Rider screen
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_chart_outlined,
                          label: 'Add Expense',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SellerExpensesScreen(
                                  seller: widget.seller),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
    return Text(title,
        style: GoogleFonts.playfairDisplay(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04)));
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
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04))),
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis),
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
  final String orderId;
  final String product;
  final String amount;
  final String status;
  final String date;

  const _RecentOrderTile({
    required this.orderId,
    required this.product,
    required this.amount,
    required this.status,
    required this.date,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending': return const Color(0xffFFA726);
      case 'Processing': return const Color(0xffFFA726);
      case 'Shipped': return const Color(0xff42A5F5);
      case 'Delivered': return const Color(0xff66BB6A);
      case 'Cancelled': return const Color(0xffEF5350);
      case 'Return': return const Color(0xff7E57C2);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);
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
          Container(
            width: 44, height: 44,
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
                Text(orderId,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5E1D04))),
                Text('$product • $amount',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis),
                Text(date,
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor)),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xffD08C4A), size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff5E1D04)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
