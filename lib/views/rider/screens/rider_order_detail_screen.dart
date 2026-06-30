import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../views/admin/widgets/info_row.dart';

class RiderOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const RiderOrderDetailScreen({super.key, required this.order});

  @override
  State<RiderOrderDetailScreen> createState() =>
      _RiderOrderDetailScreenState();
}

class _RiderOrderDetailScreenState extends State<RiderOrderDetailScreen> {
  final OrderService _orderService = OrderService();
  bool isLoading = false;
  late OrderModel _currentOrder;
  StreamSubscription<OrderModel>? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _listenToOrder();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  // Real-time stream — order updates live
  void _listenToOrder() {
    _orderSubscription = _orderService
        .getOrderStream(_currentOrder.docId!)
        .listen((updatedOrder) {
      if (mounted) setState(() => _currentOrder = updatedOrder);
    });
  }

  // ── Status color
  Color _statusColor(String? status) {
    switch (status) {
      case 'Dispatched':     return const Color(0xffFFA726);
      case 'Accepted':     return const Color(0xffD08C4A);
      case 'Picked':       return const Color(0xff42A5F5);
      case 'In Transit':   return const Color(0xff7E57C2);
      case 'Delivered':    return const Color(0xff66BB6A);
      case 'Not Delivered':return const Color(0xffEF5350);
      default:             return Colors.grey;
    }
  }

  // ── Accept order
  Future<void> _acceptOrder() async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.acceptOrder(_currentOrder.docId!);
      isLoading = false;
      setState(() {});
      _showSuccess('Order accepted successfully');
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Reject order
  Future<void> _rejectOrder() async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.rejectOrder(_currentOrder.docId!);
      isLoading = false;
      setState(() {});
      if (mounted) Navigator.pop(context);
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Pick up delivery
  Future<void> _pickDelivery() async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.pickDelivery(_currentOrder.docId!);
      isLoading = false;
      setState(() {});
      _showSuccess('Order picked up');
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Start delivery (In Transit)
  Future<void> _startDelivery() async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.markInTransit(_currentOrder.docId!);
      isLoading = false;
      setState(() {});
      _showSuccess('Order is now in transit');
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Mark delivered
  Future<void> _markDelivered() async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.markDelivered(_currentOrder.docId!);
      isLoading = false;
      setState(() {});
      _showSuccess('Order marked as delivered');
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Mark not delivered
  Future<void> _markNotDelivered(String reason) async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.markNotDelivered(
        docId: _currentOrder.docId!,
        reason: reason,
      );
      isLoading = false;
      setState(() {});
      _showSuccess('Order marked as not delivered');
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Confirm COD received from buyer
  Future<void> _confirmBuyerPayment() async {
    try {
      isLoading = true;
      setState(() {});
      await _orderService.markBuyerPaymentReceived(_currentOrder.docId!);
      isLoading = false;
      setState(() {});
      _showSuccess('payment received');
    } catch (e) {
      isLoading = false;
      setState(() {});
      _showError(e.toString());
    }
  }

