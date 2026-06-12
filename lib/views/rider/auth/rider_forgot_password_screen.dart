import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/rider_auth_service.dart';

class RiderForgotPasswordScreen extends StatefulWidget {
  const RiderForgotPasswordScreen({super.key});

  @override
  State<RiderForgotPasswordScreen> createState() => _RiderForgotPasswordScreenState();
}

class _RiderForgotPasswordScreenState extends State<RiderForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff5E1D04),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.28,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xff5E1D04),
                    child: Column(children: [
                      Align(alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18),
                            onPressed: () => Navigator.pop(context),
                          )),
                      Container(width: 64, height: 64,
                          decoration: BoxDecoration(color: const Color(0xffD08C4A),
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.lock_reset_rounded,
                              color: Color(0xff5E1D04), size: 32)),
                      const SizedBox(height: 10),
                      Text('RESET PASSWORD',
                          style: GoogleFonts.playfairDisplay(fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('We\'ll send a reset link',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: const Color(0xffD08C4A))),
                    ]),
                  ),
                  Positioned(bottom: 0, left: 0, right: 0,
                      child: ClipPath(clipper: _DiagonalClipper(),
                          child: Container(height: 40, color: Colors.white))),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                child: _emailSent ? _successView() : _formView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forgot Password?',
              style: GoogleFonts.playfairDisplay(fontSize: 24,
                  fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
          const SizedBox(height: 8),
          Text('Enter your registered email and we\'ll send you a reset link.',
              style: GoogleFonts.poppins(fontSize: 13,
                  color: Colors.grey.shade500, height: 1.5)),
          const SizedBox(height: 28),

          Text('Email Address',
              style: GoogleFonts.poppins(fontSize: 13,
                  fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xff5E1D04)),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Invalid email address';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'you@email.com',
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xffD08C4A), size: 20),
              filled: true, fillColor: const Color(0xFFFFF8F0),
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
          ),
          const SizedBox(height: 28),

          isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
              : SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      try {
                        isLoading = true;
                        setState(() {});

                        await RiderAuthServices()
                            .forgotPassword(email: _emailCtrl.text.trim());

                        if (mounted) setState(() { isLoading = false; _emailSent = true; });
                      } catch (e) {
                        isLoading = false;
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                        elevation: 0),
                    child: Text('Send Reset Link',
                        style: GoogleFonts.poppins(fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xffD08C4A))),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffD08C4A), width: 1.5)),
          child: const Icon(Icons.mark_email_read_outlined,
              color: Color(0xffD08C4A), size: 40),
        ),
        const SizedBox(height: 24),
        Text('Email Sent!',
            style: GoogleFonts.playfairDisplay(fontSize: 24,
                fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        const SizedBox(height: 12),
        Text('We\'ve sent a reset link to\n${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13,
                color: Colors.grey.shade500, height: 1.6)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5E1D04),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0),
            child: Text('Back to Login',
                style: GoogleFonts.poppins(fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffD08C4A))),
          ),
        ),
      ],
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
