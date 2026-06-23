
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyerAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the role of the current user, or null if not logged in / doc not found.
  Future<String?> getCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Checks if the current user is a valid buyer.
  Future<bool> isValidBuyer() async {
    final role = await getCurrentUserRole();
    return role == 'buyer';
  }
}