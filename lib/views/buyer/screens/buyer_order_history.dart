import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';

import 'order_detail_screen.dart';
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();

  bool isLoading = false;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final orders = await _orderService.getBuyerOrders(uid);
      setState(() {
        _orders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':    return const Color(0xffFFA726);
      case 'Processing': return const Color(0xff42A5F5);
      case 'Dispatched': return const Color(0xffD08C4A);
      case 'Delivered':  return const Color(0xff66BB6A);
      case 'Cancelled':  return const Color(0xffEF5350);
      case 'Returned':   return const Color(0xff7E57C2);
      case 'Not Delivered': return const Color(0xffEF5350);
      default:           return Colors.grey;
    }
  }

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xff5E1D04), size: 20),
        ),
        title: Text('Order History',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : RefreshIndicator(
        color: const Color(0xffD08C4A),
        onRefresh: _loadOrders,
        child: _orders.isEmpty
            ? ListView(
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No orders yet',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          itemCount: _orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = _orders[index];
            return _OrderHistoryTile(
              order: order,
              statusColor: _statusColor(order.status),
              formattedDate: _formatDate(order.createdAt),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                );
                _loadOrders();
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Order History Tile
class _OrderHistoryTile extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final String formattedDate;
  final VoidCallback onTap;

  const _OrderHistoryTile({
    required this.order,
    required this.statusColor,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId ?? '',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(order.status ?? '',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(children: [
              const Icon(Icons.local_florist_outlined, size: 14, color: Color(0xffD08C4A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${order.productName ?? ''} x${order.quantity ?? 1}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rs ${order.amount ?? 0}',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                Text(formattedDate, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}