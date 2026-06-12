import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final AdminService _adminService = AdminService();

  bool isLoading = false;
  String _selectedRole = 'Seller';
  final List<String> _roles = ['Seller', 'Rider'];
  bool _obscurePassword = true;

  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _addressController  = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter full name';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter email address';
    }
    if (!_emailController.text.contains('@')) {
      return 'Please enter a valid email';
    }
    if (_passwordController.text.trim().isEmpty) {
      return 'Please enter password';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (_addressController.text.trim().isEmpty) {
      return 'Please enter address';
    }
    return null;
  }

  Future<void> _createUser() async {
    final error = _validate();
    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    try {
      setState(() => isLoading = true);

      if (_selectedRole == 'Seller') {
        await _adminService.addSeller(
          name:     _nameController.text.trim(),
          email:    _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone:    _phoneController.text.trim(),
          address:  _addressController.text.trim(),
        );
      } else {
        await _adminService.addRider(
          name:     _nameController.text.trim(),
          email:    _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone:    _phoneController.text.trim(),
          address:  _addressController.text.trim(),
        );
      }

      setState(() => isLoading = false);

      if (mounted) {
        _showSnackBar('$_selectedRole account created successfully');
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();
        _addressController.clear();
        setState(() => _selectedRole = 'Seller');
      }
    } catch (e) {
      setState(() => isLoading = false);
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
          : const Color(0xffD08C4A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Add User',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xffD08C4A)
                        .withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: Color(0xffD08C4A), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The user can login directly with the email and password you set.',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xff5E1D04)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Role selector
            _fieldLabel('Select Role'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFEEEEEE)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xffD08C4A)),
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xff5E1D04)),
                  onChanged: (val) =>
                      setState(() => _selectedRole = val!),
                  items: _roles
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Row(children: [
                      Icon(
                        role == 'Seller'
                            ? Icons.storefront_outlined
                            : Icons
                            .delivery_dining_outlined,
                        color: const Color(0xffD08C4A),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(role,
                          style: GoogleFonts.poppins(
                              fontSize: 13)),
                    ]),
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Role info badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedRole == 'Seller'
                    ? const Color(0xFFFFF3CD)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedRole == 'Seller'
                          ? Icons.storefront_outlined
                          : Icons.delivery_dining_outlined,
                      size: 13,
                      color: _selectedRole == 'Seller'
                          ? const Color(0xffD08C4A)
                          : const Color(0xff42A5F5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedRole == 'Seller'
                          ? 'Stored in sellers collection'
                          : 'Stored in riders collection',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _selectedRole == 'Seller'
                            ? const Color(0xffD08C4A)
                            : const Color(0xff42A5F5),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 24),

            // ── Personal info section
            Text('Personal Information',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 14),

            _FormField(
              label: 'Full Name',
              controller: _nameController,
              hint: 'Enter full name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),

            _FormField(
              label: 'Email Address',
              controller: _emailController,
              hint: 'Enter email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            // ── Password field
            _fieldLabel('Password'),
            const SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff5E1D04)),
              decoration: InputDecoration(
                hintText: 'Minimum 6 characters',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400),
                prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xffD08C4A),
                    size: 18),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() =>
                  _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFEEEEEE))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFEEEEEE))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xffD08C4A))),
              ),
            ),
            const SizedBox(height: 14),

            _FormField(
              label: 'Phone Number',
              controller: _phoneController,
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _FormField(
              label: 'Address',
              controller: _addressController,
              hint: 'Enter address',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),

            // ── Seller verification note
            if (_selectedRole == 'Seller') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.verified_outlined,
                      color: Color(0xff66BB6A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seller account will be created with verification pending. Verify from the Sellers screen.',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xff66BB6A)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
            ],

            // ── Create button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2))
                    : Text(
                  'Create $_selectedRole Account',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500));
  }
}

// ── Reusable form field
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xff5E1D04)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 12, color: Colors.grey.shade400),
            prefixIcon: Icon(icon,
                color: const Color(0xffD08C4A), size: 18),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFEEEEEE))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFEEEEEE))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xffD08C4A))),
          ),
        ),
      ],
    );
  }
}