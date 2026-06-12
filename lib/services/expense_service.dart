import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';

  /// Add Expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      DocumentReference ref = _firestore.collection(_collection).doc();
      await ref.set(expense.toJson(ref.id));
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Expenses by Seller
  Future<List<ExpenseModel>> getSellerExpenses(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) =>
              ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Total Expenses by Seller
  Future<double> getTotalExpenses(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return snap.docs.fold<double>(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + ((data['amount'] as num?)?.toDouble() ?? 0.0);
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Expenses by Date Range
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required String sellerId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) =>
              ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Total Expenses by Date Range
  Future<double> getTotalExpensesByDateRange({
    required String sellerId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();
      return snap.docs.fold<double>(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + ((data['amount'] as num?)?.toDouble() ?? 0.0);
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Expense
  Future<void> updateExpense({
    required String docId,
    required String title,
    required String category,
    required double amount,
    required String note,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'title': title,
        'category': category,
        'amount': amount,
        'note': note,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Delete Expense
  Future<void> deleteExpense(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).delete();
    } catch (e) {
      throw e.toString();
    }
  }
}
