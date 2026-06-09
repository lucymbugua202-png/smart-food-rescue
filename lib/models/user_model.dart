import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { administrator, donor, recipient }

class AppUser {
  final String id;
  String name;
  String email;
  final UserRole role;
  String phone;
  String? profileImage;
  final DateTime createdAt;
  bool isActive;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.profileImage,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'userId': id,
    'name': name,
    'email': email,
    'role': role.toString().split('.').last,
    'phone': phone,
    'profileImage': profileImage,
    'createdAt': Timestamp.fromDate(createdAt),
    'isActive': isActive,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Handle role - convert 'admin' to 'administrator'
    String roleString = json['role'] ?? 'recipient';
    if (roleString == 'admin') {
      roleString = 'administrator';
    }
    
    // Handle createdAt - could be Timestamp from Firestore or DateTime
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is DateTime) {
      createdAt = json['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }
    
    return AppUser(
      id: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == roleString,
        orElse: () => UserRole.recipient,
      ),
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      createdAt: createdAt,
      isActive: json['isActive'] ?? true,
    );
  }
}
