import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/rider_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/auth_button.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/info_row.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/section_title.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';

class AdminRiderDetailScreen extends StatefulWidget {
  final RiderModel rider;
  final String sellerName;

  const AdminRiderDetailScreen({
    super.key,
    required this.rider,
    required this.sellerName,
  });

  @override
  State<AdminRiderDetailScreen> createState() =>
      _AdminRiderDetailScreenState();
}

class _AdminRiderDetailScreenState
    extends State<AdminRiderDetailScreen> {
  final AdminService _adminService = AdminService();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  late bool _isBlocked;
  bool isUpdating        = false;
  bool isLoadingStats    = false;

  // ── Performance stats
  int    _totalDeliveries    = 0;
  int    _deliveredOrders    = 0;
  int    _notDeliveredOrders = 0;
  double _avgRating          = 0.0;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.rider.isBlocked ?? false;
    _loadRiderStats();
  }

  // ── Load real-time rider performance from orders + reviews
  Future<void> _loadRiderStats() async {
    try {
      setState(() => isLoadingStats = true);

      final riderId = widget.rider.docId ?? '';

      final results = await Future.wait([
        // All orders assigned to this rider
        _firestore
            .collection('orders')
            .where('riderId', isEqualTo: riderId)
            .get(),
        // All reviews for products delivered by this rider's seller
        // We calculate rating from delivered orders' reviews
        _firestore
            .collection('reviews')
            .where('sellerId',
            isEqualTo: widget.rider.sellerId ?? '')
            .get(),
      ]);

      final orderDocs  = results[0].docs;
      final reviewDocs = results[1].docs;

      final delivered = orderDocs
          .where((d) =>
      (d.data() as Map)['status'] == 'Delivered')
          .length;
      final notDelivered = orderDocs
          .where((d) =>
      (d.data() as Map)['status'] == 'Not Delivered')
          .length;

      // Avg rating from seller reviews
      double avgRating = 0.0;
      if (reviewDocs.isNotEmpty) {
        final total = reviewDocs.fold<double>(
            0.0,
                (sum, d) =>
            sum +
                ((d.data() as Map)['rating'] as num? ?? 0)
                    .toDouble());
        avgRating = total / reviewDocs.length;
      }

      setState(() {
        _totalDeliveries    = orderDocs.length;
        _deliveredOrders    = delivered;
        _notDeliveredOrders = notDelivered;
        _avgRating          = avgRating;
        isLoadingStats      = false;
      });
    } catch (_) {
      setState(() => isLoadingStats = false);
    }
  }

  // ── Block dialog with reason field
  void _showBlockDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Block Rider',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Block ${widget.rider.name}? Please provide a reason.',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter reason for blocking...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFEEEEEE))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFEEEEEE))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xffD08C4A))),
              ),
            ),
          ],
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(
                  content: Text('Please enter a reason',
                      style: GoogleFonts.poppins(
                          fontSize: 13)),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                ));
                return;
              }
              Navigator.pop(context);
              _blockRider(reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Block',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Unblock confirm dialog
  void _showUnblockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Unblock Rider',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        content: Text(
            'Are you sure you want to unblock ${widget.rider.name}? They will regain access to deliveries.',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600)),
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
              _unblockRider();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff66BB6A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Unblock',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Block rider in Firestore
  Future<void> _blockRider(String reason) async {
    try {
      setState(() => isUpdating = true);
      await _adminService.blockRider(
        riderId: widget.rider.docId ?? '',
        reason:  reason,
      );
      setState(() {
        _isBlocked = true;
        isUpdating = false;
      });
      _showSnackBar('Rider blocked successfully',
          isError: true);
    } catch (e) {
      setState(() => isUpdating = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  // ── Unblock rider in Firestore
  Future<void> _unblockRider() async {
    try {
      setState(() => isUpdating = true);
      await _adminService.unblockRider(
          widget.rider.docId ?? '');
      setState(() {
        _isBlocked = false;
        isUpdating = false;
      });
      _showSnackBar('Rider unblocked successfully');
    } catch (e) {
      setState(() => isUpdating = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: isError
          ? Colors.red.shade400
          : const Color(0xff66BB6A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final rider = widget.rider;

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
        title: Text('Rider Detail',
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
            const SizedBox(height: 20),

            // ── Profile section
            Center(
              child: Column(children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor:
                  const Color(0xFFF5E6E6),
                  backgroundImage: (rider.profileImage
                      ?.isNotEmpty ??
                      false)
                      ? NetworkImage(
                      rider.profileImage!)
                      : null,
                  child: (rider.profileImage
                      ?.isEmpty ??
                      true)
                      ? Text(
                    (rider.name ?? 'R')[0]
                        .toUpperCase(),
                    style:
                    GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight:
                        FontWeight.bold,
                        color: const Color(
                            0xff5E1D04)),
                  )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(rider.name ?? '',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                        const Color(0xff5E1D04))),
                const SizedBox(height: 4),
                if (widget.sellerName.isNotEmpty)
                  Text(widget.sellerName,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    StatusBadge.role('Rider'),
                    const SizedBox(width: 6),
                    _isBlocked
                        ? StatusBadge.blocked()
                        : StatusBadge.active(),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Performance Stats
            const SectionTitle(
                title: 'Performance Stats'),
            const SizedBox(height: 12),
            isLoadingStats
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A),
                    strokeWidth: 2),
              ),
            )
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Column(children: [
                _StatRow(
                    label: 'Total Deliveries',
                    value:
                    '$_totalDeliveries'),
                const Divider(
                    color: Color(0xFFEEDDB0),
                    height: 20),
                _StatRow(
                    label: 'Delivered',
                    value: '$_deliveredOrders',
                    valueColor: const Color(
                        0xff66BB6A)),
                const Divider(
                    color: Color(0xFFEEDDB0),
                    height: 20),
                _StatRow(
                    label: 'Not Delivered',
                    value:
                    '$_notDeliveredOrders',
                    valueColor:
                    Colors.red.shade400),
                const Divider(
                    color: Color(0xFFEEDDB0),
                    height: 20),
                _StatRow(
                    label: 'Rating',
                    value:
                    '${_avgRating.toStringAsFixed(1)}/5.0',
                    valueColor: const Color(
                        0xffD08C4A)),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Contact info
            const SectionTitle(
                title: 'Contact Info'),
            const SizedBox(height: 8),
            InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: rider.email ?? ''),
            InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: rider.phone ?? ''),
            if ((rider.address ?? '').isNotEmpty)
              InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: rider.address ?? ''),
            const SizedBox(height: 20),

            // ── Assigned seller
            if (widget.sellerName.isNotEmpty) ...[
              const SectionTitle(
                  title: 'Assigned Seller'),
              const SizedBox(height: 8),
              InfoRow(
                  icon: Icons.store_outlined,
                  label: 'Shop',
                  value: widget.sellerName),
              const SizedBox(height: 20),
            ],

            // ── Vehicle info
            if ((rider.vehicleModel ?? '').isNotEmpty ||
                (rider.vehicleNumber ?? '')
                    .isNotEmpty) ...[
              const SectionTitle(
                  title: 'Vehicle Info'),
              const SizedBox(height: 8),
              if ((rider.vehicleModel ?? '').isNotEmpty)
                InfoRow(
                    icon: Icons.two_wheeler_outlined,
                    label: 'Model',
                    value: rider.vehicleModel ?? ''),
              if ((rider.vehicleNumber ?? '').isNotEmpty)
                InfoRow(
                    icon: Icons.pin_outlined,
                    label: 'Number',
                    value: rider.vehicleNumber ?? ''),
              const SizedBox(height: 20),
            ],

            // ── License info
            if ((rider.licenseNumber ?? '').isNotEmpty) ...[
              const SectionTitle(
                  title: 'License Info'),
              const SizedBox(height: 8),
              InfoRow(
                  icon: Icons.credit_card_outlined,
                  label: 'License',
                  value: rider.licenseNumber ?? ''),
              const SizedBox(height: 20),
            ],

            // ── Block reason if blocked
            if (_isBlocked &&
                (rider.blockedReason ?? '').isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline,
                      color: Colors.red.shade400,
                      size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Blocked: ${rider.blockedReason}',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                            Colors.red.shade400)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            // ── Block/Unblock button
            AuthButton(
              label: _isBlocked
                  ? 'Unblock Rider'
                  : 'Block Rider',
              onPressed: _isBlocked
                  ? _showUnblockDialog
                  : _showBlockDialog,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Stat Row widget
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ??
                    const Color(0xff5E1D04))),
      ],
    );
  }
}