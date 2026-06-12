import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/select_role_model.dart';
import 'package:online_perfume_app_fyp/services/select_role_service.dart';
import 'package:online_perfume_app_fyp/views/admin/auth/admin_login_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer%20auth/buyer_login_screen.dart';
import 'package:online_perfume_app_fyp/views/buyer/screens/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/rider/auth/rider_login_screen.dart';
import 'package:online_perfume_app_fyp/views/rider/rider_homescreen.dart';
import 'package:online_perfume_app_fyp/views/seller/seller%20auth/seller_login_screen.dart';
import 'package:online_perfume_app_fyp/views/seller/seller_homescreen.dart';
import 'admin/screens/admin_homescreen.dart';

class SelectRole extends StatefulWidget {
  const SelectRole({super.key});

  @override
  State<SelectRole> createState() => _SelectRoleState();
}

class _SelectRoleState extends State<SelectRole> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<RoleModel> _roles = SelectRoleServices.getRoles();

  Future<void> _onGetStarted() async {
    if (_selectedRole == null) return;


    if (_selectedRole == 'seller') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SellerLoginScreen(),
        ),
      );
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
        case 'admin':
          targetScreen = const AdminLoginScreen();
          break;
        default:
          targetScreen = const BuyerHomescreen();
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✅ Kept for future use — shown after auth when seller is blocked/unverified
  void _showVerificationErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange[800], size: 28),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.grey[800], height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5E1D04)),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xff5E1D04)),
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.menu_outlined, color: Color(0xff5E1D04)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Select  how you want use\nthe App',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff5E1D04),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Role Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      _roles.map((role) => _buildRoleCard(role)).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selectedRole == null || _isLoading)
                      ? null
                      : _onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8860A),
                    disabledBackgroundColor:
                        const Color(0xFFC8860A).withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFFC8860A).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
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
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFFF6AF52).withOpacity(isSelected ? 1.0 : 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xff5E1D04) : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: role.useAsset
                  ? Image.asset(
                      role.assetImage!,
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        role.icon,
                        size: 48,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              role.title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xff5E1D04),
              ),
            ),
            Text(
              role.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xff5E1D04),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
