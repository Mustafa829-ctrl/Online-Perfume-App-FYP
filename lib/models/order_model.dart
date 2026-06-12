class OrderModel {
  final String? docId;
  final String? orderId;
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerAddress;
  final String? productName;
  final int? quantity;
  final int? amount;
  final String? status;
  final String? riderId;
  final String? riderName;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final bool? isPaid;
  final String? notDeliveredReason;
  final int? assignedAt;
  final int? deliveredAt;
  final int? createdAt;
  final String? buyerId;
  final String? buyerPaymentStatus;
  final String? riderPaymentStatus;
  final String? deliveryType;
  final String? courierName;
  final String? trackingNumber;
  final int? clearedAt;
  final String? returnReason;

  OrderModel({
    this.docId,
    this.orderId,
    this.buyerName,
    this.buyerPhone,
    this.buyerAddress,
    this.productName,
    this.quantity,
    this.amount,
    this.status,
    this.riderId,
    this.riderName,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.isPaid,
    this.notDeliveredReason,
    this.assignedAt,
    this.deliveredAt,
    this.createdAt,
    this.buyerId,
    this.buyerPaymentStatus,
    this.riderPaymentStatus,
    this.deliveryType,
    this.courierName,
    this.trackingNumber,
    this.clearedAt,
    this.returnReason
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    docId:                json["docId"],
    orderId:              json["orderId"],
    buyerName:            json["buyerName"],
    buyerPhone:           json["buyerPhone"],
    buyerAddress:         json["buyerAddress"],
    productName:          json["productName"],
    quantity:             json["quantity"],
    amount:               json["amount"],
    status:               json["status"],
    riderId:              json["riderId"],
    riderName:            json["riderName"],
    sellerId:             json["sellerId"],
    sellerName:           json["sellerName"],
    sellerPhone:          json["sellerPhone"],
    isPaid:               json["isPaid"],
    notDeliveredReason:   json["notDeliveredReason"],
    assignedAt:           json["assignedAt"],
    deliveredAt:          json["deliveredAt"],
    createdAt:            json["createdAt"],
    buyerId:              json["buyerId"],
    buyerPaymentStatus:   json["buyerPaymentStatus"],
    riderPaymentStatus:   json["riderPaymentStatus"],
    deliveryType:         json["deliveryType"],
    courierName:          json["courierName"],
    trackingNumber:       json["trackingNumber"],
    clearedAt:            json["clearedAt"],
    returnReason:         json["returnReason"],
  );

  Map<String, dynamic> toJson(String docId) => {
    "docId":                docId,
    "orderId":              orderId,
    "buyerName":            buyerName,
    "buyerPhone":           buyerPhone,
    "buyerAddress":         buyerAddress,
    "productName":          productName,
    "quantity":             quantity ?? 1,
    "amount":               amount ?? 0,
    "status":               status ?? "Assigned",
    "riderId":              riderId ?? "",
    "riderName":            riderName ?? "",
    "sellerId":             sellerId ?? "",
    "sellerName":           sellerName ?? "",
    "sellerPhone":          sellerPhone ?? "",
    "isPaid":               isPaid ?? false,
    "notDeliveredReason":   notDeliveredReason ?? "",
    "assignedAt":           assignedAt,
    "deliveredAt":          deliveredAt,
    "createdAt":            createdAt,
    "buyerId":              buyerId ?? "",
    "buyerPaymentStatus":   buyerPaymentStatus ?? "Pending",
    "riderPaymentStatus":   riderPaymentStatus ?? "Pending",
    "deliveryType":         deliveryType ?? "Rider",
    "courierName":          courierName ?? "",
    "trackingNumber":       trackingNumber ?? "",
    "clearedAt":            clearedAt,
    "returnReason":         returnReason ?? "",
  };
}