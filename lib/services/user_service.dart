import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name
  final String _collection = 'users';

  /// Register User
  /// Creates Firebase Auth account + saves user data in Firestore users/ collection
  Future<User> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // 1. Create Firebase Auth account
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Send email verification
      await userCred.user!.sendEmailVerification();

      // 3. Save user data in Firestore users/ collection
      UserModel user = UserModel(
        docId: userCred.user!.uid,
        userId: userCred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        isBlocked: false,
        role: 'buyer',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection(_collection)
          .doc(userCred.user!.uid)
          .set(user.toJson(userCred.user!.uid));

      return userCred.user!;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Login User
  /// RBAC: checks users/ collection only
  /// Extra check: isBlocked
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. RBAC — check if exists in users/ collection only
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'No buyer account found. Please register first.';
      }

      // 3. Parse user data
      UserModel user =
          UserModel.fromJson(doc.data() as Map<String, dynamic>);

      // 4. Check if blocked
      if (user.isBlocked == true) {
        await _auth.signOut();
        throw 'Your account has been blocked by the Administrator. Reason: ${user.blockedReason ?? 'No reason provided.'}';
      }

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Logout User
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Reset Password
  Future<void> resetPassword({required String email}) async {
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

  /// Get Current User Data
  Future<UserModel> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in.';

      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(user.uid)
          .get();

      if (!doc.exists) throw 'User data not found.';

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update User Profile
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
    String? profileImageUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in.';

      await _firestore.collection(_collection).doc(user.uid).update({
        'name': name,
        'phone': phone,
        'address': address,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // ─────────────────────────────────────────
  // ADMIN OPERATIONS
  // ─────────────────────────────────────────

  /// Get All Users
  /// Admin — fetches all users from Firestore
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get User By ID
  Future<UserModel> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (!doc.exists) throw 'User not found.';

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Block User
  /// Admin blocks a user
  Future<void> blockUser({
    required String userId,
    required String reason,
  }) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'isBlocked': true,
        'blockedReason': reason,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unblock User
  /// Admin unblocks a user
  Future<void> unblockUser({required String userId}) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'isBlocked': false,
        'blockedReason': null,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Total Users Count
  /// Used in admin dashboard stats
  Future<int> getUsersCount() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Blocked Users Count
  /// Used in admin dashboard stats
  Future<int> getBlockedUsersCount() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isBlocked', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search Users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Fetch all then filter locally
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final allUsers = snapshot.docs
          .map((doc) =>
              UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allUsers.where((user) {
        final nameMatch = user.name
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        final emailMatch = user.email
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
            false;
        return nameMatch || emailMatch;
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
