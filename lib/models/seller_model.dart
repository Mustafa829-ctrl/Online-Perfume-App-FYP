class SellerModel {
  final String? docId;
  final String? sellerId;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? cnic;
  final String? businessName;
  final String? businessAddress;
  final String? businessType;
  final String? profileImageUrl;
  final bool? isVerified;
  final bool? isBlocked;
  final String? blockedReason;
  final String? role;
  final String? status;
  final int? createdAt;

  // ── NEW FIELDS
  final String? shopTagline;
  final String? businessEmail;
  final String? businessPhone;
  final double? rating;

  SellerModel({
    this.docId,
    this.sellerId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.cnic,
    this.businessName,
    this.businessAddress,
    this.businessType,
    this.profileImageUrl,
    this.isVerified,
    this.isBlocked,
    this.blockedReason,
    this.role,
    this.status,
    this.createdAt,
    this.shopTagline,
    this.businessEmail,
    this.businessPhone,
    this.rating,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) => SellerModel(
    docId:           json["docId"],
    sellerId:        json["sellerId"],
    name:            json["name"],
    email:           json["email"],
    phone:           json["phone"],
    address:         json["address"],
    cnic:            json["cnic"],
    businessName:    json["businessName"],
    businessAddress: json["businessAddress"],
    businessType:    json["businessType"],
    profileImageUrl: json["profileImageUrl"],
    isVerified:      json["isVerified"],
    isBlocked:       json["isBlocked"],
    blockedReason:   json["blockedReason"],
    role:            json["role"],
    status:          json["status"],
    createdAt:       json["createdAt"],
    shopTagline:     json["shopTagline"],
    businessEmail:   json["businessEmail"],
    businessPhone:   json["businessPhone"],
    rating:          (json["rating"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson(String uid) => {
    "docId":           uid,
    "sellerId":        sellerId,
    "name":            name,
    "email":           email,
    "phone":           phone,
    "address":         address,
    "cnic":            cnic,
    "businessName":    businessName,
    "businessAddress": businessAddress,
    "businessType":    businessType,
    "profileImageUrl": profileImageUrl,
    "isVerified":      false,
    "isBlocked":       false,
    "blockedReason":   null,
    "role":            "seller",
    "status":          "active",
    "createdAt":       createdAt,
    "shopTagline":     shopTagline ?? "",
    "businessEmail":   businessEmail ?? "",
    "businessPhone":   businessPhone ?? "",
    "rating":          rating ?? 0.0,
  };
}