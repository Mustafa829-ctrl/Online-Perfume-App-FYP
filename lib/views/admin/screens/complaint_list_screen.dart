import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/complaint_model.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/filter_chip_bar.dart';
import 'package:online_perfume_app_fyp/views/admin/widgets/status_badge.dart';
import 'package:online_perfume_app_fyp/views/admin/screens/complaint_detail_screen.dart';

class AdminComplaintListScreen extends StatefulWidget {
  final String initialFilter;

  const AdminComplaintListScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<AdminComplaintListScreen> createState() =>
      _AdminComplaintListScreenState();
}

class _AdminComplaintListScreenState
    extends State<AdminComplaintListScreen> {
  // Service
  final AdminService _adminService = AdminService();

  // State
  bool isLoading = false;
  List<ComplaintModel> allComplaints = [];
  late String _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
    'Dismissed',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    loadComplaints();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load complaints from Firebase
  Future<void> loadComplaints() async {
    try {
      isLoading = true;
      setState(() {});

      allComplaints = await _adminService.getAllComplaints();

      isLoading = false;
      setState(() {});
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

  // Quick resolve from list
  Future<void> _resolveComplaint(ComplaintModel complaint) async {
    try {
      isLoading = true;
      setState(() {});

      await _adminService.resolveComplaint(
        docId: complaint.docId!,
        reply: complaint.adminReply ?? '',
      );

      await loadComplaints();
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

  // Quick dismiss from list
  Future<void> _dismissComplaint(ComplaintModel complaint) async {
    try {
      isLoading = true;
      setState(() {});

      await _adminService.dismissComplaint(complaint.docId!);

      await loadComplaints();
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

  // Filtered complaints
  List<ComplaintModel> get _filteredComplaints {
    return allComplaints.where((complaint) {
      final matchesFilter = _selectedFilter == 'All' ||
          complaint.status == _selectedFilter;
      final matchesSearch =
          (complaint.buyerName ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
              (complaint.productName ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'Pending':     return const Color(0xFFF8D7DA);
      case 'In Progress': return const Color(0xFFFFE5B4);
      case 'Resolved':    return const Color(0xFFD4EDDA);
      case 'Dismissed':   return const Color(0xFFEEEEEE);
      default:            return const Color(0xFFEEEEEE);
    }
  }

  Color _statusTextColor(String? status) {
    switch (status) {
      case 'Pending':     return const Color(0xFF721C24);
      case 'In Progress': return const Color(0xFF856404);
      case 'Resolved':    return const Color(0xFF155724);
      case 'Dismissed':   return const Color(0xFF333333);
      default:            return const Color(0xFF333333);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complaint Management',
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
        const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04)),
              decoration: InputDecoration(
                hintText: 'Search by buyer or product...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04)
                      .withOpacity(0.4),
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xffD08C4A)),
                filled: true,
                fillColor: const Color(0xFFFFF3CD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // ── Filter Chips
            FilterChipBar(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),
            const SizedBox(height: 16),

            // ── Count
            Text(
              '${_filteredComplaints.length} Complaints Found',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),

            // ── Complaint List
            Expanded(
              child: _filteredComplaints.isEmpty
                  ? Center(
                child: Text(
                  'No complaints found',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xffD08C4A),
                onRefresh: loadComplaints,
                child: ListView.builder(
                  itemCount:
                  _filteredComplaints.length,
                  itemBuilder: (context, index) {
                    final complaint =
                    _filteredComplaints[index];
                    return _ComplaintCard(
                      complaint: complaint,
                      statusBgColor: _statusBgColor(
                          complaint.status),
                      statusTextColor:
                      _statusTextColor(
                          complaint.status),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminComplaintDetailScreen(
                                  complaint: complaint,
                                ),
                          ),
                        );
                        // Reload after coming back
                        loadComplaints();
                      },
                      onResolve: () =>
                          _resolveComplaint(complaint),
                      onDismiss: () =>
                          _dismissComplaint(complaint),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Complaint Card
class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final Color statusBgColor;
  final Color statusTextColor;
  final VoidCallback onTap;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;

  const _ComplaintCard({
    required this.complaint,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.onTap,
    required this.onResolve,
    required this.onDismiss,
  });

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Text(
                    complaint.complaintId ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(complaint.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(
                    label: complaint.status ?? '',
                    backgroundColor: statusBgColor,
                    textColor: statusTextColor,
                  ),
                ],
              ),
            ),

            // ── Middle
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFF5E6E6),
                    child: Text(
                      (complaint.buyerName ?? 'B')[0]
                          .toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.buyerName ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04),
                          ),
                        ),
                        Text(
                          complaint.productName ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          complaint.issue ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: statusTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Bottom — Dismiss & Resolve buttons
            Padding(
              padding:
              const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onDismiss,
                    child: Text(
                      'DISMISS',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onResolve,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xff5E1D04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'RESOLVE',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}