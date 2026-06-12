class UserModel {
  final String? docId;
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final bool? isBlocked;
  final String? blockedReason;
  final String? role;
  final int? createdAt;

  UserModel({
    this.docId,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.isBlocked,
    this.blockedReason,
    this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        docId: json["docId"],
        userId: json["userId"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        profileImageUrl: json["profileImageUrl"],
        isBlocked: json["isBlocked"],
        blockedReason: json["blockedReason"],
        role: json["role"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson(String uid) => {
        "docId": uid,
        "userId": uid,
        "name": name,
        "email": email,
        "phone": phone ?? "",
        "address": address ?? "",
        "profileImageUrl": profileImageUrl ?? "",
        "isBlocked": false,
        "blockedReason": null,
        "role": "buyer",
        "createdAt": createdAt,
      };
}
