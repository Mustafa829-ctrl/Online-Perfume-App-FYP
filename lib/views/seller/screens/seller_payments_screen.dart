import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';

import '../../../services/order_service.dart';

class SellerPaymentsScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerPaymentsScreen({super.key, required this.seller});

  @override
  State<SellerPaymentsScreen> createState() => _SellerPaymentsScreenState();
}

class _SellerPaymentsScreenState extends State<SellerPaymentsScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();

  late TabController _tabController;

  bool isLoading = false;
  String _selectedPeriod = 'Monthly';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  // All payments (buyerPaymentStatus == 'Received')
  List<OrderModel> _allPayments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() => isLoading = true);
      final payments = await _orderService.getSellerPayments(
        widget.seller.docId ?? '',
      );
      setState(() {
        _allPayments = payments;
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

  // ── Period filter by deliveredAt (matches rider screen logic)
  List<OrderModel> _filterByPeriod(List<OrderModel> list) {
    final now = DateTime.now();
    return list.where((o) {
      if (o.deliveredAt == null) return false;
      final date = DateTime.fromMillisecondsSinceEpoch(o.deliveredAt!);
      switch (_selectedPeriod) {
        case 'Daily':
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case 'Weekly':
          return date.isAfter(now.subtract(const Duration(days: 7)));
        case 'Monthly':
          return date.year == now.year && date.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  // ── Rider payments (deliveryType == 'Rider' or null — legacy orders)
  List<OrderModel> get _riderPayments =>
      _filterByPeriod(_allPayments.where((o) => (o.deliveryType ?? 'Rider') == 'Rider').toList());

  // ── Courier payments (deliveryType == 'Courier')
  List<OrderModel> get _courierPayments =>
      _filterByPeriod(_allPayments.where((o) => o.deliveryType == 'Courier').toList());

  // ── Summary helpers
  int _totalAmount(List<OrderModel> list)   => list.fold(0, (s, o) => s + (o.amount ?? 0));
  int _pendingAmount(List<OrderModel> list) => list.where((o) => (o.riderPaymentStatus ?? 'Pending') == 'Pending').fold(0, (s, o) => s + (o.amount ?? 0));
  int _clearedAmount(List<OrderModel> list) => list.where((o) => o.riderPaymentStatus == 'Cleared').fold(0, (s, o) => s + (o.amount ?? 0));
  int _pendingCount(List<OrderModel> list)  => list.where((o) => (o.riderPaymentStatus ?? 'Pending') == 'Pending').length;

  // ── Clear rider payment
  Future<void> _clearRiderPayment(OrderModel order) async {
    try {
      await _orderService.clearRiderPayment(order.docId ?? '');
      await _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment cleared — order marked Completed', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xff66BB6A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
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

  // ── Clear courier payment
  Future<void> _clearCourierPayment(OrderModel order) async {
    try {
      await _orderService.clearCourierPayment(order.docId ?? '');
      await _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Courier remittance confirmed — order marked Completed', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xff66BB6A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
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

  // ── Confirm dialog (shared for both rider and courier)
  void _showClearDialog({
    required OrderModel order,
    required bool isCourier,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isCourier ? 'Confirm Remittance' : 'Clear Payment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCourier
                  ? 'Confirm remittance received from courier:'
                  : 'Confirm cash received from rider:',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCourier ? (order.courierName ?? '') : (order.riderName ?? ''),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)),
                  ),
                  if (isCourier && (order.trackingNumber ?? '').isNotEmpty)
                    Text('Tracking: ${order.trackingNumber}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  Text(order.orderId ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text('Rs ${order.amount ?? 0}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isCourier) {
                _clearCourierPayment(order);
              } else {
                _clearRiderPayment(order);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff66BB6A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Confirm', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final riderList   = _riderPayments;
    final courierList = _courierPayments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xff5E1D04), size: 20),
        ),
        title: Text('Payments', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xffD08C4A),
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: const Color(0xffD08C4A),
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: [
            Tab(text: 'Riders (${_riderPayments.length})'),
            Tab(text: 'Couriers (${_courierPayments.length})'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : RefreshIndicator(
        color: const Color(0xffD08C4A),
        onRefresh: _loadPayments,
        child: Column(
          children: [
            // ── Period selector + summary (shared for both tabs)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  // Period selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: _periods.map((period) {
                            final isSelected = _selectedPeriod == period;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = period),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xffD08C4A) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(period, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey.shade500)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Summary cards — reflect current tab
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (_, __) {
                      final list = _tabController.index == 0 ? riderList : courierList;
                      return Row(children: [
                        Expanded(child: _SummaryCard(label: 'Total',   amount: _totalAmount(list),   color: const Color(0xff5E1D04), bgColor: const Color(0xFFFFF3CD), icon: Icons.payments_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _SummaryCard(label: 'Pending', amount: _pendingAmount(list), color: const Color(0xffFFA726), bgColor: const Color(0xFFFFF8E1), icon: Icons.hourglass_empty_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _SummaryCard(label: 'Cleared', amount: _clearedAmount(list), color: const Color(0xff66BB6A), bgColor: const Color(0xFFE8F5E9), icon: Icons.check_circle_outline)),
                      ]);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Pending alert — reflect current tab
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (_, __) {
                      final list    = _tabController.index == 0 ? riderList : courierList;
                      final pending = _pendingCount(list);
                      final label   = _tabController.index == 0
                          ? '$pending payment(s) pending collection from riders'
                          : '$pending remittance(s) pending from couriers';
                      if (pending == 0) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffFFA726).withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline, color: Color(0xffFFA726), size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xffFFA726), fontWeight: FontWeight.w500))),
                        ]),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── RIDERS TAB
                  _PaymentList(
                    orders: riderList,
                    isCourier: false,
                    emptyMessage: 'No rider payments for this period',
                    formatDate: _formatDate,
                    onClear: (order) => _showClearDialog(order: order, isCourier: false),
                  ),

                  // ── COURIERS TAB
                  _PaymentList(
                    orders: courierList,
                    isCourier: true,
                    emptyMessage: 'No courier payments for this period',
                    formatDate: _formatDate,
                    onClear: (order) => _showClearDialog(order: order, isCourier: true),
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

// ── Payment List (used by both tabs)
class _PaymentList extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isCourier;
  final String emptyMessage;
  final String Function(int?) formatDate;
  final void Function(OrderModel) onClear;

  const _PaymentList({
    required this.orders,
    required this.isCourier,
    required this.emptyMessage,
    required this.formatDate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyMessage, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _PaymentTile(
          order: order,
          isCourier: isCourier,
          formatDate: formatDate,
          onClear: (order.riderPaymentStatus ?? 'Pending') == 'Pending'
              ? () => onClear(order)
              : null,
        );
      },
    );
  }
}

// ── Summary Card
class _SummaryCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text('Rs $amount', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ── Payment Tile
class _PaymentTile extends StatelessWidget {
  final OrderModel order;
  final bool isCourier;
  final String Function(int?) formatDate;
  final VoidCallback? onClear;

  const _PaymentTile({
    required this.order,
    required this.isCourier,
    required this.formatDate,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = (order.riderPaymentStatus ?? 'Pending') == 'Pending';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPending ? const Color(0xffFFA726).withOpacity(0.3) : const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + payment status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderId ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Cleared',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isPending ? const Color(0xffFFA726) : const Color(0xff66BB6A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Buyer + product
          Row(children: [
            const Icon(Icons.person_outline, size: 13, color: Color(0xffD08C4A)),
            const SizedBox(width: 5),
            Text(order.buyerName ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(width: 10),
            const Icon(Icons.local_florist_outlined, size: 13, color: Color(0xffD08C4A)),
            const SizedBox(width: 5),
            Expanded(child: Text(order.productName ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),

          // Delivery info box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCourier ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(
                isCourier ? Icons.local_shipping_outlined : Icons.delivery_dining_outlined,
                size: 16,
                color: isCourier ? const Color(0xff42A5F5) : const Color(0xffD08C4A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCourier ? (order.courierName ?? '') : (order.riderName ?? ''),
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)),
                    ),
                    if (isCourier && (order.trackingNumber ?? '').isNotEmpty)
                      Text('Tracking: ${order.trackingNumber}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  isCourier ? 'Courier' : 'Rider',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: isCourier ? const Color(0xff42A5F5) : const Color(0xffD08C4A)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),

          // Amount + date + clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rs ${order.amount ?? 0}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                  Text(
                    isPending
                        ? 'Delivered: ${formatDate(order.deliveredAt)}'
                        : 'Cleared: ${formatDate(order.clearedAt)}',
                    style: GoogleFonts.poppins(fontSize: 10, color: isPending ? const Color(0xffFFA726) : Colors.grey.shade400),
                  ),
                ],
              ),
              Row(children: [
                // COD badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(6)),
                  child: Text('COD', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xffD08C4A))),
                ),
                // Clear button (only for pending)
                if (isPending && onClear != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xff66BB6A), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        isCourier ? 'Confirm' : 'Clear',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ]),
            ],
          ),
        ],
      ),
    );
  }
}