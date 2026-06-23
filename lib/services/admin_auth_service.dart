import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/admin_model.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login Admin
  Future<AdminModel> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. RBAC — check if user exists in admins/ collection only
      DocumentSnapshot doc = await _firestore
          .collection('admin')
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        // Not an admin — kick out immediately
        await _auth.signOut();
        throw 'No admin account found. Unauthorized access.';
      }

      // 3. Parse admin data
      AdminModel admin =
          AdminModel.fromJson(doc.data() as Map<String, dynamic>);

      // 4. Check role
      if (admin.role != 'admin') {
        await _auth.signOut();
        throw 'Unauthorized access. Invalid role.';
      }

      // 5. Check if blocked
      if (admin.isBlocked == true) {
        await _auth.signOut();
        throw 'Your admin account has been blocked.';
      }

      return admin;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Logout Admin
  Future<void> logoutAdmin() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Reset Password
  /// Sends password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Change Password
  /// Re-authenticates before changing password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No admin logged in.';

      // Re-authenticate before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Current Admin Data
  Future<AdminModel> getCurrentAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No admin logged in.';

      DocumentSnapshot doc = await _firestore
          .collection('admin')
          .doc(user.uid)
          .get();

      if (!doc.exists) throw 'Admin data not found.';

      return AdminModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Admin Profile
  Future<void> updateAdminProfile({
    required String name,
    required String phone,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No admin logged in.';

      await _firestore.collection('admin').doc(user.uid).update({
        'name': name,
        'phone': phone,
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
