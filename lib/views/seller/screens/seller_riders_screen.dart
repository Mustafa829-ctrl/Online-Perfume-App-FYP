import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/seller_model.dart';
import '../../../models/rider_model.dart';
import '../../../services/rider_service.dart';
import '../../admin/screens/rider_detail_screen.dart';

class SellerRidersScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerRidersScreen({super.key, required this.seller});

  @override
  State<SellerRidersScreen> createState() => SellerRidersScreenState();
}

class SellerRidersScreenState extends State<SellerRidersScreen> {
  final RiderService _riderService = RiderService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Blocked'];

  bool isLoading = false;
  List<RiderModel> _allRiders = [];

  @override
  void initState() {
    super.initState();
    loadRiders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Load Riders
  Future<void> loadRiders() async {
    try {
      isLoading = true;
      setState(() {});

      _allRiders = await _riderService
          .getSellerRiders(widget.seller.docId ?? '');
    } catch (e) {
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
    } finally {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  // ── Add New Rider — full form with vehicle info
  void _showAddRiderDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final vehicleModelCtrl = TextEditingController();
    final vehicleNumberCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    bool isCreating = false;
    bool showPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add New Rider',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04),
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Personal Info
                _DialogLabel(label: 'Personal Information'),
                const SizedBox(height: 8),
                _DialogField(
                    controller: nameCtrl,
                    hint: 'Full Name *',
                    icon: Icons.person_outline),
                const SizedBox(height: 10),
                _DialogField(
                    controller: emailCtrl,
                    hint: 'Email Address *',
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _DialogField(
                    controller: phoneCtrl,
                    hint: 'Phone Number *',
                    icon: Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 10),
                _DialogField(
                    controller: addressCtrl,
                    hint: 'Address',
                    icon: Icons.location_on_outlined),
                const SizedBox(height: 10),
                _DialogField(
                    controller: cnicCtrl,
                    hint: 'CNIC',
                    icon: Icons.credit_card_outlined),
                const SizedBox(height: 16),

                // ── Vehicle Info
                _DialogLabel(label: 'Vehicle Information'),
                const SizedBox(height: 8),
                _DialogField(
                    controller: vehicleModelCtrl,
                    hint: 'Vehicle Model (e.g. Honda 125)',
                    icon: Icons.two_wheeler_outlined),
                const SizedBox(height: 10),
                _DialogField(
                    controller: vehicleNumberCtrl,
                    hint: 'Vehicle Number (e.g. LHR-1234)',
                    icon: Icons.confirmation_number_outlined),
                const SizedBox(height: 10),
                _DialogField(
                    controller: licenseCtrl,
                    hint: 'License Number',
                    icon: Icons.badge_outlined),
                const SizedBox(height: 16),

                // ── Login Credentials
                _DialogLabel(label: 'Login Credentials'),
                const SizedBox(height: 4),
                Text(
                  'These will be shared with the rider to login',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                // Password field with show/hide
                TextField(
                  controller: passwordCtrl,
                  obscureText: !showPassword,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Set Password *',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xffD08C4A), size: 18),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setDialogState(() => showPassword = !showPassword),
                      child: Icon(
                        showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Color(0xFFEEEEEE))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Color(0xFFEEEEEE))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Color(0xffD08C4A))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: isCreating
                  ? null
                  : () async {
                // Validate required fields
                if (nameCtrl.text.isEmpty ||
                    emailCtrl.text.isEmpty ||
                    phoneCtrl.text.isEmpty ||
                    passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Name, Email, Phone and Password are required',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }

                setDialogState(() => isCreating = true);

                final result =
                await _riderService.createRiderBySeller(
                  sellerId: widget.seller.docId ?? '',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  cnic: cnicCtrl.text.trim(),
                  password: passwordCtrl.text.trim(),
                  vehicleModel: vehicleModelCtrl.text.trim(),
                  vehicleNumber: vehicleNumberCtrl.text.trim(),
                  licenseNumber: licenseCtrl.text.trim(),
                );

                setDialogState(() => isCreating = false);

                if (!mounted) return;
                Navigator.pop(context);

                if (result['success'] == true) {
                  // Show credentials dialog
                  _showCredentialsDialog(
                    email: result['email'],
                    password: result['password'],
                    name: nameCtrl.text.trim(),
                  );
                  loadRiders();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'],
                          style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD08C4A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: isCreating
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text('Create Rider',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Show credentials after rider created
  void _showCredentialsDialog({
    required String email,
    required String password,
    required String name,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Color(0xff66BB6A), size: 36),
            ),
            const SizedBox(height: 16),
            Text('Rider Created!',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 6),
            Text('Share these credentials with $name:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 14),
            // Credentials box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 14, color: Color(0xffD08C4A)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(email,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff5E1D04))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 14, color: Color(0xffD08C4A)),
                      const SizedBox(width: 6),
                      Text(password,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff5E1D04))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(' Save these credentials now!',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.orange.shade700)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD08C4A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Done',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Block Rider
  Future<void> _blockRider(String docId, String reason) async {
    try {
      await _riderService.blockRider(
          docId: docId, reason: reason, duration: '', sellerId: '');
      loadRiders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rider blocked successfully',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
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

  // ── Unblock Rider
  Future<void> _unblockRider(String docId) async {
    try {
      await _riderService.unblockRider(docId);
      loadRiders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rider unblocked successfully',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xff66BB6A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
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

  // ── Filtered Riders
  List<RiderModel> get _filteredRiders {
    List<RiderModel> result = _allRiders;

    if (_searchController.text.isNotEmpty) {
      String q = _searchController.text.toLowerCase();
      result = result.where((r) {
        return (r.name?.toLowerCase().contains(q) ?? false) ||
            (r.phone?.contains(q) ?? false) ||
            (r.riderId?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (_selectedFilter == 'Active') {
      result = result.where((r) => r.isBlocked == false).toList();
    } else if (_selectedFilter == 'Blocked') {
      result = result.where((r) => r.isBlocked == true).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final int activeCount =
        _allRiders.where((r) => r.isBlocked == false).length;
    final int blockedCount =
        _allRiders.where((r) => r.isBlocked == true).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
        ),
        title: Text('Rider Management',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _showAddRiderDialog,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('+ Rider',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              children: [
                // ── Summary Chips
                Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: 'Active Riders',
                        count: activeCount,
                        color: const Color(0xff66BB6A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryChip(
                        label: 'Blocked Riders',
                        count: blockedCount,
                        color: const Color(0xffEF5350),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or phone...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xffD08C4A), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFEEEEEE))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFEEEEEE))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xffD08C4A))),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Filter Chips
                Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
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
                          child: Text(filter,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // ── Count
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${_filteredRiders.length} Riders',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04))),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // ── Riders List
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A)))
                : _filteredRiders.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining_outlined,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No riders found',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400)),
                ],
              ),
            )
                : RefreshIndicator(
              color: const Color(0xffD08C4A),
              onRefresh: loadRiders,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _filteredRiders.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final rider = _filteredRiders[index];
                  return _RiderTile(
                    rider: rider,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminRiderDetailScreen(
                            rider: rider,
                            sellerName:
                            rider.sellerName ?? '',
                          ),
                        ),
                      );
                      loadRiders();
                    },
                    onBlock: () => rider.isBlocked == true
                        ? _unblockRider(rider.docId ?? '')
                        : _showBlockDialog(rider),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Block dialog with reason
  void _showBlockDialog(RiderModel rider) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Block Rider',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Block ${rider.name}?',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Reason for blocking',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Color(0xFFEEEEEE))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Color(0xFFEEEEEE))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Color(0xffD08C4A))),
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
              Navigator.pop(context);
              _blockRider(rider.docId ?? '',
                  reasonCtrl.text.trim().isEmpty
                      ? 'Blocked by Seller'
                      : reasonCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Block',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Summary Chip
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$count',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

// ── Rider Tile
class _RiderTile extends StatelessWidget {
  final RiderModel rider;
  final VoidCallback onEdit;
  final VoidCallback onBlock;

  const _RiderTile(
      {required this.rider, required this.onEdit, required this.onBlock});

  @override
  Widget build(BuildContext context) {
    final bool isBlocked = rider.isBlocked == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBlocked ? Colors.red.shade100 : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isBlocked
                    ? const Color(0xFFFCE4EC)
                    : const Color(0xFFFFF3CD),
                child: Text(
                  (rider.name ?? 'R')[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isBlocked
                          ? Colors.red.shade300
                          : const Color(0xffD08C4A)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rider.name ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04))),
                    Text(rider.phone ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBlocked
                      ? const Color(0xFFFCE4EC)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isBlocked ? 'Blocked' : 'Active',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isBlocked
                          ? const Color(0xffEF5350)
                          : const Color(0xff66BB6A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),

          // ── Vehicle Info
          if (rider.vehicleModel != null &&
              rider.vehicleModel!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.two_wheeler_outlined,
                    size: 13, color: Color(0xffD08C4A)),
                const SizedBox(width: 6),
                Text(
                  '${rider.vehicleModel} • ${rider.vehicleNumber ?? ''}',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          if (rider.vehicleModel != null &&
              rider.vehicleModel!.isNotEmpty)
            const SizedBox(height: 10),

          // ── Buttons Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('Edit',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffD08C4A))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onBlock,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isBlocked ? 'Unblock' : 'Block',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isBlocked
                                ? const Color(0xff66BB6A)
                                : Colors.red.shade400),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Block reason if blocked
          if (isBlocked &&
              rider.blockedReason != null &&
              rider.blockedReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 13, color: Colors.red.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Blocked: ${rider.blockedReason}',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.red.shade400)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Dialog Label
class _DialogLabel extends StatelessWidget {
  final String label;
  const _DialogLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xff5E1D04)));
  }
}

// ── Dialog Input Field
class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;

  const _DialogField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon:
        Icon(icon, color: const Color(0xffD08C4A), size: 18),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffD08C4A))),
      ),
    );
  }
}