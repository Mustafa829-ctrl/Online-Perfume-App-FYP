import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:online_perfume_app_fyp/models/order_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/auth_button.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/info_row.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/section_title.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const AdminOrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState
    extends State<AdminOrderDetailScreen> {
  final AdminService _adminService = AdminService();

  late String _currentStatus;
  bool isUpdating      = false;
  bool isLoadingBuyer  = false;

  // Buyer details fetched from users collection
  String _buyerName    = '';
  String _buyerEmail   = '';
  String _buyerPhone   = '';
  String _buyerAddress = '';

  final List<String> _statusOptions = [
    'Not Delivered',
    'Returned',
    'Cancelled',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status ?? 'Not Delivered';
    // Pre-fill from order model first
    _buyerName    = widget.order.buyerName  ?? '';
    _buyerPhone   = widget.order.buyerPhone ?? '';
    // Then fetch full details from users collection
    _fetchBuyerDetails();
  }

  Future<void> _fetchBuyerDetails() async {
    try {
      setState(() => isLoadingBuyer = true);
      final details = await _adminService
          .getBuyerDetails(widget.order.buyerId ?? '');
      setState(() {
        _buyerName    = details['name']    ?? _buyerName;
        _buyerEmail   = details['email']   ?? '';
        _buyerPhone   = details['phone']   ?? _buyerPhone;
        _buyerAddress = details['address'] ?? '';
        isLoadingBuyer = false;
      });
    } catch (_) {
      setState(() => isLoadingBuyer = false);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Not Delivered': return const Color(0xFFF8D7DA);
      case 'Returned':      return const Color(0xFFD0E8FF);
      case 'Cancelled':     return const Color(0xFFEEEEEE);
      case 'Resolved':      return const Color(0xFFD4EDDA);
      case 'Closed':        return const Color(0xFFEEEEEE);
      default:              return const Color(0xFFEEEEEE);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Not Delivered': return const Color(0xFF721C24);
      case 'Returned':      return const Color(0xFF0D47A1);
      case 'Cancelled':     return const Color(0xFF333333);
      case 'Resolved':      return const Color(0xFF155724);
      case 'Closed':        return const Color(0xFF333333);
      default:              return const Color(0xFF333333);
    }
  }

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  // ── Update status dialog
  void _showUpdateStatusDialog() {
    String tempStatus = _currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('Update Order Status',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statusOptions.map((status) {
              return RadioListTile<String>(
                value:      status,
                groupValue: tempStatus,
                activeColor: const Color(0xffD08C4A),
                onChanged:  (val) =>
                    setDialogState(() => tempStatus = val!),
                title: Text(status,
                    style: GoogleFonts.poppins(fontSize: 13)),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateStatus(tempStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD08C4A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Update',
                  style: GoogleFonts.poppins(
                      color: const Color(0xff5E1D04),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Update status in Firestore
  Future<void> _updateStatus(String newStatus) async {
    try {
      setState(() => isUpdating = true);

      await _adminService.updateOrderStatus(
        orderId: widget.order.docId ?? '',
        status:  newStatus,
      );

      setState(() {
        _currentStatus = newStatus;
        isUpdating     = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order status updated to $newStatus',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xffD08C4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Contact buyer via phone or email
  Future<void> _contactBuyer(String type) async {
    final Uri uri = type == 'phone'
        ? Uri(scheme: 'tel',    path: _buyerPhone)
        : Uri(scheme: 'mailto', path: _buyerEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not open ${type == 'phone' ? 'dialer' : 'email'}',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order        = widget.order;
    final issueText    = order.status == 'Returned'
        ? (order.returnReason         ?? 'Return requested')
        : (order.notDeliveredReason   ?? 'No reason provided');
    final deliveryInfo = (order.deliveryType ?? 'Rider') == 'Courier'
        ? order.courierName ?? ''
        : order.riderName   ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04)),
        ),
        title: Text('Order Detail',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: isUpdating
          ? const Center(
          child: CircularProgressIndicator(
              color: Color(0xffD08C4A)))
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Order ID + Status
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(order.orderId ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                            const Color(0xff5E1D04))),
                    Text(
                        _formatDate(order.createdAt),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                            Colors.grey.shade400)),
                  ],
                ),
                StatusBadge(
                  label: _currentStatus,
                  backgroundColor:
                  _statusBgColor(_currentStatus),
                  textColor:
                  _statusTextColor(_currentStatus),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Product Info
            const SectionTitle(title: 'Product Info'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6E6),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xffD08C4A),
                      size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(order.productName ?? '',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w600,
                              color: const Color(
                                  0xff5E1D04))),
                      Text(
                          'Amount: Rs ${order.amount ?? 0}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors
                                  .grey.shade600)),
                      Text(
                          'Qty: ${order.quantity ?? 1}',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors
                                  .grey.shade500)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Reported Issue
            const SectionTitle(
                title: 'Reported Issue'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(issueText,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color:
                      const Color(0xFF721C24))),
            ),
            const SizedBox(height: 20),

            // ── Delivery Info
            if (deliveryInfo.isNotEmpty) ...[
              const SectionTitle(
                  title: 'Delivery Info'),
              const SizedBox(height: 8),
              InfoRow(
                icon: (order.deliveryType ?? 'Rider') ==
                    'Courier'
                    ? Icons.local_shipping_outlined
                    : Icons.delivery_dining_outlined,
                label: (order.deliveryType ?? 'Rider') ==
                    'Courier'
                    ? 'Courier'
                    : 'Rider',
                value: deliveryInfo,
              ),
              if ((order.trackingNumber ?? '')
                  .isNotEmpty)
                InfoRow(
                  icon: Icons
                      .confirmation_number_outlined,
                  label: 'Tracking',
                  value: order.trackingNumber ?? '',
                ),
              const SizedBox(height: 12),
            ],

            // ── Buyer Info
            const SectionTitle(title: 'Buyer Info'),
            const SizedBox(height: 8),
            isLoadingBuyer
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A),
                    strokeWidth: 2),
              ),
            )
                : Column(children: [
              InfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: _buyerName),
              if (_buyerEmail.isNotEmpty)
                InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _buyerEmail),
              InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: _buyerPhone),
              if (_buyerAddress.isNotEmpty)
                InfoRow(
                    icon:
                    Icons.location_on_outlined,
                    label: 'Address',
                    value: _buyerAddress),
            ]),
            const SizedBox(height: 12),

            // ── Contact Buyer buttons
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _buyerPhone.isNotEmpty
                      ? () => _contactBuyer('phone')
                      : null,
                  icon: const Icon(Icons.call,
                      color: Color(0xffD08C4A),
                      size: 18),
                  label: Text('Call Buyer',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                          const Color(0xff5E1D04))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xffD08C4A)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _buyerEmail.isNotEmpty
                      ? () => _contactBuyer('email')
                      : null,
                  icon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xffD08C4A),
                      size: 18),
                  label: Text('Email Buyer',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                          const Color(0xff5E1D04))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xffD08C4A)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Seller Info
            const SectionTitle(title: 'Seller Info'),
            const SizedBox(height: 8),
            InfoRow(
                icon: Icons.store_outlined,
                label: 'Seller',
                value: order.sellerName ?? ''),
            const SizedBox(height: 28),

            // ── Update Status button
            AuthButton(
              label: 'Update Order Status',
              onPressed: _showUpdateStatusDialog,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}