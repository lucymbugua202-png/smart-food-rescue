import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String donorId;
  final String donorName;
  final String title;
  final String description;
  final String category;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final DateTime createdAt;
  final String pickupAddress;
  final String status;
  final String? imageUrl;
  final String? claimedBy;
  final DateTime? claimedAt;

  FoodModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.title,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.createdAt,
    required this.pickupAddress,
    required this.status,
    this.imageUrl,
    this.claimedBy,
    this.claimedAt,
  });

  bool get isAvailable => status == 'available';
  bool get isUrgent => expiryDate.difference(DateTime.now()).inDays <= 1;
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 3;

  Map<String, dynamic> toJson() => {
    'id': id,
    'donorId': donorId,
    'donorName': donorName,
    'title': title,
    'description': description,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'expiryDate': Timestamp.fromDate(expiryDate),
    'createdAt': Timestamp.fromDate(createdAt),
    'pickupAddress': pickupAddress,
    'status': status,
    'imageUrl': imageUrl,
    'claimedBy': claimedBy,
    'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
  };

  factory FoodModel.fromJson(Map<String, dynamic> json) => FoodModel(
    id: json['id'],
    donorId: json['donorId'],
    donorName: json['donorName'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    quantity: (json['quantity'] ?? 0).toDouble(),
    unit: json['unit'],
    expiryDate: (json['expiryDate'] as Timestamp).toDate(),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    pickupAddress: json['pickupAddress'],
    status: json['status'],
    imageUrl: json['imageUrl'],
    claimedBy: json['claimedBy'],
    claimedAt: json['claimedAt'] != null ? (json['claimedAt'] as Timestamp).toDate() : null,
  );
}
