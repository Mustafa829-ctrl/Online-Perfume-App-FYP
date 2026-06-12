import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/rider/auth/rider_register_screen.dart';
import '../../../models/rider_model.dart';
import '../../../services/rider_auth_service.dart';
import 'rider_forgot_password_screen.dart';
import '../rider_homescreen.dart';

class RiderLoginScreen extends StatefulWidget {
  const RiderLoginScreen({super.key});

  @override
  State<RiderLoginScreen> createState() => _RiderLoginScreenState();
}

class _RiderLoginScreenState extends State<RiderLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff5E1D04),
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP DARK SECTION with diagonal cut
            SizedBox(
              height: screenHeight * 0.30,
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
                          width: 68, height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xffD08C4A),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.delivery_dining_rounded,
                              color: Color(0xff5E1D04), size: 34),
                        ),
                        const SizedBox(height: 12),
                        Text('RIDER PORTAL',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 20, fontWeight: FontWeight.bold,
                                color: Colors.white, letterSpacing: 2.5)),
                        const SizedBox(height: 4),
                        Text('Online Perfume',
                            style: GoogleFonts.poppins(fontSize: 11,
                                color: const Color(0xffD08C4A), letterSpacing: 1.5)),
                      ],
                    ),
                  ),

                  // Diagonal cut
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Container(height: 42, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── WHITE CARD BODY
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
                        Text('Welcome Back',
                            style: GoogleFonts.playfairDisplay(fontSize: 24,
                                fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                        const SizedBox(height: 4),
                        Text('Sign in to your rider account',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
                        const SizedBox(height: 24),

                        // Email
                        _buildLabel('Email Address'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: 'you@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your email';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
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
                              color: const Color(0xffD08C4A), size: 20,
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

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const RiderForgotPasswordScreen())),
                            child: Text('Forgot Password?',
                                style: GoogleFonts.poppins(fontSize: 12,
                                    color: const Color(0xffD08C4A),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Login button
                        isLoading
                            ? const Center(child: CircularProgressIndicator(
                                color: Color(0xffD08C4A)))
                            : SizedBox(
                                width: double.infinity, height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    try {
                                      isLoading = true;
                                      setState(() {});

                                      RiderModel rider = await RiderAuthServices()
                                          .loginRider(
                                        email: _emailCtrl.text.trim(),
                                        password: _passwordCtrl.text.trim(),
                                      );

                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                RiderHomeScreen(rider: rider),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      isLoading = false;
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(e.toString(),
                                            style: GoogleFonts.poppins(fontSize: 13)),
                                        backgroundColor: const Color(0xFF721C24),
                                      ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff5E1D04),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: Text('Sign In',
                                      style: GoogleFonts.poppins(fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xffD08C4A))),
                                ),
                              ),
                        const SizedBox(height: 20),
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

  Widget _buildLabel(String text) => Text(text,
      style: GoogleFonts.poppins(fontSize: 13,
          fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)));

  Widget _buildTextField({
    required TextEditingController controller, required String hint,
    required IconData icon, TextInputType keyboardType = TextInputType.text,
    bool obscure = false, Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller, keyboardType: keyboardType,
      obscureText: obscure, validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xff5E1D04)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 20),
        suffixIcon: suffixIcon, filled: true, fillColor: const Color(0xFFFFF8F0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffD08C4A), width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: const Color(0xffD08C4A).withOpacity(0.3), width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffD08C4A), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 0.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
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
