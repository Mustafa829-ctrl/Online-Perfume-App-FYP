import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/services/user_service.dart';

class BuyerChangePasswordScreen extends StatefulWidget {
  const BuyerChangePasswordScreen({super.key});

  @override
  State<BuyerChangePasswordScreen> createState() =>
      _BuyerChangePasswordScreenState();
}

class _BuyerChangePasswordScreenState extends State<BuyerChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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
      await UserService().changePassword(
        currentPassword: _currentPasswordCtrl.text.trim(),
        newPassword: _newPasswordCtrl.text.trim(),
      ).then((_) {
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
                Text('Password Updated',
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04),
                        fontSize: 16)),
              ]),
              content: Text(
                'Your password has been changed successfully!',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5E1D04),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Done',
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        Text('Change Password',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff5E1D04),
                            )),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your current password and set a new one',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 28),

                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8D7DA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF721C24)
                                      .withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFF721C24), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_errorMessage!,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF721C24))),
                                ),
                              ],
                            ),
                          ),

                        _buildLabel('Current Password'),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _currentPasswordCtrl,
                          hint: 'Enter current password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscureCurrent,
                          suffix: _eyeButton(_obscureCurrent,
                              () => setState(() => _obscureCurrent = !_obscureCurrent)),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Current password is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('New Password'),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _newPasswordCtrl,
                          hint: 'Min. 6 characters',
                          icon: Icons.lock_reset_rounded,
                          obscure: _obscureNew,
                          suffix: _eyeButton(_obscureNew,
                              () => setState(() => _obscureNew = !_obscureNew)),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'New password is required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            if (v == _currentPasswordCtrl.text)
                              return 'Must be different from current';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Confirm New Password'),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _confirmPasswordCtrl,
                          hint: 'Re-enter new password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscureConfirm,
                          suffix: _eyeButton(_obscureConfirm,
                              () => setState(() => _obscureConfirm = !_obscureConfirm)),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please confirm password';
                            if (v != _newPasswordCtrl.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff5E1D04),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor:
                                  const Color(0xff5E1D04).withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Color(0xffD08C4A),
                                        strokeWidth: 2))
                                : Text('Update Password',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xffD08C4A),
                                      letterSpacing: 0.5,
                                    )),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 180,
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
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
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
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  'Security Settings',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
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
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: const Color(0xffD08C4A),
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}
