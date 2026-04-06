class WishlistItemModel {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final bool isLiked;

  WishlistItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.isLiked = true,
  });
}
