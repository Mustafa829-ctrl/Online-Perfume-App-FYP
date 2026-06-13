// lib/views/buyer/screens/order_history_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
      return;
    }
    try {
      final orders = await _orderService.getBuyerOrders(user.uid);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
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
      case 'not delivered': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xffD08C4A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (ctx, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(order.status ?? 'pending'),
                child: Text(
                  (order.status?[0] ?? 'P').toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                order.orderId ?? 'Order #${order.docId?.substring(0, 8)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product: ${order.productName ?? 'N/A'}'),
                  Text('Qty: ${order.quantity}  |  Amount: Rs ${order.amount}'),
                  Text('Placed: ${_formatDate(order.createdAt)}'),
                ],
              ),
              trailing: Chip(
                label: Text(order.status ?? 'pending'),
                backgroundColor: _getStatusColor(order.status ?? 'pending').withOpacity(0.2),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}