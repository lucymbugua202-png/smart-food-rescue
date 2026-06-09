import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String foodId;
  final String foodTitle;
  final String donorId;
  final String donorName;
  final String recipientId;
  final String recipientName;
  final String recipientPhone;
  final String status; // pending, approved, rejected, completed
  final DateTime createdAt;
  final DateTime? updatedAt;

  RequestModel({
    required this.id,
    required this.foodId,
    required this.foodTitle,
    required this.donorId,
    required this.donorName,
    required this.recipientId,
    required this.recipientName,
    required this.recipientPhone,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'foodId': foodId,
    'foodTitle': foodTitle,
    'donorId': donorId,
    'donorName': donorName,
    'recipientId': recipientId,
    'recipientName': recipientName,
    'recipientPhone': recipientPhone,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
    id: json['id'],
    foodId: json['foodId'],
    foodTitle: json['foodTitle'],
    donorId: json['donorId'],
    donorName: json['donorName'],
    recipientId: json['recipientId'],
    recipientName: json['recipientName'],
    recipientPhone: json['recipientPhone'] ?? '',
    status: json['status'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
  );
}
