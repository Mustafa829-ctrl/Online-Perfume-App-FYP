class ReviewModel {
  final String? docId;
  final String? reviewId;
  final String? productId;
  final String? buyerId;
  final String? buyerName;
  final double? rating;
  final String? comment;
  final String? sellerId;
  final String? sellerReply;
  final int? repliedAt;
  final int? createdAt;
  final String? status;

  ReviewModel({
    this.docId,
    this.reviewId,
    this.productId,
    this.buyerId,
    this.buyerName,
    this.rating,
    this.comment,
    this.sellerId,
    this.sellerReply,
    this.repliedAt,
    this.createdAt,
    this.status,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    docId:       json["docId"],
    reviewId:    json["reviewId"],
    productId:   json["productId"],
    buyerId:     json["buyerId"],
    buyerName:   json["buyerName"],
    rating:      (json["rating"] as num?)?.toDouble(),
    comment:     json["comment"],
    sellerId:    json["sellerId"],
    sellerReply: json["sellerReply"],
    repliedAt:   json["repliedAt"],
    createdAt:   json["createdAt"],
    status:      json["status"],
  );

  Map<String, dynamic> toJson(String uid) => {
    "docId":       uid,
    "reviewId":    reviewId ?? uid,
    "productId":   productId ?? "",
    "buyerId":     buyerId ?? "",
    "buyerName":   buyerName ?? "",
    "rating":      rating ?? 0.0,
    "comment":     comment ?? "",
    "sellerId":    sellerId ?? "",
    "sellerReply": sellerReply ?? "",
    "repliedAt":   repliedAt,
    "createdAt":   createdAt,
    "status":      status ?? "Approved",
  };
}