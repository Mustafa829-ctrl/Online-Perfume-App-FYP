import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rider_model.dart';

class RiderAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register Rider
  Future<User> registerRider({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String cnic,
    required String licenseNumber,
    required String vehicleModel,
    required String vehicleNumber,
  }) async {
    try {
      // Step 1 — Create Firebase Auth user
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Step 2 — Generate rider ID
      String riderId =
          'RDR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Step 3 — Build rider model
      RiderModel rider = RiderModel(
        riderId: riderId,
        name: name,
        email: email,
        phone: phone,
        address: address,
        cnic: cnic,
        licenseNumber: licenseNumber,
        vehicleModel: vehicleModel,
        vehicleNumber: vehicleNumber,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Step 4 — Save to Firestore riders/ collection
      await _firestore
          .collection('riders')
          .doc(userCred.user!.uid)
          .set(rider.toJson(userCred.user!.uid));

      return userCred.user!;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Login Rider
  Future<RiderModel> loginRider({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1 — Firebase Auth sign in
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      String uid = userCred.user!.uid;

      // Step 2 — Check if this user exists in riders/ collection
      // (RBAC: seller/buyer cannot login here)
      DocumentSnapshot doc =
          await _firestore.collection('riders').doc(uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'Access denied. No rider account found.';
      }

      RiderModel rider =
          RiderModel.fromJson(doc.data() as Map<String, dynamic>);

      // Step 3 — Check if blocked
      if (rider.isBlocked == true) {
        await _auth.signOut();
        throw 'Your account is blocked. Reason: ${rider.blockedReason ?? 'Contact admin'}';
      }

      return rider;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Logout Rider
  Future<void> logoutRider() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Forgot Password
  Future<void> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User user = _auth.currentUser!;

      // Re-authenticate first
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      // Then update
      await user.updatePassword(newPassword);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get current rider profile
  Future<RiderModel> getRiderProfile() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc =
          await _firestore.collection('riders').doc(uid).get();
      return RiderModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update rider profile
  Future<void> updateRiderProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('riders').doc(uid).update(data);
    } catch (e) {
      throw e.toString();
    }
  }
}
