// lib/views/buyer/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Not available';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':   return Colors.green;
      case 'shipped':     return Colors.blue;
      case 'accepted':    return Colors.orange;
      case 'picked':      return Colors.teal;
      case 'in transit':  return Colors.lightBlue;
      case 'assigned':    return Colors.purple;
      case 'pending':     return Colors.amber;
      case 'cancelled':   return Colors.red;
      case 'returned':    return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderId ?? 'Order Details'),
        backgroundColor: const Color(0xffD08C4A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status ?? 'pending').withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text(order.status ?? 'Pending'),
                    backgroundColor: _getStatusColor(order.status ?? 'pending').withOpacity(0.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Information
            _sectionTitle('Order Information'),
            _infoRow('Order ID', order.orderId ?? 'N/A'),
            _infoRow('Placed On', _formatDate(order.createdAt)),
            if (order.deliveredAt != null) _infoRow('Delivered On', _formatDate(order.deliveredAt)),
            if (order.assignedAt != null) _infoRow('Assigned On', _formatDate(order.assignedAt)),
            if (order.clearedAt != null) _infoRow('Cleared On', _formatDate(order.clearedAt)),
            const SizedBox(height: 16),

            // Product Details
            _sectionTitle('Product Details'),
            _infoRow('Product Name', order.productName ?? 'N/A'),
            _infoRow('Quantity', order.quantity?.toString() ?? '1'),
            _infoRow('Amount', 'Rs ${order.amount ?? 0}'),
            const SizedBox(height: 16),

            // Buyer Information
            _sectionTitle('Buyer Information'),
            _infoRow('Name', order.buyerName ?? 'N/A'),
            _infoRow('Phone', order.buyerPhone ?? 'N/A'),
            _infoRow('Address', order.buyerAddress ?? 'N/A'),
            const SizedBox(height: 16),

            // Seller Information
            _sectionTitle('Seller Information'),
            _infoRow('Seller Name', order.sellerName ?? 'N/A'),
            _infoRow('Seller Phone', order.sellerPhone ?? 'N/A'),
            const SizedBox(height: 16),

            // Delivery Information
            _sectionTitle('Delivery Information'),
            _infoRow('Delivery Type', order.deliveryType ?? 'Rider'),
            if (order.deliveryType == 'Courier') ...[
              _infoRow('Courier Name', order.courierName ?? 'N/A'),
              _infoRow('Tracking Number', order.trackingNumber ?? 'N/A'),
            ],
            if (order.riderName != null) _infoRow('Rider Name', order.riderName!),
            const SizedBox(height: 16),

            // Payment Information
            _sectionTitle('Payment Information'),
            _infoRow('Buyer Payment Status', order.buyerPaymentStatus ?? 'Pending'),
            _infoRow('Rider Payment Status', order.riderPaymentStatus ?? 'Pending'),
            _infoRow('Is Paid', order.isPaid == true ? 'Yes' : 'No'),
            const SizedBox(height: 16),

            // Not Delivered / Return Reason
            if (order.notDeliveredReason != null && order.notDeliveredReason!.isNotEmpty)
              _infoRow('Not Delivered Reason', order.notDeliveredReason!),
            if (order.returnReason != null && order.returnReason!.isNotEmpty)
              _infoRow('Return Reason', order.returnReason!),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xff5E1D04),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}