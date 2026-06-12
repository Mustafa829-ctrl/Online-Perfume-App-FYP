import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order_model.dart';
import '../../../models/rider_model.dart';
import '../../../services/order_service.dart';
import 'rider_order_detail_screen.dart';

class RiderOrdersScreen extends StatefulWidget {
  final RiderModel rider;                              // ← add
  const RiderOrdersScreen({super.key, required this.rider});

  @override
  State<RiderOrdersScreen> createState() => _RiderOrdersScreenState();
}

class _RiderOrdersScreenState extends State<RiderOrdersScreen> {
  // Service
  final OrderService _orderService = OrderService();

  // State
  bool isLoading = false;
  List<OrderModel> allOrders = [];
  String _selectedFilter = 'All';

  // Filter options
  final List<String> _filters = [
    'All',
    'Assigned',
    'Accepted',
    'Picked',
    'In Transit',
    'Delivered',
    'Not Delivered',
  ];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // Load orders from Firebase
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Filtered orders
  List<OrderModel> get _filteredOrders {
    if (_selectedFilter == 'All') return allOrders;
    return allOrders
        .where((o) => o.status == _selectedFilter)
        .toList();
  }

  // Status color
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            children: [
              // ── Summary chips
              Row(
                children: [
                  _SummaryChip(
                    label: 'Assigned',
                    count: allOrders
                        .where((o) => o.status == 'Assigned')
                        .length,
                    color: const Color(0xffFFA726),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'In Transit',
                    count: allOrders
                        .where((o) => o.status == 'In Transit')
                        .length,
                    color: const Color(0xff7E57C2),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Delivered',
                    count: allOrders
                        .where((o) => o.status == 'Delivered')
                        .length,
                    color: const Color(0xff66BB6A),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffD08C4A)
                              : const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xffD08C4A)
                                : const Color(0xFFEEEEEE),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ── Count
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredOrders.length} Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // ── Orders List
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xffD08C4A),
                  ),
                )
              : _filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delivery_dining_outlined,
                              size: 60,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No orders found',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xffD08C4A),
                      onRefresh: loadOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            20, 0, 20, 20),
                        itemCount: _filteredOrders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return _OrderTile(
                            order: order,
                            statusColor:
                                _statusColor(order.status),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RiderOrderDetailScreen(
                                          order: order),
                                ),
                              );
                              // Reload after coming back
                              loadOrders();
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

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

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
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Tile
class _OrderTile extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderTile({
    required this.order,
    required this.statusColor,
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
            // ── Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Buyer info
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 13, color: Color(0xffD08C4A)),
                const SizedBox(width: 5),
                Text(
                  order.buyerName ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Address
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Color(0xffD08C4A)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    order.buyerAddress ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Amount + COD badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs ${order.amount ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'COD',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffD08C4A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
