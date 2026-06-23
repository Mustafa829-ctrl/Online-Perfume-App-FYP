import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/select_role_model.dart';
import 'package:online_perfume_app_fyp/services/select_role_service.dart';
import 'package:online_perfume_app_fyp/views/admin/auth/admin_login_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/rider/auth/rider_login_screen.dart';
import 'package:online_perfume_app_fyp/views/rider/rider_homescreen.dart';
import 'package:online_perfume_app_fyp/views/seller/seller%20auth/seller_login_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/seller_homescreen.dart';

class SelectRole extends StatefulWidget {
  const SelectRole({super.key});

  @override
  State<SelectRole> createState() => _SelectRoleState();
}

class _SelectRoleState extends State<SelectRole> {
  String? _selectedRole;
  bool _isLoading = false;
  int _adminTapCount = 0;

  final List<RoleModel> _roles = SelectRoleServices.getRoles();

  // Silent Secret Admin Access
  void _handleSecretAdminTap() {
    setState(() {
      _adminTapCount++;
    });

    if (_adminTapCount >= 4) {
      setState(() => _adminTapCount = 0);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    }
  }

  Future<void> _onGetStarted() async {
    if (_selectedRole == null) return;

    if (_selectedRole == 'seller') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerLoginScreen()));
      return;
    }

    setState(() => _isLoading = true);

    final success = await SelectRoleServices.selectRole(_selectedRole!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Widget targetScreen;
      switch (_selectedRole) {
        case 'buyer':
          targetScreen = const BuyerHomescreen();
          break;
        case 'rider':
          targetScreen = const RiderLoginScreen();
          break;
        default:
          targetScreen = const BuyerHomescreen();
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff5E1D04)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose Your Role',
          style: GoogleFonts.poppins(
            color: const Color(0xff5E1D04),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          // Hidden Admin Access Icon
          GestureDetector(
            onTap: _handleSecretAdminTap,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.admin_panel_settings_outlined,
                  color: Color(0xff5E1D04), size: 28),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Text(
                'Select how you want to use\nthe App',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff5E1D04),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _roles
                      .where((role) => role.id != 'admin')
                      .map((role) => _buildRoleCard(role))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selectedRole == null || _isLoading) ? null : _onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8860A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Get Started', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(RoleModel role) {
    final bool isSelected = _selectedRole == role.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFFF6AF52).withOpacity(isSelected ? 1.0 : 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xff5E1D04) : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                role.icon ?? Icons.person,
                size: 48,
                color: const Color(0xff5E1D04),
              ),
            ),
            const SizedBox(height: 12),
            Text(role.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xff5E1D04))),
            Text(role.subtitle, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xff5E1D04))),
          ],
        ),
      ),
    );
  }
}