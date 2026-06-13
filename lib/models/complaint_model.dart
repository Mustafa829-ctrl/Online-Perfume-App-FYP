class ComplaintModel {
  final String? docId;
  final String? complaintId;
  final String? buyerId;
  final String? buyerName;
  final String? buyerEmail;
  final String? buyerPhone;
  final String? sellerId;
  final String? sellerName;
  final String? orderId;
  final String? productName;
  final String? issue;
  final String? status; // 'Pending', 'In Progress', 'Resolved', 'Dismissed'
  final String? adminReply;
  final int? createdAt;
  final int? resolvedAt;
  final String? imageUrl;

  ComplaintModel({
    this.docId,
    this.complaintId,
    this.buyerId,
    this.buyerName,
    this.buyerEmail,
    this.buyerPhone,
    this.sellerId,
    this.sellerName,
    this.orderId,
    this.productName,
    this.issue,
    this.status,
    this.adminReply,
    this.createdAt,
    this.resolvedAt,
    this.imageUrl = "",
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
        docId: json["docId"],
        complaintId: json["complaintId"],
        buyerId: json["buyerId"],
        buyerName: json["buyerName"],
        buyerEmail: json["buyerEmail"],
        buyerPhone: json["buyerPhone"],
        sellerId: json["sellerId"],
        sellerName: json["sellerName"],
        orderId: json["orderId"],
        productName: json["productName"],
        issue: json["issue"],
        status: json["status"],
        adminReply: json["adminReply"],
        createdAt: json["createdAt"],
        resolvedAt: json["resolvedAt"],
        imageUrl:   json["imageUrl"]
      );

  Map<String, dynamic> toJson(String docId) => {
        "docId": docId,
        "complaintId": complaintId,
        "buyerId": buyerId ?? "",
        "buyerName": buyerName ?? "",
        "buyerEmail": buyerEmail ?? "",
        "buyerPhone": buyerPhone ?? "",
        "sellerId": sellerId ?? "",
        "sellerName": sellerName ?? "",
        "orderId": orderId ?? "",
        "productName": productName ?? "",
        "issue": issue ?? "",
        "status": status ?? "Pending",
        "adminReply": adminReply ?? "",
        "createdAt": createdAt,
        "resolvedAt": resolvedAt,
        "imageUrl"  : imageUrl ?? ""
      };
}
