class UserProfileModel {
  final String name;
  final String profileImage;
  final int orderCount;
  final int reviewCount;
  final int wishlistCount;

  UserProfileModel({
    required this.name,
    required this.profileImage,
    required this.orderCount,
    required this.reviewCount,
    required this.wishlistCount,
  });
}
