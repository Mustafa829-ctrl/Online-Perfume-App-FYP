import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../provider/rider-provider.dart';
import '../../../services/rider_service.dart';

class RiderOrdersScreen extends StatefulWidget {
  const RiderOrdersScreen({super.key});

  @override
  State<RiderOrdersScreen> createState() => _RiderOrdersScreenState();
}

class _RiderOrdersScreenState extends State<RiderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RiderService _service = RiderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rider = context.watch<RiderProvider>().rider;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text('My Orders',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    )),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
              indicator: BoxDecoration(
                color: const Color(0xff5E1D04),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Assigned'),
                Tab(text: 'In Progress'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab views
          Expanded(
            child: rider == null
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(
                  stream: _service.getAssignedOrdersStream(rider.uid)
                      .map((orders) => orders
                      .where((o) =>
                  o.orderStatus == 'dispatched_rider')
                      .toList()),
                  emptyMessage: 'No new assigned orders',
                  showAcceptReject: true,
                  service: _service,
                ),
                _OrdersList(
                  stream: _service.getAssignedOrdersStream(rider.uid)
                      .map((orders) => orders
                      .where((o) =>
                  o.orderStatus == 'picked' ||
                      o.orderStatus == 'in_transit')
                      .toList()),
                  emptyMessage: 'No orders in progress',
                  showUpdateStatus: true,
                  service: _service,
                ),
                _OrdersList(
                  stream: _service
                      .getOrdersByDateStream(rider.uid, DateTime.now())
                      .map((orders) => orders
                      .where((o) =>
                  o.orderStatus == 'delivered' ||
                      o.orderStatus == 'not_delivered')
                      .toList()),
                  emptyMessage: 'No completed orders today',
                  service: _service,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final Stream<List<OrderModel>> stream;
  final String emptyMessage;
  final bool showAcceptReject;
  final bool showUpdateStatus;
  final RiderService service;

  const _OrdersList({
    required this.stream,
    required this.emptyMessage,
    this.showAcceptReject = false,
    this.showUpdateStatus = false,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xffD08C4A)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(emptyMessage,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade400)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.length,
          itemBuilder: (_, i) {
            final order = snapshot.data![i];
            return _OrderCard(
              order: order,
              showAcceptReject: showAcceptReject,
              showUpdateStatus: showUpdateStatus,
              service: service,
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool showAcceptReject;
  final bool showUpdateStatus;
  final RiderService service;

  const _OrderCard({
    required this.order,
    this.showAcceptReject = false,
    this.showUpdateStatus = false,
    required this.service,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'dispatched_rider':
        return const Color(0xFFFFF3CD);
      case 'picked':
        return const Color(0xFFE8F5E9);
      case 'in_transit':
        return const Color(0xFFE3F2FD);
      case 'delivered':
        return const Color(0xFFE8F5E9);
      case 'not_delivered':
        return const Color(0xFFF8D7DA);
      default:
        return const Color(0xFFF9F9F9);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'dispatched_rider':
        return const Color(0xFF856404);
      case 'picked':
        return Colors.green.shade700;
      case 'in_transit':
        return Colors.blue.shade700;
      case 'delivered':
        return Colors.green.shade700;
      case 'not_delivered':
        return const Color(0xFF721C24);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'dispatched_rider':
        return 'New Order';
      case 'picked':
        return 'Picked Up';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'not_delivered':
        return 'Not Delivered';
      default:
        return status;
    }
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Delivery Status',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 16),
            _StatusOption(
              label: 'Mark as In Transit',
              icon: Icons.local_shipping_outlined,
              color: Colors.blue.shade50,
              iconColor: Colors.blue.shade600,
              onTap: () async {
                Navigator.pop(context);
                await service.updateDeliveryStatus(
                    order.orderId, 'in_transit', null);
              },
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'Mark as Delivered',
              icon: Icons.check_circle_outline,
              color: const Color(0xFFE8F5E9),
              iconColor: Colors.green.shade600,
              onTap: () async {
                Navigator.pop(context);
                await service.updateDeliveryStatus(
                    order.orderId, 'delivered', null);
              },
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'Not Delivered',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFF8D7DA),
              iconColor: const Color(0xFF721C24),
              onTap: () {
                Navigator.pop(context);
                _showNotDeliveredDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotDeliveredDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reason for Non-delivery',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xff5E1D04))),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter reason...',
            hintStyle: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade400),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffD08C4A)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.updateDeliveryStatus(
                  order.orderId, 'not_delivered', reasonCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5E1D04),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Submit',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.orderId,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5E1D04))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.orderStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel(order.orderStatus),
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _statusTextColor(order.orderStatus))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(
                icon: Icons.person_outline,
                label: order.buyerName,
                sub: order.buyerPhone),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.location_on_outlined,
                label: order.buyerAddress),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.payments_outlined,
                label: 'Rs ${order.totalAmount.toStringAsFixed(0)}',
                sub: 'Cash on Delivery'),
            if (showAcceptReject) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          service.rejectOrder(order.orderId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF721C24),
                        side: const BorderSide(
                            color: Color(0xFF721C24), width: 0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Reject',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () =>
                          service.acceptOrder(order.orderId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD08C4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text('Accept & Pick Up',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
            if (showUpdateStatus) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateStatusDialog(context),
                  icon: const Icon(Icons.update_rounded, size: 18),
                  label: Text('Update Delivery Status',
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E1D04),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;

  const _InfoRow({required this.icon, required this.label, this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xffD08C4A)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade700),
              children: sub != null
                  ? [
                TextSpan(
                    text: ' • $sub',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade400))
              ]
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff5E1D04))),
          ],
        ),
      ),
    );
  }
}