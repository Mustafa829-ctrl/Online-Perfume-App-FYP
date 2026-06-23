import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order_model.dart';
import '../../../models/rider_model.dart';
import '../../../services/order_service.dart';

class RiderPaymentsScreen extends StatefulWidget {
  final RiderModel rider;
  const RiderPaymentsScreen({super.key, required this.rider});

  @override
  State<RiderPaymentsScreen> createState() => _RiderPaymentsScreenState();
}

class _RiderPaymentsScreenState extends State<RiderPaymentsScreen> {
  final OrderService _orderService = OrderService();

  bool isLoading = false;
  bool isConfirming = false;
  List<OrderModel> deliveredOrders = [];
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      isLoading = true;
      setState(() {});

      String riderId = widget.rider.docId ?? '';

      deliveredOrders = await _orderService.getAllDeliveredOrders(riderId);

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── Confirm payment received from buyer
  Future<void> _confirmPaymentReceived(OrderModel order) async {
    try {
      setState(() => isConfirming = true);
      await _orderService.markBuyerPaymentReceived(order.docId ?? '');
      await loadPayments();
      setState(() => isConfirming = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment confirmed for ${order.orderId}',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xff66BB6A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() => isConfirming = false);
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
    final now = DateTime.now();
    return deliveredOrders.where((o) {
      if (o.deliveredAt == null) return false;
      final date = DateTime.fromMillisecondsSinceEpoch(o.deliveredAt!);
      switch (_selectedPeriod) {
        case 'Daily':
          return date.day == now.day && date.month == now.month && date.year == now.year;
        case 'Weekly':
          final weekAgo = now.subtract(const Duration(days: 7));
          return date.isAfter(weekAgo);
        case 'Monthly':
          return date.month == now.month && date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  int get _totalAmount => _filteredOrders.fold(0, (sum, o) => sum + (o.amount ?? 0));

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
        : RefreshIndicator(
      color: const Color(0xffD08C4A),
      onRefresh: loadPayments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _PeriodSelector(
                  periods: _periods,
                  selected: _selectedPeriod,
                  onSelect: (p) => setState(() => _selectedPeriod = p),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _TotalCard(
              amount: _totalAmount,
              count: _filteredOrders.length,
              period: _selectedPeriod,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Deliveries',
                    value: '${deliveredOrders.length}',
                    icon: Icons.delivery_dining_outlined,
                    color: const Color(0xffD08C4A),
                    bgColor: const Color(0xFFFFF3CD),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Collected',
                    value: 'Rs ${deliveredOrders.fold(0, (s, o) => s + (o.amount ?? 0))}',
                    icon: Icons.payments_outlined,
                    color: const Color(0xff66BB6A),
                    bgColor: const Color(0xFFE8F5E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              '$_selectedPeriod Collections',
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 12),

            _filteredOrders.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(Icons.payments_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No collections for this period',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            )
                : Column(
              children: _filteredOrders
                  .map((o) => _PaymentTile(
                order: o,
                isConfirming: isConfirming,
                onConfirm: () => _confirmPaymentReceived(o),
              ))
                  .toList(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Period Selector
class _PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final String selected;
  final Function(String) onSelect;

  const _PeriodSelector({
    required this.periods,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = selected == period;
          return GestureDetector(
            onTap: () => onSelect(period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xffD08C4A) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Total Card
class _TotalCard extends StatelessWidget {
  final int amount;
  final int count;
  final String period;

  const _TotalCard({
    required this.amount,
    required this.count,
    required this.period,
  });

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
                  '$period COD Collected',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
                ),
                Text(
                  'Rs $amount',
                  style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '$count orders delivered',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
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
            child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

// ── Summary Card
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Tile — with Confirm Payment button
class _PaymentTile extends StatelessWidget {
  final OrderModel order;
  final bool isConfirming;
  final VoidCallback onConfirm;

  const _PaymentTile({
    required this.order,
    required this.isConfirming,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = (order.buyerPaymentStatus ?? 'Pending') == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPending ? const Color(0xffFFA726).withOpacity(0.3) : const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPending ? Icons.hourglass_empty_outlined : Icons.check_circle_outline,
                  color: isPending ? const Color(0xffFFA726) : const Color(0xff66BB6A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderId ?? '',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)),
                    ),
                    Text(
                      order.buyerName ?? '',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    if (order.deliveredAt != null)
                      Text(
                        _formatDate(order.deliveredAt!),
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
                      ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${order.amount ?? 0}',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      'COD',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xffD08C4A)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Confirm Payment button — only shown if buyerPaymentStatus is still Pending
          if (isPending) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: isConfirming ? null : onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff66BB6A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: isConfirming
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  'Confirm Payment Received',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  'Payment Confirmed ✓',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xff66BB6A)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}