import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/rider_model.dart';

class RiderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'riders';

  get _auth => null;

  /// Fetch all riders assigned to this specific seller
  Future<List<RiderModel>> getSellerRiders(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .get();

      return snap.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Ensure the firestore document ID is injected into the data map
        data['docId'] = doc.id;
        return RiderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Block a rider with a reason and duration
  Future<void> blockRider({
    required String docId,
    required String reason,
    required String duration,
    required String sellerId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'isBlocked': true,
        'status': 'blocked',
        'blockedReason': reason,
        'blockDuration': duration,
        'blockedAt': FieldValue.serverTimestamp(),
        'blockedBy': sellerId,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Unblock a rider and restore their status to active
  Future<void> unblockRider(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'isBlocked': false,
        'status': 'active',
        'blockedReason': null,
        'blockDuration': null,
        'unblockedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Seller creates a new Rider account

  Future<Map<String, dynamic>> createRiderBySeller({
    required String sellerId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String cnic,
    required String password,
    required String vehicleModel,
    required String vehicleNumber,
    required String licenseNumber,
  }) async {
    // Create secondary Firebase app
    // so seller session is NOT disturbed
    FirebaseApp? secondaryApp;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      //  Use secondary app auth
      FirebaseAuth secondaryAuth =
      FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential cred = await secondaryAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;

      // Generate rider ID
      String riderId =
          'RDR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Save to Firestore
      RiderModel rider = RiderModel(
        docId: uid,
        riderId: riderId,
        sellerId: sellerId,
        name: name,
        email: email,
        phone: phone,
        address: address,
        cnic: cnic,
        vehicleModel: vehicleModel,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
        isBlocked: false,
        role: 'rider',
        status: 'active',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection('riders')
          .doc(uid)
          .set(rider.toJson(uid));

      //  Sign out from secondary app
      await secondaryAuth.signOut();

      return {
        'success': true,
        'email': email,
        'password': password,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      // Always delete secondary app to free memory
      await secondaryApp?.delete();
    }
  }
  }