import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/select_role_model.dart';
import 'package:online_perfume_app_fyp/services/select_role_service.dart';
import 'package:online_perfume_app_fyp/views/seller/seller_homescreen.dart';
import 'package:online_perfume_app_fyp/views/buyer/buyer_homescreen.dart';
import 'package:online_perfume_app_fyp/views/rider/rider_homescreen.dart';
import 'package:online_perfume_app_fyp/services/admin_service.dart';
import 'package:online_perfume_app_fyp/models/admin_models.dart';

import 'admin/screens/admin_homescreen.dart';



class SelectRole extends StatefulWidget {
  const SelectRole({super.key});

  @override
  State<SelectRole> createState() => _SelectRoleState();
}

class _SelectRoleState extends State<SelectRole> {
  String? _selectedRole;
  bool _isLoading = false;

  // Roles are now loaded from the service
  final List<RoleModel> _roles = SelectRoleServices.getRoles();

  Future<void> _onGetStarted() async {
    if (_selectedRole == null) return;

    if (_selectedRole == 'seller') {
      _handleSellerLogin();
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
          targetScreen = const RiderHomescreen();
          break;
        case 'admin':
          targetScreen = const AdminHomeScreen();
          break;
        default:
          targetScreen = const BuyerHomescreen(); // Default fallback
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

  void _handleSellerLogin() {
    final sellers = AdminService.instance.sellers;
    final primaryColor = const Color(0xff5E1D04);
    final accentColor = const Color(0xffD08C4A);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Select Seller Profile",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sellers.length + 1,
              itemBuilder: (context, index) {
                if (index == sellers.length) {
                  return ListTile(
                    leading: Icon(Icons.add_business_rounded, color: accentColor),
                    title: Text(
                      "Register as New Seller",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showRegisterSellerDialog();
                    },
                  );
                }

                final seller = sellers[index];
                final isVerified = seller.status == "Verified";

                return ListTile(
                  leading: Icon(
                    Icons.storefront_rounded,
                    color: seller.isBlocked ? Colors.grey : (isVerified ? Colors.green : Colors.orange),
                  ),
                  title: Text(
                    seller.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: seller.isBlocked ? Colors.grey : primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    "Status: ${seller.isBlocked ? 'Blocked' : seller.status}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: seller.isBlocked ? Colors.red : (isVerified ? Colors.green[800] : Colors.orange[800]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (seller.isBlocked) {
                      _showVerificationErrorDialog(
                        "Access Denied",
                        "Your seller profile '${seller.name}' has been blocked by the Administrator.",
                      );
                    } else if (!isVerified) {
                      _showVerificationErrorDialog(
                        "Verification Pending",
                        "Your seller profile '${seller.name}' is currently under review by the Administrator. Once verified, you will be granted access to the Seller Panel.",
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SellerHomescreen()),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterSellerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final primaryColor = const Color(0xff5E1D04);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Seller Registration",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Brand/Seller Name"),
                  validator: (val) => val == null || val.trim().isEmpty ? "Brand name is required" : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Email is required";
                    if (!val.contains("@")) return "Enter a valid email";
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  AdminService.instance.addSeller(
                    nameController.text.trim(),
                    emailController.text.trim(),
                  );
                  Navigator.pop(context);
                  _showVerificationErrorDialog(
                    "Registration Pending",
                    "Thank you for registering '${nameController.text.trim()}'! Your seller profile is created with 'Pending' verification. An administrator will review your application soon.",
                  );
                }
              },
              child: const Text("Register", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationErrorDialog(String title, String message) {
    final primaryColor = const Color(0xff5E1D04);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 28),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey[800], height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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

              // ── Subtitle
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

              // ── Role Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _roles.map((role) => _buildRoleCard(role)).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Get Started button
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
            // ── Image or Icon
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

            // ── Title
            Text(
              role.title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xff5E1D04),
              ),
            ),

            // ── Subtitle
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