  // ── Reject dialog
  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Order',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
        ),
        content: Text(
          'Are you sure you want to reject this order?',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Reject',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Not delivered dialog
  void _showNotDeliveredDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Not Delivered',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason:',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Buyer not available...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Color(0xFFEEEEEE))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Color(0xFFEEEEEE))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Color(0xffD08C4A))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              _markNotDelivered(reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Confirm',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── COD confirm dialog
  void _showCODConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Payment',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm you have received Rs ${_currentOrder.amount ?? 0} cash from the buyer?',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Rs ${_currentOrder.amount ?? 0}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmBuyerPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff66BB6A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Yes, Received',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: const Color(0xffD08C4A),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentOrder.status ?? 'Dispatched';
    final statusColor = _statusColor(status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentOrder.orderId ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Customer Details
            _SectionTitle(title: 'Customer Details'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              InfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: _currentOrder.buyerName ?? ''),
              InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _currentOrder.buyerPhone ?? ''),
              InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _currentOrder.buyerAddress ?? ''),
            ]),
            const SizedBox(height: 20),

            // ── Order Summary
            _SectionTitle(title: 'Order Summary'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              // If multi-item order, show items list
              if (_currentOrder.items != null &&
                  _currentOrder.items!.isNotEmpty) ...[
                ..._currentOrder.items!.map((item) => InfoRow(
                  icon: Icons.local_florist_outlined,
                  label: item['productName'] ?? '',
                  value:
                  'x${item['quantity']} — Rs ${item['amount']}',
                )),
                InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Total',
                    value: 'Rs ${_currentOrder.amount ?? 0}'),
              ] else ...[
                InfoRow(
                    icon: Icons.local_florist_outlined,
                    label: 'Product',
                    value: _currentOrder.productName ?? ''),
                InfoRow(
                    icon: Icons.numbers_outlined,
                    label: 'Quantity',
                    value: '${_currentOrder.quantity ?? 1}'),
                InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Amount',
                    value: 'Rs ${_currentOrder.amount ?? 0}'),
              ],
              InfoRow(
                  icon: Icons.money_outlined,
                  label: 'Payment',
                  value: 'Cash on Delivery'),
            ]),
            const SizedBox(height: 20),

            // ── Seller Details
            _SectionTitle(title: 'Seller Details'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              InfoRow(
                  icon: Icons.storefront_outlined,
                  label: 'Seller',
                  value: _currentOrder.sellerName ?? ''),
              InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _currentOrder.sellerPhone ?? ''),
            ]),
            const SizedBox(height: 20),

            // ── Order Timeline
            _SectionTitle(title: 'Order Timeline'),
            const SizedBox(height: 10),
            _StatusTimeline(currentStatus: status),
            const SizedBox(height: 24),

            // ── Payment Status Banner
            if (status == 'Delivered') ...[
              _currentOrder.buyerPaymentStatus == 'Received'
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xff66BB6A), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Confirmed',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff66BB6A),
                          ),
                        ),
                        Text(
                          'Waiting for seller to confirm receipt from you',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
                  : _ActionButton(
                label: 'Confirm payment Received from Buyer',
                icon: Icons.payments_outlined,
                color: const Color(0xff66BB6A),
                onTap: _showCODConfirmDialog,
              ),
              const SizedBox(height: 10),
            ],

            // ── riderPaymentStatus banner
            if (_currentOrder.riderPaymentStatus == 'Cleared') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.verified,
                      color: Color(0xff66BB6A), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Payment Cleared by Seller',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff66BB6A),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],

            // ── Action Buttons
            if (status == 'Dispatched') ...[
              _ActionButton(
                label: 'Accept Order',
                icon: Icons.check_circle_outline,
                color: const Color(0xff66BB6A),
                onTap: _acceptOrder,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Reject Order',
                icon: Icons.cancel_outlined,
                color: Colors.red.shade400,
                onTap: _showRejectDialog,
              ),
            ],

            if (status == 'Accepted')
              _ActionButton(
                label: 'Pick Up Delivery',
                icon: Icons.inventory_outlined,
                color: const Color(0xff42A5F5),
                onTap: _pickDelivery,
              ),

            if (status == 'Picked')
              _ActionButton(
                label: 'Start Delivery',
                icon: Icons.delivery_dining_outlined,
                color: const Color(0xff7E57C2),
                onTap: _startDelivery,
              ),

            if (status == 'In Transit') ...[
              _ActionButton(
                label: 'Mark as Delivered',
                icon: Icons.check_circle_outline,
                color: const Color(0xff66BB6A),
                onTap: _markDelivered,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Not Delivered',
                icon: Icons.cancel_outlined,
                color: Colors.red.shade400,
                onTap: _showNotDeliveredDialog,
              ),
            ],

            if (status == 'Not Delivered')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.cancel_outlined,
                      color: Colors.red.shade400, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Not Delivered: ${_currentOrder.notDeliveredReason ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ]),
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
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xff5E1D04),
      ),
    );
  }
}

// ── Info Card
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: children
            .expand((w) => [
          w,
          if (w != children.last)
            Divider(color: Colors.grey.shade200, height: 16),
        ])
            .toList(),
      ),
    );
  }
}
// ── Status Timeline
class _StatusTimeline extends StatelessWidget {
  final String currentStatus;
  const _StatusTimeline({required this.currentStatus});

  static const List<String> _steps = [
    'Dispatched',
    'Accepted',
    'Picked',
    'In Transit',
    'Delivered',
  ];

  bool _isCompleted(String step) {
    final currentIndex = _steps.indexOf(currentStatus);
    final stepIndex = _steps.indexOf(step);
    if (currentIndex == -1) return false;
    return stepIndex <= currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: _steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = _isCompleted(step);
          final isLast = index == _steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xffD08C4A)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      size: isCompleted ? 14 : 8,
                      color: isCompleted
                          ? Colors.white
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28,
                      color: isCompleted
                          ? const Color(0xffD08C4A)
                          : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  step,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isCompleted
                        ? const Color(0xff5E1D04)
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Action Button
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
        required this.icon,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}