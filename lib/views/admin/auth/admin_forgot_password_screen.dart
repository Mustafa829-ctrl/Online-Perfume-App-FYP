import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/admin_auth_service.dart';

import 'admin_login_screen.dart';

class AdminForgotPasswordScreen extends StatefulWidget {
  const AdminForgotPasswordScreen({super.key});

  @override
  State<AdminForgotPasswordScreen> createState() =>
      _AdminForgotPasswordScreenState();
}

class _AdminForgotPasswordScreenState
    extends State<AdminForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AdminAuthService()
          .resetPassword(email: _emailCtrl.text.trim())
          .then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
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
                          child: const Icon(Icons.lock_reset_rounded,
                              color: Color(0xff5E1D04), size: 34),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ADMIN PORTAL',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Password Recovery',
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
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
                  child: _emailSent
                      ? _buildSuccessState()
                      : _buildFormState(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFD4EDDA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              color: Color(0xFF155724), size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Email Sent!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent a password reset link to\n${_emailCtrl.text.trim()}\n\nPlease check your inbox and follow the instructions.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.grey.shade500, height: 1.6),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5E1D04),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              'Back to Login',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xffD08C4A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() {
            _emailSent = false;
            _emailCtrl.clear();
          }),
          child: Text(
            'Resend Email',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xffD08C4A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios,
                    color: Color(0xff5E1D04), size: 16),
                Text('Back',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Forgot Password?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your registered email to receive a reset link',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

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
                    child: Text(_errorMessage!,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF721C24))),
                  ),
                ],
              ),
            ),

          Text('Email Address',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff5E1D04))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xff5E1D04)),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'admin@perfume.com',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: Color(0xffD08C4A), size: 20),
              filled: true,
              fillColor: const Color(0xFFFFF8F0),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xffD08C4A), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: const Color(0xffD08C4A).withOpacity(0.3),
                    width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xffD08C4A), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.red, width: 0.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5E1D04),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Color(0xffD08C4A), strokeWidth: 2))
                  : Text(
                      'Send Reset Link',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffD08C4A),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Remember your password? ',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey.shade500)),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminLoginScreen()),
                ),
                child: Text('Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
