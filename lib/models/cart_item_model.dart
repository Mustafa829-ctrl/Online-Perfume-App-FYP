class CartItemModel {
  final String? cartItemId;
  final String? productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;
  final String? sellerId;
  final int? addedAt;
  final String? buyerId;

  CartItemModel({
    this.cartItemId,
    this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.sellerId,
    this.addedAt,
    this.buyerId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    cartItemId: json["cartItemId"],
    productId: json["productId"],
    productName: json["productName"] ?? '',
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    imageUrl: json["imageUrl"] ?? '',
    quantity: json["quantity"] ?? 1,
    sellerId: json["sellerId"],
    addedAt: json["addedAt"],
    buyerId: json['buyerId'],
  );

  Map<String, dynamic> toJson() => {
    "cartItemId": cartItemId,
    "productId": productId,
    "productName": productName,
    "price": price,
    "imageUrl": imageUrl,
    "quantity": quantity,
    "sellerId": sellerId,
    "addedAt": addedAt,
    'buyerId': buyerId,
  };

  double get totalPrice => price * quantity;
}