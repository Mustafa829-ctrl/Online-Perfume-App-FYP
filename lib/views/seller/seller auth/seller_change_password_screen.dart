import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/seller_auth_service.dart';

class SellerChangePasswordScreen extends StatefulWidget {
  const SellerChangePasswordScreen({super.key});

  @override
  State<SellerChangePasswordScreen> createState() =>
      _SellerChangePasswordScreenState();
}

class _SellerChangePasswordScreenState
    extends State<SellerChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SellerAuthServices().changePassword(
        currentPassword: _currentPasswordCtrl.text.trim(),
        newPassword: _newPasswordCtrl.text.trim(),
      ).then((_) {
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
                    'Password Changed',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Your password has been changed successfully!',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade700),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E1D04),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Done',
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
                            Icons.lock_reset_rounded,
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
                          'Change Your Password',
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
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_back_ios,
                                  color: Color(0xff5E1D04), size: 16),
                              Text(
                                'Back',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xff5E1D04),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Change Password',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5E1D04),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your current password and set a new one',
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

                        // ── Current Password
                        _buildLabel('Current Password'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _currentPasswordCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscureCurrent,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xffD08C4A),
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please enter current password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── New Password
                        _buildLabel('New Password'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _newPasswordCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscureNew,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xffD08C4A),
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please enter new password';
                            if (v.length < 6) return 'Minimum 6 characters';
                            if (v == _currentPasswordCtrl.text)
                              return 'New password must be different';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Confirm New Password
                        _buildLabel('Confirm New Password'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _confirmPasswordCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xffD08C4A),
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please confirm new password';
                            if (v != _newPasswordCtrl.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // ── Change Password Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
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
                                    'Update Password',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xffD08C4A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
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
        hintStyle:
            GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
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
