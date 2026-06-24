import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_perfume_app_fyp/models/complaint_model.dart';
import 'package:online_perfume_app_fyp/services/cloudinary_service.dart';
import 'package:online_perfume_app_fyp/services/complaint_service.dart';
import '../buyer auth/buyer_login_screen.dart';

class BuyerComplaintsScreen extends StatefulWidget {
  const BuyerComplaintsScreen({super.key});

  @override
  State<BuyerComplaintsScreen> createState() => _BuyerComplaintsScreenState();
}

class _BuyerComplaintsScreenState extends State<BuyerComplaintsScreen> {
  final ComplaintService _complaintService = ComplaintService();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildGuestState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: const Color(0xffD08C4A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<List<ComplaintModel>>(
        future: _complaintService.getComplaintsByBuyer(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final complaints = snapshot.data ?? [];
          if (complaints.isEmpty) {
            return const Center(child: Text('No complaints yet.'));
          }
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (ctx, index) {
              final c = complaints[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: c.imageUrl != null && c.imageUrl!.isNotEmpty
                      ? Image.network(c.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.error_outline),
                  title: Text(c.productName ?? 'Product'),
                  subtitle: Text(c.issue ?? ''),
                  trailing: Chip(
                    label: Text(c.status ?? 'Pending'),
                    backgroundColor: _getStatusColor(c.status),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _submitNewComplaint(user),
        backgroundColor: const Color(0xffD08C4A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: const Color(0xff5E1D04).withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Login to view Complaints',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit complaints about your orders here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyerLoginScreen()),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff5E1D04)),
              child: const Text('Login Now'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade100;
      case 'In Progress':
        return Colors.blue.shade100;
      case 'Dismissed':
        return Colors.grey.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  Future<void> _submitNewComplaint(User user) async {
    final orders = await _getUserDeliveredOrders(user.uid);
    if (orders.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have no delivered orders to complain about.')),
        );
      }
      return;
    }
    await _showOrderSelectionDialog(orders, user);
  }

  Future<List<QueryDocumentSnapshot>> _getUserDeliveredOrders(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['delivered', 'completed'])
        .get();
    return snapshot.docs;
  }

  Future<void> _showOrderSelectionDialog(List<QueryDocumentSnapshot> orders, User user) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select an order to complain about'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              final orderId = order.id;
              final items = orderData['items'] as List<dynamic>? ?? [];
              final sellerId = orderData['sellerId'] ?? '';
              final sellerName = orderData['sellerName'] ?? 'Unknown Seller';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Order #${orderId.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...items.map((item) {
                    final product = item as Map<String, dynamic>;
                    return ListTile(
                      leading: product['imageUrl'] != null
                          ? Image.network(product['imageUrl'], width: 40, height: 40)
                          : const Icon(Icons.image),
                      title: Text(product['name'] ?? 'Product'),
                      subtitle: Text('Qty: ${product['quantity']}'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showComplaintForm(
                          orderId: orderId,
                          productId: product['id'] ?? '',
                          productName: product['name'] ?? '',
                          sellerId: sellerId,
                          sellerName: sellerName,
                          user: user,
                        );
                      },
                    );
                  }).toList(),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<void> _showComplaintForm({
    required String orderId,
    required String productId,
    required String productName,
    required String sellerId,
    required String sellerName,
    required User user,
  }) async {
    final issueController = TextEditingController();
    File? issueImage;
    String? uploadedImageUrl;
    bool isUploading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complaint for $productName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: issueController,
                  maxLines: 5,
                  decoration: const InputDecoration(hintText: 'Describe the issue...', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setModalState(() => issueImage = File(picked.path));
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                    child: issueImage != null
                        ? Image.file(issueImage!, fit: BoxFit.cover)
                        : const Center(child: Text('Tap to add image of the issue')),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                    setModalState(() => isUploading = true);
                    if (issueImage != null) {
                      uploadedImageUrl = await CloudinaryService.uploadImage(issueImage!);
                    }

                    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                    final buyerName = userDoc.data()?['name'] ?? user.displayName ?? '';
                    final buyerEmail = user.email ?? '';
                    final buyerPhone = userDoc.data()?['phone'] ?? '';

                    final complaint = ComplaintModel(
                      complaintId: DateTime.now().millisecondsSinceEpoch.toString(),
                      buyerId: user.uid,
                      buyerName: buyerName,
                      buyerEmail: buyerEmail,
                      buyerPhone: buyerPhone,
                      sellerId: sellerId,
                      sellerName: sellerName,
                      orderId: orderId,
                      productName: productName,
                      issue: issueController.text.trim(),
                      status: 'Pending',
                      adminReply: '',
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      resolvedAt: null,
                      imageUrl: uploadedImageUrl,
                    );

                    try {
                      await _complaintService.addComplaint(complaint);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Complaint submitted successfully!')),
                        );
                        setState(() {}); // refresh list
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    } finally {
                      setModalState(() => isUploading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Complaint'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}