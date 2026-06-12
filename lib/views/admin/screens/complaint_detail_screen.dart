import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:online_perfume_app_fyp/models/complaint_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/section_title.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/info_row.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/auth_button.dart';

class AdminComplaintDetailScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const AdminComplaintDetailScreen({
    super.key,
    required this.complaint,
  });

  @override
  State<AdminComplaintDetailScreen> createState() =>
      _AdminComplaintDetailScreenState();
}

class _AdminComplaintDetailScreenState
    extends State<AdminComplaintDetailScreen> {
  // Service
  final AdminService _adminService = AdminService();

  // State
  bool isLoading = false;
  late String _currentStatus;
  final TextEditingController _replyController = TextEditingController();

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Resolved',
    'Dismissed',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.complaint.status ?? 'Pending';
    _replyController.text = widget.complaint.adminReply ?? '';
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Pending':     return const Color(0xFFF8D7DA);
      case 'In Progress': return const Color(0xFFFFE5B4);
      case 'Resolved':    return const Color(0xFFD4EDDA);
      case 'Dismissed':   return const Color(0xFFEEEEEE);
      default:            return const Color(0xFFEEEEEE);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Pending':     return const Color(0xFF721C24);
      case 'In Progress': return const Color(0xFF856404);
      case 'Resolved':    return const Color(0xFF155724);
      case 'Dismissed':   return const Color(0xFF333333);
      default:            return const Color(0xFF333333);
    }
  }

  // Update status + reply to Firebase
  Future<void> _submitUpdate(String newStatus) async {
    try {
      isLoading = true;
      setState(() {});

      if (newStatus == 'Resolved') {
        await _adminService.resolveComplaint(
          docId: widget.complaint.docId!,
          reply: _replyController.text.trim(),
        );
      } else if (newStatus == 'Dismissed') {
        await _adminService.dismissComplaint(
            widget.complaint.docId!);
      } else {
        await _adminService.replyToComplaint(
          docId: widget.complaint.docId!,
          reply: _replyController.text.trim(),
        );
        await _adminService.updateComplaintStatus(
          docId: widget.complaint.docId!,
          status: newStatus,
        );
      }

      setState(() {
        _currentStatus = newStatus;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complaint updated to $newStatus',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: const Color(0xffD08C4A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      isLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showUpdateStatusDialog() {
    String tempStatus = _currentStatus;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update Status',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statusOptions.map((status) {
              return RadioListTile<String>(
                value: status,
                groupValue: tempStatus,
                activeColor: const Color(0xffD08C4A),
                onChanged: (val) =>
                    setDialogState(() => tempStatus = val!),
                title: Text(
                  status,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitUpdate(tempStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD08C4A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.poppins(
                  color: const Color(0xff5E1D04),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactBuyer(String type) async {
    final Uri uri = type == 'phone'
        ? Uri(scheme: 'tel', path: widget.complaint.buyerPhone)
        : Uri(scheme: 'mailto', path: widget.complaint.buyerEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Format timestamp
  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04)),
        ),
        title: Text(
          'Complaint Detail',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(color: Color(0xffD08C4A)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Complaint ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.complaintId ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                    Text(
                      _formatDate(complaint.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                StatusBadge(
                  label: _currentStatus,
                  backgroundColor: _statusBgColor(_currentStatus),
                  textColor: _statusTextColor(_currentStatus),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Reported Issue
            const SectionTitle(title: 'Reported Issue'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint.productName ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.issue ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF721C24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Buyer Info
            const SectionTitle(title: 'Buyer Info'),
            const SizedBox(height: 8),
            InfoRow(
                icon: Icons.person_outline,
                label: 'Name',
                value: complaint.buyerName ?? ''),
            InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: complaint.buyerEmail ?? ''),
            InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: complaint.buyerPhone ?? ''),
            const SizedBox(height: 10),

            // ── Contact Buyer Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactBuyer('phone'),
                    icon: const Icon(Icons.call,
                        color: Color(0xffD08C4A), size: 18),
                    label: Text(
                      'Call Buyer',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
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
                    onPressed: () => _contactBuyer('email'),
                    icon: const Icon(Icons.email_outlined,
                        color: Color(0xffD08C4A), size: 18),
                    label: Text(
                      'Email Buyer',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
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
              ],
            ),
            const SizedBox(height: 20),

            // ── Seller Info
            const SectionTitle(title: 'Seller Info'),
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.store_outlined,
              label: 'Shop Name',
              value: complaint.sellerName ?? '',
            ),
            const SizedBox(height: 20),

            // ── Order Info
            const SectionTitle(title: 'Order Info'),
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.shopping_bag_outlined,
              label: 'Order ID',
              value: complaint.orderId ?? '',
            ),
            const SizedBox(height: 20),

            // ── Admin Reply
            const SectionTitle(title: 'Reply to Complaint'),
            const SizedBox(height: 8),
            TextField(
              controller: _replyController,
              maxLines: 4,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04)),
              decoration: InputDecoration(
                hintText: 'Type your reply here...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04)
                      .withOpacity(0.4),
                ),
                filled: true,
                fillColor: const Color(0xFFFFF3CD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 28),

            // ── Update Status Button
            AuthButton(
              label: 'Update Complaint Status',
              onPressed: _showUpdateStatusDialog,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}