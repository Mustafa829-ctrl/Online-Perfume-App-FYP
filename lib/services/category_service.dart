import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  /// 1. Create - Add a new Category to Firestore
  Future<void> createCategory(CategoryModel category) async {
    try {
      // Standardize formatting: trim trailing spaces and capitalize first letter
      final trimmedName = category.categoryName.trim();
      if (trimmedName.isEmpty) throw "Category name cannot be empty";
      final formattedName = trimmedName[0].toUpperCase() + trimmedName.substring(1).toLowerCase();

      // Check for duplicates in your database collection
      QuerySnapshot duplicateCheck = await _firestore
          .collection(_collection)
          .where('categoryName', isEqualTo: formattedName)
          .get();

      if (duplicateCheck.docs.isNotEmpty) {
        throw "A category named '$formattedName' already exists.";
      }

      // Generate a document reference automatically if docId wasn't manually passed
      DocumentReference docRef;
      if (category.docId.isEmpty) {
        docRef = _firestore.collection(_collection).doc();
      } else {
        docRef = _firestore.collection(_collection).doc(category.docId);
      }

      // Rebuild the model configuration with clean values and assigned doc references
      final finalCategory = CategoryModel(
        docId: docRef.id,
        categoryName: formattedName,
        description: category.description.trim(),
        imageUrl: category.imageUrl,
        createdAt: category.createdAt,
      );

      // Upload payload data to Firebase Firestore
      await docRef.set(finalCategory.toMap());
    } catch (e) {
      throw e.toString();
    }
  }

  /// 2. Read - Fetch all active categories from Firestore ordered alphabetically
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      QuerySnapshot snap = await _firestore
          .collection(_collection)
          .orderBy('categoryName', descending: false)
          .get();

      return snap.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// 3. Update - Modify an existing category profile
  Future<void> updateCategory(CategoryModel category) async {
    try {
      if (category.docId.isEmpty) throw "Cannot update category without a valid document ID";

      await _firestore
          .collection(_collection)
          .doc(category.docId)
          .update(category.toMap());
    } catch (e) {
      throw e.toString();
    }
  }

  /// 4. Delete - Remove a category by its Document ID reference
  Future<void> deleteCategory(String docId) async {
    try {
      if (docId.isEmpty) throw "Invalid category document reference";
      await _firestore.collection(_collection).doc(docId).delete();
    } catch (e) {
      throw e.toString();
    }
  }
}