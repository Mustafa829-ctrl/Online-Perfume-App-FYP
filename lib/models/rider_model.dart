import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiderModel {
  final String? docId;
  final String? riderId;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? cnic;
  final String? licenseNumber;
  final String? vehicleModel;
  final String? vehicleNumber;
  final String? profileImage;
  final bool? isBlocked;
  final String? blockedReason;
  final String? role;
  final String? status;
  final String? sellerId;
  final String? sellerName;
  final int? createdAt;
  final int? updatedAt;

  RiderModel({
    this.docId,
    this.riderId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.cnic,
    this.licenseNumber,
    this.vehicleModel,
    this.vehicleNumber,
    this.profileImage,
    this.isBlocked = false,
    this.blockedReason,
    this.role = 'rider',
    this.status = 'active',
    this.sellerId,
    this.sellerName,
    this.createdAt,
    this.updatedAt,
  });

  // Factory Constructor
  factory RiderModel.fromJson(Map<String, dynamic> json) => RiderModel(
    docId: json["docId"],
    riderId: json["riderId"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    cnic: json["cnic"],
    licenseNumber: json["licenseNumber"],
    vehicleModel: json["vehicleModel"],
    vehicleNumber: json["vehicleNumber"],
    profileImage: json["profileImage"],
    isBlocked: json["isBlocked"] ?? false,
    blockedReason: json["blockedReason"],
    role: json["role"] ?? 'rider',
    status: json["status"] ?? 'active',
    sellerId: json["sellerId"],
    sellerName: json["sellerName"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  // ToJson Method
  Map<String, dynamic> toJson(String uid) => {
    "docId": uid,
    "riderId": riderId,
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "cnic": cnic,
    "licenseNumber": licenseNumber,
    "vehicleModel": vehicleModel,
    "vehicleNumber": vehicleNumber,
    "profileImage": profileImage,
    "isBlocked": isBlocked,
    "blockedReason": blockedReason,
    "role": role,
    "status": status,
    "sellerId": sellerId,
    "sellerName": sellerName,
    "createdAt": createdAt ?? DateTime.now().millisecondsSinceEpoch,
    "updatedAt": updatedAt ?? DateTime.now().millisecondsSinceEpoch,
  };

  // Helper Methods
  bool get isActive => status == 'active' && isBlocked == false;

  String get statusText {
    if (isBlocked == true) return 'Blocked';
    return status?.toUpperCase() ?? 'ACTIVE';
  }

  Color get statusColor {
    if (isBlocked == true) return Colors.red;
    return Colors.green;
  }
}