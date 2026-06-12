import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';
import 'package:online_perfume_app_fyp/views/seller/screens/seller_order_detail_screen.dart';

class SellerOrdersScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerOrdersScreen({super.key, required this.seller});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final OrderService _orderService = OrderService();

  bool isLoading = false;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All', 'Pending', 'Processing', 'Dispatched',
    'Delivered', 'Cancelled', 'Returned',
  ];

  List<OrderModel> _allOrders = [];

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
      final orders = await _orderService.getSellerOrders(
        widget.seller.docId ?? '',
      );
      setState(() {
        _allOrders = orders;
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

  List<OrderModel> get _filteredOrders {
    List<OrderModel> result = _allOrders;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      result = result.where((o) {
        return (o.orderId ?? '').toLowerCase().contains(query) ||
            (o.buyerName ?? '').toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedFilter != 'All') {
      result = result.where((o) => o.status == _selectedFilter).toList();
    }

    return result;
  }

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _allOrders.where((o) => o.status == 'Pending').length;
    final processingCount = _allOrders.where((o) => o.status == 'Processing').length;
    final dispatchedCount = _allOrders.where((o) => o.status == 'Dispatched').length;
    final filtered = _filteredOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            children: [
              // Summary chips
              Row(children: [
                _SummaryChip(label: 'Pending',    count: pendingCount,    color: const Color(0xffFFA726)),
                const SizedBox(width: 8),
                _SummaryChip(label: 'Processing', count: processingCount, color: const Color(0xff42A5F5)),
                const SizedBox(width: 8),
                _SummaryChip(label: 'Dispatched', count: dispatchedCount, color: const Color(0xffD08C4A)),
              ]),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search by order ID or buyer name...',
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xffD08C4A), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffD08C4A))),
                ),
              ),
              const SizedBox(height: 12),

              // Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xffD08C4A) : const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xffD08C4A) : const Color(0xFFEEEEEE)),
                        ),
                        child: Text(filter, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey.shade600)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('${filtered.length} Orders', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // Orders list
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
              : RefreshIndicator(
            color: const Color(0xffD08C4A),
            onRefresh: _loadOrders,
            child: filtered.isEmpty
                ? ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No orders found', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = filtered[index];
                return _OrderTile(
                  order: order,
                  formattedDate: _formatDate(order.createdAt),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerOrderDetailScreen(order: order),
                      ),
                    );
                    // Refresh after returning from detail screen
                    _loadOrders();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Summary Chip
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text('$count', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,   style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── Order Tile
class _OrderTile extends StatelessWidget {
  final OrderModel order;
  final String formattedDate;
  final VoidCallback onTap;
  const _OrderTile({required this.order, required this.formattedDate, required this.onTap});

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':    return const Color(0xffFFA726);
      case 'Processing': return const Color(0xff42A5F5);
      case 'Dispatched': return const Color(0xffD08C4A);
      case 'Delivered':  return const Color(0xff66BB6A);
      case 'Cancelled':  return const Color(0xffEF5350);
      case 'Returned':   return const Color(0xff7E57C2);
      default:           return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

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
            // Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(order.status ?? '', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Buyer name
            Row(children: [
              const Icon(Icons.person_outline, size: 14, color: Color(0xffD08C4A)),
              const SizedBox(width: 6),
              Text(order.buyerName ?? '', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff5E1D04))),
            ]),
            const SizedBox(height: 4),

            // Product
            Row(children: [
              const Icon(Icons.local_florist_outlined, size: 14, color: Color(0xffD08C4A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${order.productName ?? ''} x${order.quantity ?? 1}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 4),

            // Address
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xffD08C4A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(order.buyerAddress ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 10),

            // Amount + COD + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rs ${order.amount ?? 0}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(6)),
                    child: Text('COD', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xffD08C4A))),
                  ),
                  const SizedBox(width: 8),
                  Text(formattedDate, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}