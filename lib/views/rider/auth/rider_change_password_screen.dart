import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/rider_auth_service.dart';

class RiderChangePasswordScreen extends StatefulWidget {
  const RiderChangePasswordScreen({super.key});

  @override
  State<RiderChangePasswordScreen> createState() => _RiderChangePasswordScreenState();
}

class _RiderChangePasswordScreenState extends State<RiderChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _passwordChanged = false;

  @override
  void dispose() {
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
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
                          child: const Icon(Icons.lock_outline_rounded,
                              color: Color(0xff5E1D04), size: 32)),
                      const SizedBox(height: 10),
                      Text('CHANGE PASSWORD',
                          style: GoogleFonts.playfairDisplay(fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Keep your account secure',
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
                child: _passwordChanged ? _successView() : _formView(),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Password',
                style: GoogleFonts.playfairDisplay(fontSize: 24,
                    fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
            const SizedBox(height: 4),
            Text('New password must be at least 8 characters.',
                style: GoogleFonts.poppins(fontSize: 13,
                    color: Colors.grey.shade500, height: 1.5)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Password Requirements',
                    style: GoogleFonts.poppins(fontSize: 12,
                        fontWeight: FontWeight.w600, color: const Color(0xff5E1D04))),
                const SizedBox(height: 6),
                _RequirementRow(text: 'Minimum 8 characters', met: _newCtrl.text.length >= 8),
                _RequirementRow(text: 'At least one number',
                    met: _newCtrl.text.contains(RegExp(r'[0-9]'))),
                _RequirementRow(text: 'At least one special character',
                    met: _newCtrl.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
              ]),
            ),
            const SizedBox(height: 20),

            _buildLabel('Current Password'), const SizedBox(height: 6),
            _buildTextField(controller: _currentCtrl, hint: 'Enter current password',
                icon: Icons.lock_outline, obscure: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xffD08C4A), size: 20),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter current password' : null),
            const SizedBox(height: 16),

            _buildLabel('New Password'), const SizedBox(height: 6),
            _buildTextField(controller: _newCtrl, hint: 'Min. 8 characters',
                icon: Icons.lock_outline, obscure: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xffD08C4A), size: 20),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter new password';
                  if (v.length < 8) return 'Minimum 8 characters';
                  if (v == _currentCtrl.text) return 'Must differ from current password';
                  return null;
                }),
            const SizedBox(height: 16),

            _buildLabel('Confirm New Password'), const SizedBox(height: 6),
            _buildTextField(controller: _confirmCtrl, hint: 'Re-enter new password',
                icon: Icons.lock_outline, obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xffD08C4A), size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm password';
                  if (v != _newCtrl.text) return 'Passwords do not match';
                  return null;
                }),
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

                          await RiderAuthServices().changePassword(
                            currentPassword: _currentCtrl.text.trim(),
                            newPassword: _newCtrl.text.trim(),
                          );

                          if (mounted) setState(() { isLoading = false; _passwordChanged = true; });
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
                      child: Text('Update Password',
                          style: GoogleFonts.poppins(fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffD08C4A))),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xffD08C4A), width: 1.5)),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xffD08C4A), size: 44)),
        const SizedBox(height: 24),
        Text('Password Updated!',
            style: GoogleFonts.playfairDisplay(fontSize: 24,
                fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
        const SizedBox(height: 12),
        Text('Your password has been changed\nsuccessfully.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13,
                color: Colors.grey.shade500, height: 1.6)),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5E1D04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              child: Text('Back to Profile',
                  style: GoogleFonts.poppins(fontSize: 15,
                      fontWeight: FontWeight.w600, color: const Color(0xffD08C4A))),
            )),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: GoogleFonts.poppins(fontSize: 13,
          fontWeight: FontWeight.w600, color: const Color(0xff5E1D04)));

  Widget _buildTextField({
    required TextEditingController controller, required String hint,
    required IconData icon, bool obscure = false, Widget? suffixIcon,
    String? Function(String?)? validator, void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller, obscureText: obscure,
      validator: validator, onChanged: onChanged,
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
            borderSide: BorderSide(color: const Color(0xffD08C4A).withOpacity(0.3), width: 0.5)),
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

class _RequirementRow extends StatelessWidget {
  final String text; final bool met;
  const _RequirementRow({required this.text, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14, color: met ? Colors.green.shade600 : Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 11,
            color: met ? Colors.green.shade600 : Colors.grey.shade500)),
      ]),
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
