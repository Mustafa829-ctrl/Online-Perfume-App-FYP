import 'package:flutter/material.dart';
import 'package:online_perfume_app_fyp/models/select_role_model.dart';

/// Service responsible for providing role data and handling role selection logic.
/// When backend is ready, replace the stub methods with real API calls.
class SelectRoleServices {
  // ── Role data
  /// Returns the list of all selectable roles.
  static List<RoleModel> getRoles() {
    return const [
      RoleModel(
        id: 'buyer',
        title: 'Buyer',
        subtitle: 'Shop Perfume',
        icon: Icons.shopping_bag,
        assetImage: 'assets/images/ads2.png',
        useAsset: true,
      ),
      RoleModel(
        id: 'seller',
        title: 'Seller',
        subtitle: 'Sell Product',
        icon: Icons.storefront_rounded,
        assetImage: 'assets/images/seller.png',
        useAsset: true,
      ),
      RoleModel(
        id: 'rider',
        title: 'A Rider',
        subtitle: 'Deliver Order',
        icon: Icons.delivery_dining_rounded,
        assetImage: 'assets/images/rider.jpg',
        useAsset: false,
      ),
      RoleModel(
        id: 'admin',
        title: 'Admin',
        subtitle: 'Manage System',
        icon: Icons.admin_panel_settings_rounded,
        useAsset: false,
      ),
    ];
  }

  // ── Role selection
  /// Saves the selected role.
  /// TODO: Replace with a real API call or SharedPreferences when backend is ready.
  /// e.g. POST /api/users/role  { "role": roleId }
  static Future<bool> selectRole(String roleId) async {
    try {
      // Stub: simulate a network call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Implement real backend call, e.g.:
      // final response = await http.post(
      //   Uri.parse('https://your-api.com/api/users/role'),
      //   body: jsonEncode({'role': roleId}),
      //   headers: {'Content-Type': 'application/json'},
      // );
      // return response.statusCode == 200;

      return true; // Returns true on success
    } catch (e) {
      return false; // Returns false on failure
    }
  }

  // ── Helpers
  /// Returns the display name for a given role ID.
  static String getRoleDisplayName(String roleId) {
    final role = getRoles().firstWhere(
      (r) => r.id == roleId,
      orElse: () => getRoles().first,
    );
    return role.title;
  }
}
