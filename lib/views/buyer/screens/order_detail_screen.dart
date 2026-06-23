import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/product_details.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  static const int _cancelWindowSeconds = 15 * 60;

  late OrderModel _order;
  bool isUpdating = false;
  bool isReordering = false;

  // ── Cancel countdown (based on real createdAt)
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canStillCancel = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _initCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initCountdown() {
    if (_order.status != 'Pending' || _order.createdAt == null) return;

    final elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - _order.createdAt!) / 1000).round();
    final remaining = _cancelWindowSeconds - elapsedSeconds;

    if (remaining <= 0) {
      setState(() => _canStillCancel = false);
      return;
    }

    setState(() {
      _remainingSeconds = remaining;
      _canStillCancel = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        setState(() {
          _remainingSeconds = 0;
          _canStillCancel = false;
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: isError ? Colors.red.shade400 : const Color(0xffD08C4A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Cancel order (within window)
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Order?',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        content: Text('Are you sure you want to cancel this order?',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Order', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Yes, Cancel', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder() async {
    try {
      setState(() => isUpdating = true);
      await _orderService.cancelOrder(orderId: _order.docId ?? '', reason: 'Cancelled by buyer');
      _timer?.cancel();
      setState(() {
        _order = OrderModel.fromJson({..._order.toJson(_order.docId ?? ''), 'status': 'Cancelled'});
        isUpdating = false;
        _canStillCancel = false;
      });
      _showSnackBar('Order cancelled successfully');
    } catch (e) {
      setState(() => isUpdating = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  // ── Return request
  void _showReturnSheet() {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Request Return', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
            const SizedBox(height: 6),
            Text('Please tell us why you want to return this product', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Wrong item received, damaged product...',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffD08C4A))),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.trim().isEmpty) {
                    _showSnackBar('Please provide a reason', isError: true);
                    return;
                  }
                  Navigator.pop(context);
                  try {
                    setState(() => isUpdating = true);
                    await _orderService.submitReturnRequest(docId: _order.docId ?? '', reason: reasonController.text.trim());
                    setState(() {
                      _order = OrderModel.fromJson({..._order.toJson(_order.docId ?? ''), 'status': 'Returned', 'returnReason': reasonController.text.trim()});
                      isUpdating = false;
                    });
                    _showSnackBar('Return request submitted');
                  } catch (e) {
                    setState(() => isUpdating = false);
                    _showSnackBar(e.toString(), isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffD08C4A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: Text('Submit Return Request', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reorder
  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reorder Product?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        content: Text('This will place a new order for ${_order.productName} x${_order.quantity ?? 1}.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reorder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffD08C4A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Reorder', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _reorder() async {
    try {
      setState(() => isReordering = true);
      await _orderService.reorderItem(originalOrder: _order);
      setState(() => isReordering = false);
      _showSnackBar('New order placed successfully!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => isReordering = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  // ── Write review — navigate to product detail screen
  Future<void> _navigateToWriteReview() async {
    try {
      setState(() => isUpdating = true);
      final product = await _productService.getProductById(_order.productId ?? '');
      setState(() => isUpdating = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetails(
              product: product,
              isLoggedIn: true,
              onLoginRequired: () {},
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isUpdating = false);
      _showSnackBar('Could not load product details', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_order.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xff5E1D04), size: 20),
        ),
        title: Text('Order Details',
            style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: isUpdating
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_order.orderId ?? '',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(_order.status ?? '',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(_formatDate(_order.createdAt), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400)),
            const SizedBox(height: 20),

            // ── Cancel countdown (only if Pending and within window)
            if (_order.status == 'Pending' && _canStillCancel) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Row(children: [
                      const Icon(Icons.timer_outlined, color: Color(0xffD08C4A), size: 18),
                      const SizedBox(width: 8),
                      Text('Cancel within $_formattedTime',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showCancelDialog,
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                        label: Text('Cancel Order', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red.shade600)),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (_order.status == 'Pending' && !_canStillCancel) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Cancellation window has passed', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500))),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            // ── Order Summary
            const _SectionTitle(title: 'Order Summary'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              _InfoRow(icon: Icons.local_florist_outlined, label: 'Product', value: _order.productName ?? ''),
              _InfoRow(icon: Icons.numbers_outlined, label: 'Quantity', value: '${_order.quantity ?? 1}'),
              _InfoRow(icon: Icons.payments_outlined, label: 'Amount', value: 'Rs ${_order.amount ?? 0}'),
              _InfoRow(icon: Icons.money_outlined, label: 'Payment', value: 'Cash on Delivery'),
            ]),
            const SizedBox(height: 20),

            // ── Delivery Info
            const _SectionTitle(title: 'Delivery Address'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: _order.buyerAddress ?? ''),
            ]),
            const SizedBox(height: 20),

            // ── Tracking info — only when dispatched/delivered
            if (_order.status == 'Dispatched' || _order.status == 'Delivered') ...[
              const _SectionTitle(title: 'Tracking Info'),
              const SizedBox(height: 10),
              _InfoCard(children: [
                if ((_order.deliveryType ?? 'Rider') == 'Rider') ...[
                  if ((_order.riderName ?? '').isNotEmpty)
                    _InfoRow(icon: Icons.delivery_dining_outlined, label: 'Rider', value: _order.riderName ?? ''),
                ] else ...[
                  if ((_order.courierName ?? '').isNotEmpty)
                    _InfoRow(icon: Icons.local_shipping_outlined, label: 'Courier', value: _order.courierName ?? ''),
                  if ((_order.trackingNumber ?? '').isNotEmpty)
                    _InfoRow(icon: Icons.confirmation_number_outlined, label: 'Tracking', value: _order.trackingNumber ?? ''),
                ],
              ]),
              const SizedBox(height: 20),
            ],

            // ── Issue reason (Not Delivered / Returned)
            if (_order.status == 'Not Delivered' && (_order.notDeliveredReason ?? '').isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(12)),
                child: Text('Reason: ${_order.notDeliveredReason}',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.red.shade400)),
              ),
              const SizedBox(height: 20),
            ],
            if (_order.status == 'Returned' && (_order.returnReason ?? '').isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                child: Text('Return reason: ${_order.returnReason}',
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xff0D47A1))),
              ),
              const SizedBox(height: 20),
            ],

            // ── Actions per status
            if (_order.status == 'Delivered') ...[
              const _SectionTitle(title: 'Actions'),
              const SizedBox(height: 10),
              _ActionButton(label: 'Write a Review', icon: Icons.rate_review_outlined, color: const Color(0xffD08C4A), onTap: _navigateToWriteReview),
              const SizedBox(height: 10),
              _ActionButton(label: 'Request Return', icon: Icons.assignment_return_outlined, color: const Color(0xff7E57C2), onTap: _showReturnSheet),
              const SizedBox(height: 10),
            ],

            if (_order.status == 'Cancelled' || _order.status == 'Returned' || _order.status == 'Not Delivered') ...[
              const _SectionTitle(title: 'Actions'),
              const SizedBox(height: 10),
              _ActionButton(
                label: isReordering ? 'Placing order...' : 'Reorder',
                icon: Icons.replay_outlined,
                color: const Color(0xff66BB6A),
                onTap: isReordering ? () {} : _showReorderDialog,
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Widgets
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) =>
      Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)));
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(children: children.expand((w) => [w, if (w != children.last) Divider(color: Colors.grey.shade200, height: 16)]).toList()),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: const Color(0xffD08C4A)),
      const SizedBox(width: 10),
      SizedBox(width: 70, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500))),
      Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xff5E1D04)))),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}