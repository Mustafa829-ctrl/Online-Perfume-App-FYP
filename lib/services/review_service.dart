import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/review_model.dart'; // Agar alag ReviewModel bana hai to import kar lenge

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _reviewsCollection = 'reviews';
  final String _productsCollection = 'products';

  // ADD REVIEW (Buyer Side)----

  /// Add Product Review
  Future<void> addReview({
    required String reviewId,
    required String productId,
    required String buyerId,
    required String buyerName,
    required double rating, // 1 to 5
    required String comment,
    required String sellerId,
  }) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).set({
        'reviewId': reviewId,
        'productId': productId,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'rating': rating,
        'comment': comment,
        'sellerId': sellerId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'Approved', // Default approved (Admin can moderate later)
      });

      // Update Product Average Rating
      await _updateProductRating(productId);
    } catch (e) {
      throw e.toString();
    }
  }

  // GET REVIEWS-------

  /// Get All Reviews of a Product
  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId)
          .where('status', isEqualTo: 'Approved')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Reviews by Seller (Seller Panel)
  Future<List<Map<String, dynamic>>> getSellerReviews(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get All Reviews (Admin)
  Future<List<Map<String, dynamic>>> getAllReviews() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_reviewsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // REPLY TO REVIEW (Seller Side)-------

  /// Seller Reply to Customer Review
  Future<void> replyToReview({
    required String reviewId,
    required String sellerReply,
  }) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).update({
        'sellerReply': sellerReply,
        'repliedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // HELPER METHODS-----

  /// Update Product Average Rating
  Future<void> _updateProductRating(String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId)
          .where('status', isEqualTo: 'Approved')
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] as num).toDouble();
      }

      double averageRating = totalRating / snapshot.docs.length;

      await _firestore.collection(_productsCollection).doc(productId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'reviewCount': snapshot.docs.length,
      });
    } catch (e) {
      print("Error updating product rating: $e");
    }
  }

  /// Delete Review (Admin)
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get Average Rating of Product
  Future<double> getAverageRating(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['rating'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      throw e.toString();
    }
  }
  /// Get All Reviews of a Product as ReviewModel list
  Future<List<ReviewModel>> getProductReviewModels(String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId)
          .where('status', isEqualTo: 'Approved')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}