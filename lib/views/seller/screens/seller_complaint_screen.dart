import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerComplaintsScreen extends StatefulWidget {
  const SellerComplaintsScreen({super.key});

  @override
  State<SellerComplaintsScreen> createState() =>
      _SellerComplaintsScreenState();
}

class _SellerComplaintsScreenState extends State<SellerComplaintsScreen> {
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Selected filter
  String _selectedFilter = 'All';

  // Filter options
  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  // Dummy complaints data
  final List<Map<String, dynamic>> _allComplaints = [
    {
      'complaintId': '#CMP-001',
      'orderId': '#ORD-556',
      'buyerName': 'John Serena',
      'buyerPhone': '+92 300 1234567',
      'product': 'Midnight Oud - 50ml',
      'complaintType': 'Scent Issue',
      'description':
      'The scent profile feels weak and watery. Not as described on the product page.',
      'status': 'Pending',
      'date': '2 Hours Ago',
      'sellerReply': '',
      'images': true,
    },
    {
      'complaintId': '#CMP-002',
      'orderId': '#ORD-6743',
      'buyerName': 'Marcus Joseph',
      'buyerPhone': '+92 311 9876543',
      'product': 'Rose Amber - 50ml',
      'complaintType': 'Wrong Product',
      'description':
      'I received the wrong product. I ordered Rose Amber 50ml but received 30ml.',
      'status': 'In Progress',
      'date': 'Yesterday',
      'sellerReply':
      'We apologize for the inconvenience. We are processing a replacement.',
      'images': false,
    },
    {
      'complaintId': '#CMP-003',
      'orderId': '#ORD-6740',
      'buyerName': 'Sara Khan',
      'buyerPhone': '+92 333 5556677',
      'product': 'Oud Prestige - 100ml',
      'complaintType': 'Damaged Product',
      'description':
      'The bottle arrived broken. The packaging was damaged during delivery.',
      'status': 'Resolved',
      'date': '3 Days Ago',
      'sellerReply':
      'We have issued a full refund for this order. Sorry for the experience.',
      'images': true,
    },
    {
      'complaintId': '#CMP-004',
      'orderId': '#ORD-6738',
      'buyerName': 'Ahmed Malik',
      'buyerPhone': '+92 321 1112233',
      'product': 'Fresh Citrus - 100ml',
      'complaintType': 'Late Delivery',
      'description':
      'My order was supposed to arrive 5 days ago. Still waiting.',
      'status': 'Closed',
      'date': '5 Days Ago',
      'sellerReply': 'Order has been delivered. Closing this complaint.',
      'images': false,
    },
  ];

