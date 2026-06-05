import 'package:cloud_firestore/cloud_firestore.dart';

class RiderModel {
  final String uid;
  final String riderId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String cnic;
  final String licenseNumber;
  final String vehicleModel;
  final String vehicleNumber;
  final String? profileImageUrl;
  final String? licenseImageUrl;
  final String? vehicleDocImageUrl;
  final String role;
  final String status; // active, blocked, inactive
  final bool isBlocked;
  final String? blockedReason;
  final String? sellerId; // which seller this rider belongs to
  final int totalDeliveries;
  final int successfulDeliveries;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RiderModel({
    required this.uid,
    required this.riderId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.cnic,
    required this.licenseNumber,
    required this.vehicleModel,
    required this.vehicleNumber,
    this.profileImageUrl,
    this.licenseImageUrl,
    this.vehicleDocImageUrl,
    this.role = 'rider',
    this.status = 'active',
    this.isBlocked = false,
    this.blockedReason,
    this.sellerId,
    this.totalDeliveries = 0,
    this.successfulDeliveries = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'riderId': riderId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'cnic': cnic,
      'licenseNumber': licenseNumber,
      'vehicleModel': vehicleModel,
      'vehicleNumber': vehicleNumber,
      'profileImageUrl': profileImageUrl,
      'licenseImageUrl': licenseImageUrl,
      'vehicleDocImageUrl': vehicleDocImageUrl,
      'role': role,
      'status': status,
      'isBlocked': isBlocked,
      'blockedReason': blockedReason,
      'sellerId': sellerId,
      'totalDeliveries': totalDeliveries,
      'successfulDeliveries': successfulDeliveries,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory RiderModel.fromMap(Map<String, dynamic> map) {
    return RiderModel(
      uid: map['uid'] ?? '',
      riderId: map['riderId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      cnic: map['cnic'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      vehicleModel: map['vehicleModel'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      licenseImageUrl: map['licenseImageUrl'],
      vehicleDocImageUrl: map['vehicleDocImageUrl'],
      role: map['role'] ?? 'rider',
      status: map['status'] ?? 'active',
      isBlocked: map['isBlocked'] ?? false,
      blockedReason: map['blockedReason'],
      sellerId: map['sellerId'],
      totalDeliveries: map['totalDeliveries'] ?? 0,
      successfulDeliveries: map['successfulDeliveries'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  RiderModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? licenseNumber,
    String? vehicleModel,
    String? vehicleNumber,
    String? profileImageUrl,
    String? licenseImageUrl,
    String? vehicleDocImageUrl,
    String? status,
    bool? isBlocked,
    String? blockedReason,
    int? totalDeliveries,
    int? successfulDeliveries,
    DateTime? updatedAt,
  }) {
    return RiderModel(
      uid: uid,
      riderId: riderId,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      cnic: cnic,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      vehicleDocImageUrl: vehicleDocImageUrl ?? this.vehicleDocImageUrl,
      role: role,
      status: status ?? this.status,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedReason: blockedReason ?? this.blockedReason,
      sellerId: sellerId,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      successfulDeliveries: successfulDeliveries ?? this.successfulDeliveries,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}