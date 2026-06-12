import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/user_service.dart';

import 'buyer_login_screen.dart';

class BuyerSignupScreen extends StatefulWidget {
  const BuyerSignupScreen({super.key});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await UserService().registerUser(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      ).then((user) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffD08C4A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: Color(0xffD08C4A), size: 24),
                ),
                const SizedBox(width: 10),
                Text('Account Created!',
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                        fontSize: 16)),
              ]),
              content: Text(
                'Please verify your email to complete registration.',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const BuyerLoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E1D04),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Go to Login',
                      style: GoogleFonts.poppins(
                          color: const Color(0xffD08C4A),
                          fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header
                  _buildHeader(),

                  // ── Form
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle('Create Account',
                              'Join the world of luxury fragrances'),
                          const SizedBox(height: 24),

                          if (_errorMessage != null) _buildError(),

                          _buildLabel('Full Name'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _nameCtrl,
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Email Address'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _emailCtrl,
                            hint: 'you@example.com',
                            icon: Icons.email_outlined,
                            keyboard: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email is required';
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Phone Number'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _phoneCtrl,
                            hint: '+92 300 0000000',
                            icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Phone is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Password'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _passwordCtrl,
                            hint: 'Min. 6 characters',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffix: _eyeButton(
                                _obscurePassword,
                                () => setState(() =>
                                    _obscurePassword = !_obscurePassword)),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password is required';
                              if (v.length < 6)
                                return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Confirm Password'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _confirmPasswordCtrl,
                            hint: 'Re-enter password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureConfirm,
                            suffix: _eyeButton(
                                _obscureConfirm,
                                () => setState(() =>
                                    _obscureConfirm = !_obscureConfirm)),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Please confirm password';
                              if (v != _passwordCtrl.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          _buildButton('Create Account', _isLoading, _register),
                          const SizedBox(height: 20),

                          _buildDivider(),
                          const SizedBox(height: 16),

                          _buildGoogleButton(),
                          const SizedBox(height: 20),

                          _buildBottomLink(
                            'Already have an account? ',
                            'Sign In',
                            () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BuyerLoginScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xff5E1D04),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffD08C4A).withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffD08C4A).withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xffD08C4A),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffD08C4A).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.spa_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Essence of Luxury',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium Fragrance Collection',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xffD08C4A),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5E1D04),
            )),
        const SizedBox(height: 4),
        Text(subtitle,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF721C24).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFF721C24), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF721C24))),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xff5E1D04),
        ));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xff5E1D04)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFFFF8F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: const Color(0xffD08C4A).withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xffD08C4A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscure
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: const Color(0xffD08C4A),
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildButton(String label, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff5E1D04),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xff5E1D04).withOpacity(0.3),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A), strokeWidth: 2))
            : Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffD08C4A),
                  letterSpacing: 0.5,
                )),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or continue with',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade400)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ],
    );
  }

  // ✅ Fixed Google button — no Image.network
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Google sign in
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: const Color(0xff5E1D04).withOpacity(0.2), width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.g_mobiledata,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff5E1D04),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLink(String text, String link, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade500)),
        GestureDetector(
          onTap: onTap,
          child: Text(link,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              )),
        ),
      ],
    );
  }
}
