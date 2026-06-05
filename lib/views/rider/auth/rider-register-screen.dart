import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/views/rider/auth/rider-login.dart';
import 'package:provider/provider.dart';
import '../../../provider/rider-provider.dart';

class RiderRegisterScreen extends StatefulWidget {
  const RiderRegisterScreen({super.key});

  @override
  State<RiderRegisterScreen> createState() => _RiderRegisterScreenState();
}

class _RiderRegisterScreenState extends State<RiderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _vehicleNumberCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cnicCtrl.dispose();
    _licenseCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<RiderProvider>();
    final success = await provider.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      cnic: _cnicCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      vehicleModel: _vehicleModelCtrl.text.trim(),
      vehicleNumber: _vehicleNumberCtrl.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.green.shade600,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RiderLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff5E1D04),
      body: SafeArea(
        child: Column(
          children: [
            // Top section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xffD08C4A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: Color(0xff5E1D04), size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'CREATE ACCOUNT',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Rider Registration',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xffD08C4A),
                    ),
                  ),
                ],
              ),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _StepDot(active: _currentStep >= 0, label: 'Personal'),
                  _StepLine(active: _currentStep >= 1),
                  _StepDot(active: _currentStep >= 1, label: 'Vehicle'),
                  _StepLine(active: _currentStep >= 2),
                  _StepDot(active: _currentStep >= 2, label: 'Security'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error
                        Consumer<RiderProvider>(
                          builder: (_, provider, __) {
                            if (provider.errorMessage == null) {
                              return const SizedBox.shrink();
                            }
                            return Container(
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
                                      provider.errorMessage!,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF721C24)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        if (_currentStep == 0) ..._personalFields(),
                        if (_currentStep == 1) ..._vehicleFields(),
                        if (_currentStep == 2) ..._securityFields(),

                        const SizedBox(height: 24),

                        // Navigation buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _currentStep--),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xff5E1D04),
                                    side: const BorderSide(
                                        color: Color(0xff5E1D04)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text('Back',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Consumer<RiderProvider>(
                                builder: (_, provider, __) {
                                  return ElevatedButton(
                                    onPressed: provider.isLoading
                                        ? null
                                        : () {
                                      if (_currentStep < 2) {
                                        if (_formKey.currentState!
                                            .validate()) {
                                          setState(
                                                  () => _currentStep++);
                                        }
                                      } else {
                                        _register();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xffD08C4A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      elevation: 0,
                                    ),
                                    child: provider.isLoading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Text(
                                      _currentStep < 2
                                          ? 'Continue'
                                          : 'Create Account',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade500)),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const RiderLoginScreen()),
                              ),
                              child: Text('Sign In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff5E1D04),
                                  )),
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

  List<Widget> _personalFields() => [
    _sectionTitle('Personal Information'),
    const SizedBox(height: 16),
    _buildLabel('Full Name'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _nameCtrl,
        hint: 'Muhammad Ali',
        icon: Icons.person_outline,
        validator: (v) =>
        v == null || v.isEmpty ? 'Name is required' : null),
    const SizedBox(height: 14),
    _buildLabel('Email Address'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _emailCtrl,
        hint: 'you@email.com',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Email is required';
          if (!v.contains('@')) return 'Invalid email';
          return null;
        }),
    const SizedBox(height: 14),
    _buildLabel('Phone Number'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _phoneCtrl,
        hint: '+92 300 1234567',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        validator: (v) =>
        v == null || v.isEmpty ? 'Phone is required' : null),
    const SizedBox(height: 14),
    _buildLabel('Address'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _addressCtrl,
        hint: 'House #, Street, City',
        icon: Icons.location_on_outlined,
        validator: (v) =>
        v == null || v.isEmpty ? 'Address is required' : null),
    const SizedBox(height: 14),
    _buildLabel('CNIC Number'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _cnicCtrl,
        hint: '35201-1234567-1',
        icon: Icons.badge_outlined,
        keyboardType: TextInputType.number,
        validator: (v) =>
        v == null || v.isEmpty ? 'CNIC is required' : null),
  ];

  List<Widget> _vehicleFields() => [
    _sectionTitle('Vehicle Information'),
    const SizedBox(height: 16),
    _buildLabel('Driving License Number'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _licenseCtrl,
        hint: 'LHR-123456',
        icon: Icons.credit_card_outlined,
        validator: (v) =>
        v == null || v.isEmpty ? 'License number is required' : null),
    const SizedBox(height: 14),
    _buildLabel('Vehicle Model'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _vehicleModelCtrl,
        hint: 'Honda CD 70',
        icon: Icons.two_wheeler_outlined,
        validator: (v) =>
        v == null || v.isEmpty ? 'Vehicle model is required' : null),
    const SizedBox(height: 14),
    _buildLabel('Vehicle Registration Number'),
    const SizedBox(height: 6),
    _buildTextField(
        controller: _vehicleNumberCtrl,
        hint: 'LHR-1234',
        icon: Icons.confirmation_number_outlined,
        validator: (v) =>
        v == null || v.isEmpty ? 'Vehicle number is required' : null),
  ];

  List<Widget> _securityFields() => [
    _sectionTitle('Account Security'),
    const SizedBox(height: 16),
    _buildLabel('Password'),
    const SizedBox(height: 6),
    _buildTextField(
      controller: _passwordCtrl,
      hint: 'Min. 8 characters',
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
        onPressed: () =>
            setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 8) return 'Minimum 8 characters';
        return null;
      },
    ),
    const SizedBox(height: 14),
    _buildLabel('Confirm Password'),
    const SizedBox(height: 6),
    _buildTextField(
      controller: _confirmPasswordCtrl,
      hint: 'Re-enter password',
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
        onPressed: () =>
            setState(() => _obscureConfirm = !_obscureConfirm),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm password';
        if (v != _passwordCtrl.text) return 'Passwords do not match';
        return null;
      },
    ),
  ];

  Widget _sectionTitle(String text) => Text(
    text,
    style: GoogleFonts.playfairDisplay(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color(0xff5E1D04),
    ),
  );

  Widget _buildLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xff5E1D04),
    ),
  );

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
      style:
      GoogleFonts.poppins(fontSize: 14, color: const Color(0xff5E1D04)),
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

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xffD08C4A) : Colors.white,
            border: Border.all(
              color: active
                  ? const Color(0xffD08C4A)
                  : Colors.white.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: active
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 9,
                color: active ? const Color(0xffD08C4A) : Colors.white54)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: active
            ? const Color(0xffD08C4A)
            : Colors.white.withOpacity(0.3),
      ),
    );
  }
}