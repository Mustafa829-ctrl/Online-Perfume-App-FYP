class AdminModel {
  final String? docId;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final bool? isBlocked;
  final int? createdAt;
  final String? profileImage;

  AdminModel({
    this.docId,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.isBlocked,
    this.createdAt,
    this.profileImage,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
    docId: json["docId"] ?? json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    role: json["role"],
    isBlocked: json["isBlocked"],
    createdAt: json["createdAt"],
    profileImage: json["profileImage"],
  );

  Map<String, dynamic> toJson(String uid) => {
    "docId": uid,
    "name": name,
    "email": email,
    "phone": phone ?? '',
    "role": "admin",
    "isBlocked": false,
    "createdAt": createdAt,
    "profileImage": profileImage ?? '',
  };
}