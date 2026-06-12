class ProductModel {
  final String? docId;
  final String? productId;
  final String? sellerId;
  final String? sellerName;
  final String? name;
  final String? description;
  final String? category;
  final String? concentration; // EDP, EDT, EDC, Parfum
  final String? brand;
  final String? fragranceNotes; // e.g. 'Rose, Oud, Musk'
  final List<Map<String, dynamic>>? sizes; // [{size: '50ml', price: 2500, stock: 10}]
  final double? price;
  final int? stock;
  final int? threshold;
  final double? discount;
  final int? totalSold;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;
  final bool? isAvailable;
  final int? createdAt;

  ProductModel({
    this.docId,
    this.productId,
    this.sellerId,
    this.sellerName,
    this.name,
    this.description,
    this.category,
    this.concentration,
    this.brand,
    this.fragranceNotes,
    this.sizes,
    this.price,
    this.stock,
    this.threshold,
    this.discount,
    this.totalSold,
    this.rating,
    this.reviewCount,
    this.imageUrl,
    this.isAvailable,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        docId: json["docId"],
        productId: json["productId"],
        sellerId: json["sellerId"],
        sellerName: json["sellerName"],
        name: json["name"],
        description: json["description"],
        category: json["category"],
        concentration: json["concentration"],
        brand: json["brand"],
        fragranceNotes: json["fragranceNotes"],
        sizes: json["sizes"] != null
            ? List<Map<String, dynamic>>.from(
                (json["sizes"] as List).map((s) => Map<String, dynamic>.from(s)))
            : null,
        price: (json["price"] as num?)?.toDouble(),
        stock: json["stock"],
        threshold: json["threshold"],
        discount: (json["discount"] as num?)?.toDouble(),
        totalSold: json["totalSold"],
        rating: (json["rating"] as num?)?.toDouble(),
        reviewCount: json["reviewCount"],
        imageUrl: json["imageUrl"],
        isAvailable: json["isAvailable"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson(String uid) => {
        "docId": uid,
        "productId": uid,
        "sellerId": sellerId ?? "",
        "sellerName": sellerName ?? "",
        "name": name ?? "",
        "description": description ?? "",
        "category": category ?? "",
        "concentration": concentration ?? "",
        "brand": brand ?? "",
        "fragranceNotes": fragranceNotes ?? "",
        "sizes": sizes ?? [],
        "price": price ?? 0.0,
        "stock": stock ?? 0,
        "threshold": threshold ?? 5,
        "discount": discount ?? 0.0,
        "totalSold": totalSold ?? 0,
        "rating": rating ?? 0.0,
        "reviewCount": reviewCount ?? 0,
        "imageUrl": imageUrl ?? "",
        "isAvailable": isAvailable ?? true,
        "createdAt": createdAt,
      };

  // ── Helper: calculate discounted price
  double get discountedPrice {
    if (discount == null || discount == 0) return price ?? 0.0;
    return (price ?? 0.0) * (1 - (discount! / 100));
  }

  // ── Helper: check if low stock
  bool get isLowStock {
    final currentStock = stock ?? 0;
    final alertLevel = threshold ?? 5;
    return currentStock <= alertLevel;
  }

  // ── Helper: get price for specific size
  double? getPriceForSize(String size) {
    if (sizes == null) return price;
    final sizeData = sizes!.firstWhere(
      (s) => s['size'] == size,
      orElse: () => {},
    );
    return sizeData.isEmpty ? price : (sizeData['price'] as num?)?.toDouble();
  }

  // ── Helper: get stock for specific size
  int? getStockForSize(String size) {
    if (sizes == null) return stock;
    final sizeData = sizes!.firstWhere(
      (s) => s['size'] == size,
      orElse: () => {},
    );
    return sizeData.isEmpty ? stock : sizeData['stock'] as int?;
  }
}
