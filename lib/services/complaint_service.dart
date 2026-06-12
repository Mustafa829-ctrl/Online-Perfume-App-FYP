import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name
  final String _collection = 'complaints';

  /// Get All Complaints
  /// Admin — fetches all complaints from Firestore
  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
          ComplaintModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Complaints by Status
  /// Filter complaints by status — 'Pending', 'In Progress', 'Resolved', 'Dismissed'
  Future<List<ComplaintModel>> getComplaintsByStatus(String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
          ComplaintModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Complaints by Buyer
  Future<List<ComplaintModel>> getComplaintsByBuyer(String buyerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
          ComplaintModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Complaints by Seller
  Future<List<ComplaintModel>> getComplaintsBySeller(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
          ComplaintModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Add Complaint
  /// Buyer submits a complaint
  Future<void> addComplaint(ComplaintModel complaint) async {
    try {
      // Auto generate doc id
      DocumentReference ref = _firestore.collection(_collection).doc();
      await ref.set(complaint.toJson(ref.id));
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Complaint Status
  /// Admin updates complaint status
  Future<void> updateComplaintStatus({
    required String docId,
    required String status,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': status,
        if (status == 'Resolved')
          'resolvedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Reply to Complaint
  /// Admin replies to a complaint
  Future<void> replyToComplaint({
    required String docId,
    required String reply,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'adminReply': reply,
        'status': 'In Progress',
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Resolve Complaint
  /// Admin resolves a complaint with reply
  Future<void> resolveComplaint({
    required String docId,
    required String reply,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'adminReply': reply,
        'status': 'Resolved',
        'resolvedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Dismiss Complaint
  Future<void> dismissComplaint({required String docId}) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'status': 'Dismissed',
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Pending Complaints Count
  /// Used in admin dashboard stats
  Future<int> getPendingComplaintsCount() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'Pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search Complaints by buyer name or product
  Future<List<ComplaintModel>> searchComplaints(String query) async {
    try {
      // Fetch all then filter — Firestore doesn't support full text search
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final allComplaints = snapshot.docs
          .map((doc) =>
          ComplaintModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by buyer name or product name
      return allComplaints.where((complaint) {
        final buyerMatch = complaint.buyerName
            ?.toLowerCase()
            .contains(query.toLowerCase()) ??
            false;
        final productMatch = complaint.productName
            ?.toLowerCase()
            .contains(query.toLowerCase()) ??
            false;
        return buyerMatch || productMatch;
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}