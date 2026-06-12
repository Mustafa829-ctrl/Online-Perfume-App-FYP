import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/auth_button.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  // Service
  final AdminService _adminService = AdminService();

  // State
  bool isLoading = false;
  late bool _isBlocked;
  final TextEditingController _blockReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.user['isBlocked'] ?? false;
  }

  @override
  void dispose() {
    _blockReasonController.dispose();
    super.dispose();
  }

  // Format timestamp
  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  // Block or unblock based on current status
  void _toggleBlockStatus() {
    _blockReasonController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          _isBlocked ? 'Unblock User?' : 'Block User?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isBlocked
                  ? 'Are you sure you want to unblock ${widget.user['name']}?'
                  : 'Are you sure you want to block ${widget.user['name']}?',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            // Show reason field only when blocking
            if (!_isBlocked) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _blockReasonController,
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
              _isBlocked ? _unblockUser() : _blockUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD08C4A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(
                color: const Color(0xff5E1D04),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Block user based on type
  Future<void> _blockUser() async {
    try {
      isLoading = true;
      setState(() {});

      final String type = widget.user['type'] ?? 'buyer';
      final String docId = widget.user['docId'] ?? '';
      final String reason = _blockReasonController.text.trim();

      if (type == 'buyer') {
        await _adminService.blockBuyer(
            buyerId: docId, reason: reason);
      } else if (type == 'seller') {
        await _adminService.blockSeller(
            sellerId: docId, reason: reason);
      } else if (type == 'rider') {
        await _adminService.blockRider(
            riderId: docId, reason: reason);
      }

      setState(() {
        _isBlocked = true;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.user['name']} has been blocked',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: Colors.red.shade400,
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

  // Unblock user based on type
  Future<void> _unblockUser() async {
    try {
      isLoading = true;
      setState(() {});

      final String type = widget.user['type'] ?? 'buyer';
      final String docId = widget.user['docId'] ?? '';

      if (type == 'buyer') {
        await _adminService.unblockBuyer(docId);
      } else if (type == 'seller') {
        await _adminService.unblockSeller(docId);
      } else if (type == 'rider') {
        await _adminService.unblockRider(docId);
      }

      setState(() {
        _isBlocked = false;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.user['name']} has been unblocked',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: const Color(0xff66BB6A),
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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

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
          'User Detail',
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
              child: CircularProgressIndicator(
                  color: Color(0xffD08C4A)),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ── Profile Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFF5E6E6),
                    backgroundImage:
                        user['profileImageUrl'] != null &&
                                (user['profileImageUrl'] as String)
                                    .isNotEmpty
                            ? NetworkImage(
                                user['profileImageUrl'])
                            : null,
                    child: user['profileImageUrl'] == null ||
                            (user['profileImageUrl'] as String)
                                .isEmpty
                        ? Text(
                            (user['name'] as String)[0]
                                .toUpperCase(),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff5E1D04),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // ── Name
                  Text(
                    user['name'] ?? '',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Role & Status badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge.role(user['role'] ?? 'Customer'),
                      const SizedBox(width: 8),
                      _isBlocked
                          ? StatusBadge.blocked()
                          : StatusBadge.active(),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Info Rows
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user['email'] ?? '',
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: user['phone'] ?? 'N/A',
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: user['address'] ?? 'N/A',
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Role',
                    value: user['role'] ?? '',
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Joined',
                    value: _formatDate(user['createdAt']),
                  ),

                  // ── Show block reason if blocked
                  if (_isBlocked &&
                      user['blockedReason'] != null &&
                      (user['blockedReason'] as String).isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.red.shade400,
                              size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Blocked: ${user['blockedReason']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red.shade400),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // ── Block / Unblock Button
                  AuthButton(
                    label: _isBlocked
                        ? 'Unblock User'
                        : 'Block User',
                    onPressed: _toggleBlockStatus,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

// ── Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffD08C4A), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xff5E1D04),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
