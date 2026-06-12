import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const SellerOrderDetailScreen({super.key, required this.order});

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final OrderService _orderService = OrderService();

  bool isUpdating = false;
  late String _currentStatus;
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _currentStatus = widget.order.status ?? 'Pending';
  }

  Color _statusColor(String status) {
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

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  Future<void> _updateStatus(String newStatus, {Map<String, dynamic>? extra}) async {
    try {
      setState(() => isUpdating = true);

      await _orderService.updateOrderStatus(
        orderId:        _order.docId ?? '',
        status:         newStatus,
        riderName:      extra?['riderName'],
        riderId:        extra?['riderId'],
        deliveryType:   extra?['deliveryType'],
        courierName:    extra?['courierName'],
        trackingNumber: extra?['trackingNumber'],
      );

      setState(() {
        _currentStatus = newStatus;
        isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order status updated to $newStatus',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xffD08C4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() => isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Dispatch to Rider sheet
  void _showDispatchToRiderSheet() {
    final riderNameController  = TextEditingController();
    final riderPhoneController = TextEditingController();
    final bikeNumberController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Dispatch to Rider',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 16),
            _SheetInputField(
                controller: riderNameController,
                hint: 'Rider Name',
                icon: Icons.person_outline),
            const SizedBox(height: 12),
            _SheetInputField(
                controller: riderPhoneController,
                hint: 'Rider Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _SheetInputField(
                controller: bikeNumberController,
                hint: 'Bike / Vehicle Number',
                icon: Icons.two_wheeler_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (riderNameController.text.isNotEmpty &&
                      riderPhoneController.text.isNotEmpty) {
                    Navigator.pop(context);
                    //  deliveryType: 'Rider' now passed
                    _updateStatus('Dispatched', extra: {
                      'riderName':    riderNameController.text.trim(),
                      'riderId':      '',
                      'deliveryType': 'Rider',
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please fill rider name and phone',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: Text('Assign Rider',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dispatch to Courier sheet
  void _showDispatchToCourierSheet() {
    final courierNameController    = TextEditingController();
    final trackingNumberController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Dispatch to Courier',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 6),
            Text('Buyer Details (will be shared with courier)',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            // Buyer info box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_order.buyerName ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04))),
                  Text(_order.buyerPhone ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600)),
                  Text(_order.buyerAddress ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SheetInputField(
                controller: courierNameController,
                hint: 'Courier Service (e.g. TCS, Leopards)',
                icon: Icons.local_shipping_outlined),
            const SizedBox(height: 12),
            _SheetInputField(
                controller: trackingNumberController,
                hint: 'Tracking Number',
                icon: Icons.confirmation_number_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (courierNameController.text.isNotEmpty &&
                      trackingNumberController.text.isNotEmpty) {
                    Navigator.pop(context);
                    //  all courier fields correctly passed
                    _updateStatus('Dispatched', extra: {
                      'deliveryType':    'Courier',
                      'courierName':     courierNameController.text.trim(),
                      'trackingNumber':  trackingNumberController.text.trim(),
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please fill all courier details',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: Text('Dispatch via Courier',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Not Delivered sheet
  void _showNotDeliveredSheet() {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Not Delivered',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 6),
            Text('Please provide a reason for non-delivery',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Buyer not available, Wrong address...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xFFEEEEEE))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xFFEEEEEE))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xffD08C4A))),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.isNotEmpty) {
                    Navigator.pop(context);
                    try {
                      setState(() => isUpdating = true);
                      await _orderService.cancelOrder(
                        orderId: _order.docId ?? '',
                        reason: reasonController.text.trim(),
                      );
                      setState(() {
                        _currentStatus = 'Cancelled';
                        isUpdating = false;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text('Order marked as not delivered',
                              style:
                              GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: Colors.red.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                        ));
                      }
                    } catch (e) {
                      setState(() => isUpdating = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(e.toString(),
                              style:
                              GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: Colors.red.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                        ));
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: Text('Confirm Not Delivered',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_currentStatus);

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
        title: Text('Order Details',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: isUpdating
          ? const Center(
          child: CircularProgressIndicator(
              color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_order.orderId ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04))),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_currentStatus,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(_formatDate(_order.createdAt),
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400)),
            const SizedBox(height: 20),

            // Customer Details
            const _SectionTitle(title: 'Customer Details'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: _order.buyerName ?? ''),
              _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _order.buyerPhone ?? ''),
              _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _order.buyerAddress ?? ''),
            ]),
            const SizedBox(height: 20),

            // Order Summary
            const _SectionTitle(title: 'Order Summary'),
            const SizedBox(height: 10),
            _InfoCard(children: [
              _InfoRow(
                  icon: Icons.local_florist_outlined,
                  label: 'Product',
                  value: _order.productName ?? ''),
              _InfoRow(
                  icon: Icons.numbers_outlined,
                  label: 'Quantity',
                  value: '${_order.quantity ?? 1}'),
              _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Amount',
                  value: 'Rs ${_order.amount ?? 0}'),
              _InfoRow(
                  icon: Icons.money_outlined,
                  label: 'Payment',
                  value: 'Cash on Delivery'),
            ]),
            const SizedBox(height: 20),

            // Dispatch info (shows rider OR courier depending on deliveryType)
            if (_currentStatus == 'Dispatched' ||
                _currentStatus == 'Delivered') ...[
              const _SectionTitle(title: 'Dispatch Info'),
              const SizedBox(height: 10),
              _InfoCard(children: [
                if ((_order.deliveryType ?? 'Rider') == 'Rider') ...[
                  _InfoRow(
                      icon: Icons.delivery_dining_outlined,
                      label: 'Via',
                      value: 'Rider'),
                  if ((_order.riderName ?? '').isNotEmpty)
                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Rider',
                        value: _order.riderName ?? ''),
                ] else ...[
                  _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Via',
                      value: 'Courier'),
                  if ((_order.courierName ?? '').isNotEmpty)
                    _InfoRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Courier',
                        value: _order.courierName ?? ''),
                  if ((_order.trackingNumber ?? '').isNotEmpty)
                    _InfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Tracking',
                        value: _order.trackingNumber ?? ''),
                ],
              ]),
              const SizedBox(height: 20),
            ],

            // Timeline
            const _SectionTitle(title: 'Order Timeline'),
            const SizedBox(height: 10),
            _OrderTimeline(currentStatus: _currentStatus),
            const SizedBox(height: 24),

            // Actions
            if (_currentStatus == 'Pending') ...[
              const _SectionTitle(title: 'Actions'),
              const SizedBox(height: 10),
              _ActionButton(
                  label: 'Start Processing',
                  icon: Icons.play_circle_outline,
                  color: const Color(0xff42A5F5),
                  onTap: () => _updateStatus('Processing')),
              const SizedBox(height: 10),
            ],

            if (_currentStatus == 'Processing') ...[
              const _SectionTitle(title: 'Dispatch Options'),
              const SizedBox(height: 10),
              _ActionButton(
                  label: 'Dispatch to Rider',
                  icon: Icons.delivery_dining_outlined,
                  color: const Color(0xffD08C4A),
                  onTap: _showDispatchToRiderSheet),
              const SizedBox(height: 10),
              _ActionButton(
                  label: 'Dispatch to Courier',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xff5E1D04),
                  onTap: _showDispatchToCourierSheet),
              const SizedBox(height: 10),
            ],

            if (_currentStatus == 'Dispatched') ...[
              const _SectionTitle(title: 'Update Delivery'),
              const SizedBox(height: 10),
              _ActionButton(
                  label: 'Mark as Delivered',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xff66BB6A),
                  onTap: () => _updateStatus('Delivered')),
              const SizedBox(height: 10),
              _ActionButton(
                  label: 'Not Delivered',
                  icon: Icons.cancel_outlined,
                  color: Colors.red.shade400,
                  onTap: _showNotDeliveredSheet),
              const SizedBox(height: 10),
            ],

            if (_currentStatus == 'Delivered') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xff66BB6A), size: 22),
                  const SizedBox(width: 10),
                  Text('Order delivered successfully',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff66BB6A))),
                ]),
              ),
              const SizedBox(height: 10),
            ],

            if (_currentStatus == 'Cancelled') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.cancel_outlined,
                      color: Colors.red.shade400, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (_order.notDeliveredReason ?? '').isNotEmpty
                          ? 'Cancelled: ${_order.notDeliveredReason}'
                          : 'Order cancelled',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade400),
                    ),
                  ),
                ]),
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
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xff5E1D04)));
}

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
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(
        children: children
            .expand((w) => [
          w,
          if (w != children.last)
            Divider(color: Colors.grey.shade200, height: 16)
        ])
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: const Color(0xffD08C4A)),
      const SizedBox(width: 10),
      SizedBox(
          width: 70,
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade500))),
      Expanded(
          child: Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff5E1D04)))),
    ]);
  }
}

