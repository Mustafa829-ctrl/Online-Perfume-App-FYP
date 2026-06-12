import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/section_title.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/stat_card.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/info_row.dart';
import '../widgets/auth_button.dart';

class AdminSellerDetailScreen extends StatefulWidget {
  // Accept SellerModel
  final SellerModel seller;

  const AdminSellerDetailScreen({super.key, required this.seller});

  @override
  State<AdminSellerDetailScreen> createState() =>
      _AdminSellerDetailScreenState();
}

class _AdminSellerDetailScreenState
    extends State<AdminSellerDetailScreen> {
  final AdminService _adminService = AdminService();

  late bool _isBlocked;
  late bool _isVerified;
  bool isActionLoading = false;
  bool isPerformanceLoading = false;

  // ── Performance data from Firebase
  Map<String, dynamic> _performance = {};

  @override
  void initState() {
    super.initState();
    // Init from SellerModel
    _isBlocked = widget.seller.isBlocked ?? false;
    _isVerified = widget.seller.isVerified ?? false;
    _loadPerformance();
  }

  // ── Load real performance data
  Future<void> _loadPerformance() async {
    if (!_isVerified) return; // no data if unverified
    try {
      isPerformanceLoading = true;
      setState(() {});

      // AdminService.getSellerPerformance()
      _performance = await _adminService
          .getSellerPerformance(widget.seller.docId ?? '');

      isPerformanceLoading = false;
      setState(() {});
    } catch (e) {
      isPerformanceLoading = false;
      setState(() {});
    }
  }

  // ── Verify seller
  Future<void> _verifySeller() async {
    try {
      isActionLoading = true;
      setState(() {});

      // AdminService.verifySeller()
      // Sets isVerified: true, status: 'active'
      await _adminService.verifySeller(widget.seller.docId ?? '');

      setState(() {
        _isVerified = true;
        isActionLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${widget.seller.name} has been verified successfully!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }

      // Load performance after verification
      _loadPerformance();
    } catch (e) {
      isActionLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Unverify seller
  Future<void> _unverifySeller() async {
    try {
      isActionLoading = true;
      setState(() {});

      // AdminService.unverifySeller()
      // Sets isVerified: false, isBlocked: true, status: 'unverified'
      await _adminService.unverifySeller(widget.seller.docId ?? '');

      setState(() {
        _isVerified = false;
        _isBlocked = true;
        isActionLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${widget.seller.name} has been unverified.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      isActionLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Block seller with reason
  Future<void> _blockSeller(String reason) async {
    try {
      isActionLoading = true;
      setState(() {});

      // AdminService.blockSeller()
      await _adminService.blockSeller(
        sellerId: widget.seller.docId ?? '',
        reason: reason,
      );

      setState(() {
        _isBlocked = true;
        isActionLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${widget.seller.name} has been blocked.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      isActionLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Unblock seller
  Future<void> _unblockSeller() async {
    try {
      isActionLoading = true;
      setState(() {});

      // AdminService.unblockSeller()
      await _adminService.unblockSeller(widget.seller.docId ?? '');

      setState(() {
        _isBlocked = false;
        isActionLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '${widget.seller.name} has been unblocked.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      isActionLoading = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Confirm dialog
  void _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool showReasonField = false,
  }) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                style: GoogleFonts.poppins(fontSize: 13)),
            if (showReasonField) ...[
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Reason for blocking...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade400),
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
          ],
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
              if (showReasonField) {
                // Pass reason to block function
                _blockSeller(reasonCtrl.text.trim().isEmpty
                    ? 'Blocked by admin'
                    : reasonCtrl.text.trim());
              } else {
                onConfirm();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD08C4A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirm',
                style: GoogleFonts.poppins(
                    color: const Color(0xff5E1D04),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty_rounded,
              color: Colors.grey.shade300, size: 36),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seller = widget.seller;

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
        title: Text('Seller Detail',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFFF5E6E6),
                    child: Text(
                      // Real first letter
                      (seller.name ?? 'S')[0].toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Real seller name
                  Text(seller.name ?? '',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04))),
                  const SizedBox(height: 4),
                  // Real business name
                  Text(seller.businessName ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500)),
                  // Seller ID
                  Text(seller.sellerId ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xffD08C4A))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge.role('Seller'),
                      const SizedBox(width: 6),
                      _isVerified
                          ? const StatusBadge(
                          label: 'Verified',
                          backgroundColor: Color(0xFFD4EDDA),
                          textColor: Color(0xFF155724))
                          : const StatusBadge(
                          label: 'Unverified',
                          backgroundColor: Color(0xFFFFF3CD),
                          textColor: Color(0xFF856404)),
                      const SizedBox(width: 6),
                      _isBlocked
                          ? StatusBadge.blocked()
                          : StatusBadge.active(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Unverified Warning Banner
            if (!_isVerified)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF856404)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFF856404), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This seller is not verified. They cannot add products or sell until verified by admin.',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF856404)),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Low performer warning
            if (_isVerified &&
                (_performance['isLowPerformer'] == true))
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8D7DA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF721C24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down_rounded,
                        color: Color(0xFF721C24), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Low performer flagged: Completion rate < 70% or avg rating < 3.0',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF721C24)),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Contact Info
            const SectionTitle(title: 'Contact Info'),
            const SizedBox(height: 8),
            // Real contact data from SellerModel
            InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: seller.email ?? '—'),
            InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: seller.phone ?? '—'),
            InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: seller.businessAddress ?? '—'),
            InfoRow(
                icon: Icons.badge_outlined,
                label: 'CNIC',
                value: seller.cnic ?? '—'),
            const SizedBox(height: 20),

            // ── Order Management
            const SectionTitle(title: 'Order Management'),
            const SizedBox(height: 10),
            !_isVerified
                ? _emptyState(
                'No orders yet.\nSeller must be verified before they can receive orders.')
                : isPerformanceLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A)))
                : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: [
                StatCard(
                    label: 'Total Orders',
                    value:
                    '${_performance['totalOrders'] ?? 0}',
                    icon: Icons.shopping_bag_outlined),
                StatCard(
                    label: 'Delivered',
                    value:
                    '${_performance['deliveredOrders'] ?? 0}',
                    icon: Icons.check_circle_outline),
                StatCard(
                    label: 'Cancelled',
                    value:
                    '${_performance['cancelledOrders'] ?? 0}',
                    icon: Icons.cancel_outlined),
                StatCard(
                    label: 'Returned',
                    value:
                    '${_performance['returnedOrders'] ?? 0}',
                    icon: Icons.keyboard_return),
                StatCard(
                    label: 'Completion',
                    value:
                    '${_performance['completionRate'] ?? 0}%',
                    icon: Icons.bar_chart_outlined),
                StatCard(
                    label: 'Avg Rating',
                    value:
                    '${_performance['avgRating'] ?? 0}',
                    icon: Icons.star_outline),
              ],
            ),
            const SizedBox(height: 20),

            // ── Revenue
            const SectionTitle(title: 'Revenue'),
            const SizedBox(height: 10),
            !_isVerified
                ? _emptyState(
                'No revenue data yet.')
                : isPerformanceLoading
                ? const SizedBox.shrink()
                : StatCard(
                label: 'Total Revenue',
                value:
                'Rs ${(_performance['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                icon: Icons.payments_outlined),
            const SizedBox(height: 28),

            // ── Action buttons
            if (isActionLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                      color: Color(0xffD08C4A)),
                ),
              )
            else ...[
              // ── Verify / Unverify buttons
              Row(
                children: [
                  // Verify button — show if not verified
                  if (!_isVerified)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmDialog(
                          title: 'Verify Seller?',
                          message:
                          'Verify ${seller.name}? They will be able to login and start selling.',
                          onConfirm: _verifySeller,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffD08C4A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Verify Seller',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff5E1D04))),
                      ),
                    ),

                  if (!_isVerified) const SizedBox(width: 12),

                  // Unverify button — show if verified
                  if (_isVerified)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmDialog(
                          title: 'Unverify Seller?',
                          message:
                          'Unverify ${seller.name}? Their account will be blocked and they cannot login.',
                          onConfirm: _unverifySeller,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF3CD),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Unverify Seller',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF856404))),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Block / Unblock button
              AuthButton(
                label: _isBlocked ? 'Unblock Seller' : 'Block Seller',
                onPressed: () {
                  if (_isBlocked) {
                    _showConfirmDialog(
                      title: 'Unblock Seller?',
                      message:
                      'Unblock ${seller.name}? They will regain access.',
                      onConfirm: _unblockSeller,
                    );
                  } else {
                    // Show reason field for block
                    _showConfirmDialog(
                      title: 'Block Seller?',
                      message: 'Block ${seller.name}?',
                      onConfirm: () {},
                      showReasonField: true,
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}