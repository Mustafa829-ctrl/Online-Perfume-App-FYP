class CartItemModel {
  final String productName;
  final double price;
  final String imagePath;
  final String selectedVolume;
  int quantity;

  CartItemModel({
    required this.productName,
    required this.price,
    required this.imagePath,
    required this.selectedVolume,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}
