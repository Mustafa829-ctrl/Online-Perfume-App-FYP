class WishlistItemModel {
  final String? docId;
  final String? wishlistItemId;
  final String? productId;
  final String? buyerId;
  final String? name;
  final double? price;
  final String? imagePath;
  final String? sellerId;
  final int? addedAt;

  WishlistItemModel({
    this.docId,
    this.wishlistItemId,
    this.productId,
    this.buyerId,
    this.name,
    this.price,
    this.imagePath,
    this.sellerId,
    this.addedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      WishlistItemModel(
        docId:          json['docId'],
        wishlistItemId: json['wishlistItemId'],
        productId:      json['productId'],
        buyerId:        json['buyerId'],
        name:           json['name'],
        price:          (json['price'] as num?)?.toDouble(),
        imagePath:      json['imagePath'],
        sellerId:       json['sellerId'],
        addedAt:        json['addedAt'],
      );

  Map<String, dynamic> toJson(String uid) => {
    'docId':          uid,
    'wishlistItemId': wishlistItemId ?? uid,
    'productId':      productId ?? '',
    'buyerId':        buyerId ?? '',
    'name':           name ?? '',
    'price':          price ?? 0.0,
    'imagePath':      imagePath ?? '',
    'sellerId':       sellerId ?? '',
    'addedAt':        addedAt,
  };
}