import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SALES ANALYTICS----

  /// Get Daily Sales for Seller
  Future<double> getDailySales(String sellerId) async {
    try {
      final now = DateTime.now();
      final startOfDay =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'Delivered')
          .where('deliveredAt', isGreaterThanOrEqualTo: startOfDay)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Weekly Sales
  Future<double> getWeeklySales(String sellerId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startMillis =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
              .millisecondsSinceEpoch;

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'Delivered')
          .where('deliveredAt', isGreaterThanOrEqualTo: startMillis)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Monthly Sales
  Future<double> getMonthlySales(String sellerId) async {
    try {
      final now = DateTime.now();
      final startOfMonth =
          DateTime(now.year, now.month, 1).millisecondsSinceEpoch;

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'Delivered')
          .where('deliveredAt', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Top Selling Products
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
      String sellerId, {int limit = 5}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('totalSold', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // PROFIT & LOSS----

  /// Get Profit & Loss Summary
  Future<Map<String, dynamic>> getProfitLossSummary(String sellerId) async {
    try {
      double totalSales = await getMonthlySales(sellerId);
      double totalExpenses = await _getTotalExpenses(sellerId);

      double profit = totalSales - totalExpenses;

      return {
        'totalSales': totalSales,
        'totalExpenses': totalExpenses,
        'profit': profit,
        'profitMargin': totalSales > 0
            ? '${((profit / totalSales) * 100).toStringAsFixed(1)}%'
            : '0%',
        'isProfit': profit >= 0,
      };
    } catch (e) {
      throw e.toString();
    }
  }

  /// Helper: Get Total Expenses
  Future<double> _getTotalExpenses(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('expenses')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get Yearly Profit/Loss
  Future<Map<String, dynamic>> getYearlyProfitLoss(String sellerId) async {
    try {
      final now = DateTime.now();
      final startOfYear =
          DateTime(now.year, 1, 1).millisecondsSinceEpoch;

      QuerySnapshot ordersSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'Delivered')
          .where('deliveredAt', isGreaterThanOrEqualTo: startOfYear)
          .get();

      double totalSales = 0.0;
      for (var doc in ordersSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalSales += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }

      double totalExpenses = await _getTotalExpenses(sellerId);

      return {
        'year': now.year,
        'totalSales': totalSales,
        'totalExpenses': totalExpenses,
        'netProfit': totalSales - totalExpenses,
      };
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Orders from a specific date — used for weekly chart building
  Future<List<Map<String, dynamic>>> getOrdersFromDate(
      String sellerId, int startMillis) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .where('status', isEqualTo: 'Delivered')
          .where('deliveredAt', isGreaterThanOrEqualTo: startMillis)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // ADMIN DASHBOARD ANALYTICS----

  /// Get Total Platform Sales (Admin)
  Future<double> getTotalPlatformSales() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'Delivered')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Total Active Sellers
  Future<int> getTotalActiveSellers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sellers')
          .where('isBlocked', isEqualTo: false)
          .where('status', isEqualTo: 'Approved')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }
}
