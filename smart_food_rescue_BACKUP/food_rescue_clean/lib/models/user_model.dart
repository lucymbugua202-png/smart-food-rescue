import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? profileImage;
  final int totalDonations;
  final int totalPickups;
  final double rating;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profileImage,
    this.totalDonations = 0,
    this.totalPickups = 0,
    this.rating = 0.0,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'address': address,
    'profileImage': profileImage,
    'totalDonations': totalDonations,
    'totalPickups': totalPickups,
    'rating': rating,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    phone: json['phone'],
    address: json['address'],
    profileImage: json['profileImage'],
    totalDonations: json['totalDonations'] ?? 0,
    totalPickups: json['totalPickups'] ?? 0,
    rating: (json['rating'] ?? 0.0).toDouble(),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    lastLogin: json['lastLogin'] != null ? (json['lastLogin'] as Timestamp).toDate() : null,
  );
}