class _OrderTimeline extends StatelessWidget {
  final String currentStatus;
  const _OrderTimeline({required this.currentStatus});

  static const List<String> _steps = [
    'Pending',
    'Processing',
    'Dispatched',
    'Delivered'
  ];

  bool _isCompleted(String step) {
    final ci = _steps.indexOf(currentStatus);
    final si = _steps.indexOf(step);
    if (ci == -1) return false;
    return si <= ci;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(
        children: _steps.asMap().entries.map((entry) {
          final isCompleted = _isCompleted(entry.value);
          final isLast = entry.key == _steps.length - 1;
          return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xffD08C4A)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle),
                    child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        size: isCompleted ? 14 : 8,
                        color: isCompleted
                            ? Colors.white
                            : Colors.grey.shade400),
                  ),
                  if (!isLast)
                    Container(
                        width: 2,
                        height: 30,
                        color: isCompleted
                            ? const Color(0xffD08C4A)
                            : Colors.grey.shade200),
                ]),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(entry.value,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isCompleted
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isCompleted
                              ? const Color(0xff5E1D04)
                              : Colors.grey.shade400)),
                ),
              ]);
        }).toList(),
      ),
    );
  }
}

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
            border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      ),
    );
  }
}

class _SheetInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  const _SheetInputField(
      {required this.controller,
        required this.hint,
        required this.icon,
        this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon:
        Icon(icon, color: const Color(0xffD08C4A), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffD08C4A))),
      ),
    );
  }
}