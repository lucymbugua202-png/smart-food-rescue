import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String foodId;
  final String foodTitle;
  final String donorId;
  final String donorName;
  final String donorPhoto;
  final String recipientId;
  final String recipientName;
  final String recipientPhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.foodId,
    required this.foodTitle,
    required this.donorId,
    required this.donorName,
    required this.donorPhoto,
    required this.recipientId,
    required this.recipientName,
    required this.recipientPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'foodId': foodId,
    'foodTitle': foodTitle,
    'donorId': donorId,
    'donorName': donorName,
    'donorPhoto': donorPhoto,
    'recipientId': recipientId,
    'recipientName': recipientName,
    'recipientPhoto': recipientPhoto,
    'lastMessage': lastMessage,
    'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    'unreadCount': unreadCount,
    'isActive': isActive,
  };

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
    id: json['id'],
    foodId: json['foodId'],
    foodTitle: json['foodTitle'],
    donorId: json['donorId'],
    donorName: json['donorName'],
    donorPhoto: json['donorPhoto'] ?? '',
    recipientId: json['recipientId'],
    recipientName: json['recipientName'],
    recipientPhoto: json['recipientPhoto'] ?? '',
    lastMessage: json['lastMessage'],
    lastMessageTime: (json['lastMessageTime'] as Timestamp).toDate(),
    unreadCount: json['unreadCount'] ?? 0,
    isActive: json['isActive'] ?? true,
  );
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatRoomId': chatRoomId,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'timestamp': Timestamp.fromDate(timestamp),
    'isRead': isRead,
    'imageUrl': imageUrl,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    chatRoomId: json['chatRoomId'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    message: json['message'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    isRead: json['isRead'] ?? false,
    imageUrl: json['imageUrl'],
  );
}
