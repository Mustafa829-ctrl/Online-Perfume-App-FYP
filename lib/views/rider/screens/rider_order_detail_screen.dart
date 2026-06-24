import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';

class RiderOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const RiderOrderDetailScreen({super.key, required this.order});

  @override
  State<RiderOrderDetailScreen> createState() => _RiderOrderDetailScreenState();
}

class _RiderOrderDetailScreenState extends State<RiderOrderDetailScreen> {
  final OrderService _orderService = OrderService();
  late OrderModel _currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _listenToOrderUpdates();
  }

  void _listenToOrderUpdates() {
    _orderService.getOrderStream(_currentOrder.docId!).listen((updatedOrder) {
      if (mounted) {
        setState(() => _currentOrder = updatedOrder);
      }
    });
  }

  Future<void> _updateStatus(String newStatus, {String? reason}) async {
    setState(() => _isLoading = true);
    try {
      if (newStatus == 'Not Delivered' && reason != null) {
        await _orderService.markNotDelivered(docId: _currentOrder.docId!, reason: reason);
      } else {
        await _orderService.updateOrderStatus(orderId: _currentOrder.docId!, status: newStatus);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: const Color(0xffD08C4A)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBuyerPayment() async {
    setState(() => _isLoading = true);
    try {
      await _orderService.markBuyerPaymentReceived(_currentOrder.docId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('COD Payment Confirmed'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNotDeliveredDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Delivered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide reason:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Buyer not available, Wrong address, etc.",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _updateStatus('Not Delivered', reason: reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentOrder.status ?? 'Pending';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff5E1D04),
        foregroundColor: Colors.white,
        title: Text('Order ${_currentOrder.orderId ?? ""}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(status),
            const SizedBox(height: 20),

            _buildInfoCard('Customer Details', [
              _infoRow(Icons.person, 'Name', _currentOrder.buyerName ?? 'N/A'),
              _infoRow(Icons.phone, 'Phone', _currentOrder.buyerPhone ?? 'N/A'),
              _infoRow(Icons.location_on, 'Address', _currentOrder.buyerAddress ?? 'N/A'),
            ]),
            const SizedBox(height: 20),

            _buildInfoCard('Order Summary', [
              _infoRow(Icons.local_florist, 'Product', _currentOrder.productName ?? 'N/A'),
              _infoRow(Icons.numbers, 'Quantity', '${_currentOrder.quantity ?? 1}'),
              _infoRow(Icons.currency_rupee, 'Amount', 'Rs ${_currentOrder.amount ?? 0}'),
            ]),
            const SizedBox(height: 30),

            _buildActionButtons(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Order Details', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
        Chip(
          label: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          backgroundColor: _getStatusColor(status),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'in transit': return Colors.blue;
      case 'picked': return Colors.orange;
      case 'accepted': return Colors.purple;
      case 'assigned': return Colors.amber;
      case 'not delivered': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffD08C4A), size: 20),
          const SizedBox(width: 12),
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Column(
      children: [
        if (status == 'Assigned')
          _actionButton('Accept Order', Icons.check_circle, Colors.green, () => _updateStatus('Accepted')),

        if (status == 'Accepted')
          _actionButton('Picked Up', Icons.inventory_2_outlined, Colors.blue, () => _updateStatus('Picked')),

        if (status == 'Picked')
          _actionButton('Start Delivery', Icons.delivery_dining, Colors.purple, () => _updateStatus('In Transit')),

        if (status == 'In Transit') ...[
          _actionButton('Mark as Delivered', Icons.check_circle, Colors.green, () => _updateStatus('Delivered')),
          const SizedBox(height: 12),
          _actionButton('Not Delivered', Icons.cancel, Colors.red, _showNotDeliveredDialog),
        ],

        if (status == 'Delivered' &&
            (_currentOrder.buyerPaymentStatus == null || _currentOrder.buyerPaymentStatus == 'Pending'))
          _actionButton(
            'Confirm COD Received from Buyer',
            Icons.payments_outlined,
            Colors.green,
            _confirmBuyerPayment,
          ),

        if (_currentOrder.buyerPaymentStatus == 'Received')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('COD Payment Confirmed from Buyer', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onTap,
        icon: Icon(icon),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}