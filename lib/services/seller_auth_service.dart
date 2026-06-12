import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';

class SellerAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<User> registerSeller({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String cnic,
    required String businessName,
    required String businessAddress,
    required String businessType,
  }) async {
    try {
      // 1. Create Firebase Auth account
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Send email verification
      await userCred.user!.sendEmailVerification();

      // 3. Save seller data in Firestore sellers/ collection
      SellerModel seller = SellerModel(
        docId: userCred.user!.uid,
        sellerId: userCred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        cnic: cnic,
        businessName: businessName,
        businessAddress: businessAddress,
        businessType: businessType,
        isVerified: false,
        isBlocked: false,
        role: 'seller',
        status: 'Pending', // ← admin must verify
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection('sellers')
          .doc(userCred.user!.uid)
          .set(seller.toJson(userCred.user!.uid));

      return userCred.user!;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Login Seller

  Future<SellerModel> loginSeller({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. RBAC — check if user exists in sellers/ collection
      DocumentSnapshot doc = await _firestore
          .collection('sellers')
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        // Not a seller — kick out immediately
        await _auth.signOut();
        throw 'No seller account found. Please register as a seller first.';
      }

      // 3. Parse seller data
      SellerModel seller =
          SellerModel.fromJson(doc.data() as Map<String, dynamic>);

      // 4. Check if blocked
      if (seller.isBlocked == true) {
        await _auth.signOut();
        throw 'Your seller account has been blocked by the Administrator. Reason: ${seller.blockedReason ?? 'No reason provided.'}';
      }

      // 5. Check if verified by admin
      if (seller.status == 'Pending') {
        await _auth.signOut();
        throw 'Your seller account is pending verification. Please wait for admin approval.';
      }

      return seller;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Logout Seller
  Future<void> logoutSeller() async {
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
  /// Requires current password for re-authentication before changing
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in.';

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

  /// Get Current Seller Data
  /// Fetches seller data from Firestore sellers/ collection
  Future<SellerModel> getCurrentSeller() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in.';

      DocumentSnapshot doc = await _firestore
          .collection('sellers')
          .doc(user.uid)
          .get();

      if (!doc.exists) throw 'Seller data not found.';

      return SellerModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Seller Profile
  /// Updates seller data in Firestore sellers/ collection
  Future<void> updateSellerProfile({
    required String name,
    required String phone,
    required String address,
    required String businessName,
    required String businessAddress,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in.';

      await _firestore.collection('sellers').doc(user.uid).update({
        'name': name,
        'phone': phone,
        'address': address,
        'businessName': businessName,
        'businessAddress': businessAddress,
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
