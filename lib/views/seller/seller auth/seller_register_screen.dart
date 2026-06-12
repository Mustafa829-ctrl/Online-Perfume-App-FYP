import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/seller_auth_service.dart';
import 'package:online_perfume_app_fyp/views/seller/seller%20auth/seller_login_screen.dart';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Business Info
  final _businessNameCtrl = TextEditingController();
  final _businessAddressCtrl = TextEditingController();
  String _selectedBusinessType = 'Retail';
  final List<String> _businessTypes = ['Retail', 'Wholesale', 'Both'];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _businessNameCtrl.dispose();
    _businessAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SellerAuthServices().registerSeller(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        cnic: _cnicCtrl.text.trim(),
        businessName: _businessNameCtrl.text.trim(),
        businessAddress: _businessAddressCtrl.text.trim(),
        businessType: _selectedBusinessType,
      ).then((user) {
        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xffD08C4A), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Registration Successful',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Your seller account has been created successfully! Your account is pending verification by the admin. You will be notified once verified.',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade700),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SellerLoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E1D04),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Go to Login',
                    style: GoogleFonts.poppins(
                        color: const Color(0xffD08C4A),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff5E1D04),
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP SECTION (dark header with diagonal cut)
            SizedBox(
              height: screenHeight * 0.26,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xff5E1D04),
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xffD08C4A),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.store_mall_directory_rounded,
                            color: Color(0xff5E1D04),
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SELLER PORTAL',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create Your Seller Account',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xffD08C4A),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Container(height: 42, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── WHITE BODY
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Account',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5E1D04),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in your details to register as a seller',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Error message
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8D7DA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFF721C24), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF721C24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ── Personal Info Section
                        _buildSectionHeader('Personal Information'),
                        const SizedBox(height: 12),

                        _buildLabel('Full Name'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Email Address'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: 'you@store.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your email';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Phone Number'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _phoneCtrl,
                          hint: '+92 300 0000000',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your phone';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('CNIC Number'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _cnicCtrl,
                          hint: '00000-0000000-0',
                          icon: Icons.credit_card_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your CNIC';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Password'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _passwordCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xffD08C4A),
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your password';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Confirm Password'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _confirmPasswordCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xffD08C4A),
                              size: 20,
                            ),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm your password';
                            if (v != _passwordCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Business Info Section
                        _buildSectionHeader('Business Information'),
                        const SizedBox(height: 12),

                        _buildLabel('Business Name'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _businessNameCtrl,
                          hint: 'Your shop or brand name',
                          icon: Icons.store_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter business name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Business Address'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _businessAddressCtrl,
                          hint: 'Shop/Office address',
                          icon: Icons.location_on_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter business address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Business Type Dropdown
                        _buildLabel('Business Type'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xffD08C4A).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBusinessType,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xffD08C4A)),
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xff5E1D04)),
                              items: _businessTypes
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(
                                  () => _selectedBusinessType = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Register button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff5E1D04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Color(0xffD08C4A),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xffD08C4A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey.shade500),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SellerLoginScreen()),
                              ),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff5E1D04),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xff5E1D04),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xff5E1D04),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xff5E1D04)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFFFF8F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xffD08C4A), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xffD08C4A).withOpacity(0.3), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xffD08C4A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

// ── Diagonal clipper
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