  // Filtered complaints
  List<Map<String, dynamic>> get _filteredComplaints {
    List<Map<String, dynamic>> result = _allComplaints;

    // Search
    if (_searchController.text.isNotEmpty) {
      result = result.where((c) {
        return c['buyerName']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()) ||
            c['complaintId']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            c['product']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Filter by status
    if (_selectedFilter != 'All') {
      result = result
          .where((c) => c['status'] == _selectedFilter)
          .toList();
    }

    return result;
  }

  // Status color helper
  Map<String, Color> _statusColors(String status) {
    switch (status) {
      case 'Pending':
        return {
          'text': const Color(0xffFFA726),
          'bg': const Color(0xFFFFF3CD),
        };
      case 'In Progress':
        return {
          'text': const Color(0xff42A5F5),
          'bg': const Color(0xFFE3F2FD),
        };
      case 'Resolved':
        return {
          'text': const Color(0xff66BB6A),
          'bg': const Color(0xFFE8F5E9),
        };
      case 'Closed':
        return {
          'text': Colors.grey,
          'bg': const Color(0xFFF5F5F5),
        };
      default:
        return {
          'text': Colors.grey,
          'bg': const Color(0xFFF5F5F5),
        };
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Show complaint detail + reply bottom sheet
  void _showComplaintSheet(Map<String, dynamic> complaint) {
    final TextEditingController replyController = TextEditingController(
      text: complaint['sellerReply'] ?? '',
    );
    String selectedStatus = complaint['status'];
    final List<String> statusOptions = [
      'Pending',
      'In Progress',
      'Resolved',
      'Closed',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Complaint ID + Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      complaint['complaintId'],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        complaint['complaintType'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffD08C4A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Buyer info
                _SheetInfoRow(
                  icon: Icons.person_outline,
                  label: 'Buyer',
                  value: complaint['buyerName'],
                ),
                const SizedBox(height: 6),
                _SheetInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: complaint['buyerPhone'],
                ),
                const SizedBox(height: 6),
                _SheetInfoRow(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Order',
                  value: complaint['orderId'],
                ),
                const SizedBox(height: 6),
                _SheetInfoRow(
                  icon: Icons.local_florist_outlined,
                  label: 'Product',
                  value: complaint['product'],
                ),
                const SizedBox(height: 14),

                // Complaint description
                Text(
                  'Complaint',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    complaint['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Update status
                Text(
                  'Update Status',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFEEEEEE)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xffD08C4A),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04),
                      ),
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(
                                () => selectedStatus = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Reply field
                Text(
                  'Your Reply',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: replyController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                    'Type your response to the buyer...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFEEEEEE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xffD08C4A)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        complaint['status'] = selectedStatus;
                        complaint['sellerReply'] =
                            replyController.text;
                      });
                      // TODO: Save reply and status to Firebase
                      // FirebaseFirestore.instance
                      //     .collection('complaints')
                      //     .doc(complaint['complaintId'])
                      //     .update({
                      //   'status': selectedStatus,
                      //   'sellerReply': replyController.text,
                      //   'repliedAt': Timestamp.now(),
                      // });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reply sent successfully',
                            style:
                            GoogleFonts.poppins(fontSize: 13),
                          ),
                          backgroundColor:
                          const Color(0xffD08C4A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD08C4A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Send Reply',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count by status
    final int pendingCount = _allComplaints
        .where((c) => c['status'] == 'Pending')
        .length;
    final int inProgressCount = _allComplaints
        .where((c) => c['status'] == 'In Progress')
        .length;
    final int resolvedCount = _allComplaints
        .where((c) => c['status'] == 'Resolved')
        .length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5E1D04),
            size: 20,
          ),
        ),
        title: Text(
          'Complaints',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              children: [
                // ── Summary Row ────────────────────────────
                Row(
                  children: [
                    _SummaryChip(
                      label: 'Pending',
                      count: pendingCount,
                      color: const Color(0xffFFA726),
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'In Progress',
                      count: inProgressCount,
                      color: const Color(0xff42A5F5),
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'Resolved',
                      count: resolvedCount,
                      color: const Color(0xff66BB6A),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Search Bar ─────────────────────────────
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search by buyer, product or ID...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xffD08C4A),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xffD08C4A)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Filter Chips ───────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xffD08C4A)
                                : const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xffD08C4A)
                                  : const Color(0xFFEEEEEE),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // ── Count ──────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredComplaints.length} Complaints',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // ── Complaints List ──────────────────────────────
          Expanded(
            child: _filteredComplaints.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_problem_outlined,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No complaints found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _filteredComplaints.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final complaint = _filteredComplaints[index];
                final colors =
                _statusColors(complaint['status']);
                return _ComplaintTile(
                  complaint: complaint,
                  statusColors: colors,
                  onTap: () =>
                      _showComplaintSheet(complaint),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Chip ─────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Complaint Tile ────────────────────────────────────────────
class _ComplaintTile extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final Map<String, Color> statusColors;
  final VoidCallback onTap;

  const _ComplaintTile({
    required this.complaint,
    required this.statusColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row ──────────────────────────────────
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFFF3CD),
                  child: Text(
                    complaint['buyerName'][0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffD08C4A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint['buyerName'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04),
                        ),
                      ),
                      Text(
                        '${complaint['complaintId']} • ${complaint['date']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColors['bg'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    complaint['status'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColors['text'],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Product + Complaint Type ──────────────────
            Row(
              children: [
                const Icon(Icons.local_florist_outlined,
                    size: 13, color: Color(0xffD08C4A)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    complaint['product'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    complaint['complaintType'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xffD08C4A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Description ───────────────────────────────
            Text(
              complaint['description'],
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // ── Reply preview if exists ───────────────────
            if (complaint['sellerReply'] != null &&
                complaint['sellerReply'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply,
                        size: 13, color: Color(0xff66BB6A)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        complaint['sellerReply'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xff66BB6A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // ── Tap to respond ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  complaint['sellerReply'] != null &&
                      complaint['sellerReply']
                          .toString()
                          .isNotEmpty
                      ? 'Update Reply →'
                      : 'Tap to Respond →',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffD08C4A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet Info Row ────────────────────────────────────────────
class _SheetInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SheetInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xffD08C4A)),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xff5E1D04),
            ),
          ),
        ),
      ],
    );
  }
}