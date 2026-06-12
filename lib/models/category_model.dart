class CategoryModel {
  final String docId;
  final String categoryName;
  final String description;
  final String? imageUrl;
  final int createdAt;

  CategoryModel({
    required this.docId,
    required this.categoryName,
    this.description = "",
    this.imageUrl = "",
    required this.createdAt,
  });

  /// Convert Firestore Document snapshot map to a CategoryModel object
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      docId: map['docId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] ?? 0,
    );
  }

  /// Convert CategoryModel instance back to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'categoryName': categoryName,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}