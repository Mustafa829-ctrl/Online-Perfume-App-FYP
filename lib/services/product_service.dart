import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // SELLER OPERATIONS

  /// Add Product
  Future<void> addProduct(ProductModel product) async {
    try {
      DocumentReference ref = _firestore.collection(_collection).doc();
      await ref.set(product.toJson(ref.id));
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Products by Seller
  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Product
  Future<void> updateProduct(String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(docId).update(data);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Delete Product
  Future<void> deleteProduct(String docId) async {
    try {
      await _firestore.collection(_collection).doc(docId).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Stock for specific size
  Future<void> updateSizeStock({
    required String docId,
    required List<Map<String, dynamic>> updatedSizes,
    required int totalStock,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'sizes': updatedSizes,
        'stock': totalStock,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Threshold
  Future<void> updateThreshold({
    required String docId,
    required int threshold,
  }) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(docId)
          .update({'threshold': threshold});
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Low Stock Products (stock <= threshold)
  Future<List<ProductModel>> getLowStockProducts(String sellerId) async {
    try {
      // Fetch all seller products then filter locally
      // (Firestore can't compare two fields directly)
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final all = snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return all.where((p) => p.isLowStock).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Top Selling Products by Seller
  Future<List<ProductModel>> getTopSellingProducts(String sellerId,
      {int limit = 5}) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('totalSold', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Increment Total Sold + Decrement Stock after order placed
  Future<void> incrementTotalSold({
    required String docId,
    required int quantity,
    String? size,
    required List<Map<String, dynamic>> currentSizes,
  }) async {
    try {
      // Update sizes stock if size provided
      if (size != null && currentSizes.isNotEmpty) {
        final updatedSizes = currentSizes.map((s) {
          if (s['size'] == size) {
            return {
              ...s,
              'stock': ((s['stock'] as int?) ?? 0) - quantity,
            };
          }
          return s;
        }).toList();

        // Recalculate total stock
        final totalStock = updatedSizes.fold<int>(
            0, (sum, s) => sum + ((s['stock'] as int?) ?? 0));

        await _firestore.collection(_collection).doc(docId).update({
          'sizes': updatedSizes,
          'stock': totalStock,
          'totalSold': FieldValue.increment(quantity),
        });
      } else {
        await _firestore.collection(_collection).doc(docId).update({
          'stock': FieldValue.increment(-quantity),
          'totalSold': FieldValue.increment(quantity),
        });
      }
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Products Count for seller
  Future<int> getProductsCount(String sellerId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return snap.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  // BUYER OPERATIONS

  /// Get All Available Products (for buyers)
  Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Products by Category (for buyers)
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Search Products by name, brand or category
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();

      final all = snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return all.where((p) {
        final q = query.toLowerCase();
        return (p.name?.toLowerCase().contains(q) ?? false) ||
            (p.brand?.toLowerCase().contains(q) ?? false) ||
            (p.category?.toLowerCase().contains(q) ?? false) ||
            (p.fragranceNotes?.toLowerCase().contains(q) ?? false);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Product by ID
  Future<ProductModel> getProductById(String docId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collection).doc(docId).get();
      if (!doc.exists) throw 'Product not found.';
      return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update Product Rating after review
  Future<void> updateProductRating({
    required String docId,
    required double newRating,
    required int totalReviews,
  }) async {
    try {
      await _firestore.collection(_collection).doc(docId).update({
        'rating': newRating,
        'reviewCount': totalReviews,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Discounted Products
  Future<List<ProductModel>> getDiscountedProducts() async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .where('discount', isGreaterThan: 0)
          .orderBy('discount', descending: true)
          .get();
      return snap.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
