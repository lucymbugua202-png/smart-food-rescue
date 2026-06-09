import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String requestId;
  final String foodId;
  final String foodTitle;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.requestId,
    required this.foodId,
    required this.foodTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'fromUserName': fromUserName,
    'toUserId': toUserId,
    'toUserName': toUserName,
    'requestId': requestId,
    'foodId': foodId,
    'foodTitle': foodTitle,
    'rating': rating,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json['id'],
    fromUserId: json['fromUserId'],
    fromUserName: json['fromUserName'],
    toUserId: json['toUserId'],
    toUserName: json['toUserName'],
    requestId: json['requestId'],
    foodId: json['foodId'],
    foodTitle: json['foodTitle'],
    rating: (json['rating'] ?? 0).toDouble(),
    comment: json['comment'] ?? '',
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}

class UserRating {
  final String userId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;

  UserRating({
    required this.userId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'averageRating': averageRating,
    'totalRatings': totalRatings,
    'ratingDistribution': ratingDistribution,
  };

  factory UserRating.fromJson(Map<String, dynamic> json) => UserRating(
    userId: json['userId'],
    averageRating: (json['averageRating'] ?? 0).toDouble(),
    totalRatings: json['totalRatings'] ?? 0,
    ratingDistribution: Map<int, int>.from(json['ratingDistribution'] ?? {}),
  );
}
