import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';

class RiderOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const RiderOrderDetailScreen({super.key, required this.order});

  @override
  State<RiderOrderDetailScreen> createState() =>
      _RiderOrderDetailScreenState();
}

class _RiderOrderDetailScreenState extends State<RiderOrderDetailScreen> {
  final OrderService _orderService = OrderService();
  late String _currentStatus;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status ?? 'Assigned';
  }

  // ── Update status helper
  Future<void> _updateStatus(String newStatus) async {
    try {
      setState(() => isLoading = true);

      switch (newStatus) {
        case 'Accepted':
          await _orderService.acceptOrder(widget.order.docId!);
          break;
        case 'Picked':
          await _orderService.pickDelivery(widget.order.docId!);
          break;
        case 'In Transit':
          await _orderService.markInTransit(widget.order.docId!);
          break;
        case 'Delivered':
          await _orderService.markDelivered(widget.order.docId!);
          break;
      }

      setState(() {
        _currentStatus = newStatus;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order updated to $newStatus',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xffD08C4A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── Reject order
  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Order',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        content: Text(
          'Are you sure you want to reject this order?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                setState(() => isLoading = true);
                await _orderService.rejectOrder(widget.order.docId!);
                setState(() {
                  _currentStatus = 'Rejected';
                  isLoading = false;
                });
                Navigator.pop(context);
              } catch (e) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString(),
                        style: GoogleFonts.poppins(fontSize: 13)),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Reject',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Not Delivered',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason:',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade600),
            ),
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
                      const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xffD08C4A)),
                ),
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
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              Navigator.pop(context);
              try {
                setState(() => isLoading = true);
                await _orderService.markNotDelivered(
                  docId: widget.order.docId!,
                  reason: reasonController.text.trim(),
                );
                setState(() {
                  _currentStatus = 'Not Delivered';
                  isLoading = false;
                });
              } catch (e) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString(),
                        style: GoogleFonts.poppins(fontSize: 13)),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
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

  @override
  Widget build(BuildContext context) {
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
                  _StatusHeader(
                    orderId: widget.order.orderId ?? '',
                    status: _currentStatus,
                  ),
                  const SizedBox(height: 20),

                  // ── Customer Info
                  _SectionTitle(title: 'Customer Details'),
                  const SizedBox(height: 10),
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: widget.order.buyerName ?? ''),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: widget.order.buyerPhone ?? ''),
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: widget.order.buyerAddress ?? ''),
                  ]),
                  const SizedBox(height: 20),

                  // ── Order Summary
                  _SectionTitle(title: 'Order Summary'),
                  const SizedBox(height: 10),
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.local_florist_outlined,
                        label: 'Product',
                        value: widget.order.productName ?? ''),
                    _InfoRow(
                        icon: Icons.numbers_outlined,
                        label: 'Quantity',
                        value: '${widget.order.quantity ?? 1}'),
                    _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Amount',
                        value: 'Rs ${widget.order.amount ?? 0}'),
                    _InfoRow(
                        icon: Icons.money_outlined,
                        label: 'Payment',
                        value: 'Cash on Delivery'),
                  ]),
                  const SizedBox(height: 20),

                  // ── Seller Info
                  _SectionTitle(title: 'Seller Details'),
                  const SizedBox(height: 10),
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.storefront_outlined,
                        label: 'Seller',
                        value: widget.order.sellerName ?? ''),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: widget.order.sellerPhone ?? ''),
                  ]),
                  const SizedBox(height: 20),

                  // ── Status Timeline
                  _SectionTitle(title: 'Order Timeline'),
                  const SizedBox(height: 10),
                  _StatusTimeline(currentStatus: _currentStatus),
                  const SizedBox(height: 24),

                  // ── Action Buttons
                  if (_currentStatus == 'Assigned') ...[
                    _ActionButton(
                      label: 'Accept Order',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xff66BB6A),
                      onTap: () => _updateStatus('Accepted'),
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Reject Order',
                      icon: Icons.cancel_outlined,
                      color: Colors.red.shade400,
                      onTap: _showRejectDialog,
                    ),
                  ],

                  if (_currentStatus == 'Accepted')
                    _ActionButton(
                      label: 'Pick Up Delivery',
                      icon: Icons.inventory_outlined,
                      color: const Color(0xff42A5F5),
                      onTap: () => _updateStatus('Picked'),
                    ),

                  if (_currentStatus == 'Picked')
                    _ActionButton(
                      label: 'Start Delivery',
                      icon: Icons.delivery_dining_outlined,
                      color: const Color(0xff7E57C2),
                      onTap: () => _updateStatus('In Transit'),
                    ),

                  if (_currentStatus == 'In Transit') ...[
                    _ActionButton(
                      label: 'Mark as Delivered',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xff66BB6A),
                      onTap: () => _updateStatus('Delivered'),
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: 'Not Delivered',
                      icon: Icons.cancel_outlined,
                      color: Colors.red.shade400,
                      onTap: _showNotDeliveredDialog,
                    ),
                  ],

                  if (_currentStatus == 'Delivered')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xff66BB6A), size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Delivered — collect COD from buyer',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff66BB6A),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

// ── Status Header
class _StatusHeader extends StatelessWidget {
  final String orderId;
  final String status;
  const _StatusHeader({required this.orderId, required this.status});

  Color _statusColor() {
    switch (status) {
      case 'Assigned': return const Color(0xffFFA726);
      case 'Accepted': return const Color(0xffD08C4A);
      case 'Picked': return const Color(0xff42A5F5);
      case 'In Transit': return const Color(0xff7E57C2);
      case 'Delivered': return const Color(0xff66BB6A);
      case 'Not Delivered': return const Color(0xffEF5350);
      case 'Rejected': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          orderId,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
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

// ── Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xffD08C4A)),
        const SizedBox(width: 10),
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xff5E1D04),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Status Timeline
class _StatusTimeline extends StatelessWidget {
  final String currentStatus;
  const _StatusTimeline({required this.currentStatus});

  static const List<String> _steps = [
    'Assigned',
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
