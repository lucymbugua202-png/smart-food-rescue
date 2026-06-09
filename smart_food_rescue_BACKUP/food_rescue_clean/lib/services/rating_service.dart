import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/rating_model.dart';

class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ratingsCollection = 'ratings';
  static const String _userRatingsCollection = 'user_ratings';

  // Add a rating
  static Future<void> addRating({
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
    required String requestId,
    required String foodId,
    required String foodTitle,
    required double rating,
    required String comment,
  }) async {
    final ratingId = const Uuid().v4();
    
    final ratingObj = Rating(
      id: ratingId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toUserId: toUserId,
      toUserName: toUserName,
      requestId: requestId,
      foodId: foodId,
      foodTitle: foodTitle,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection(_ratingsCollection).doc(ratingId).set(ratingObj.toJson());
    
    // Update user's average rating
    await _updateUserRating(toUserId);
  }

  // Update user's average rating
  static Future<void> _updateUserRating(String userId) async {
    final ratings = await _firestore
        .collection(_ratingsCollection)
        .where('toUserId', isEqualTo: userId)
        .get();
    
    if (ratings.docs.isEmpty) return;
    
    double total = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    for (var doc in ratings.docs) {
      final rating = (doc.data()['rating'] ?? 0).toDouble();
      total += rating;
      final intRating = rating.toInt();
      distribution[intRating] = (distribution[intRating] ?? 0) + 1;
    }
    
    final average = total / ratings.docs.length;
    
    final userRating = UserRating(
      userId: userId,
      averageRating: average,
      totalRatings: ratings.docs.length,
      ratingDistribution: distribution,
    );
    
    await _firestore.collection(_userRatingsCollection).doc(userId).set(userRating.toJson());
  }

  // Get user rating
  static Future<UserRating?> getUserRating(String userId) async {
    final doc = await _firestore.collection(_userRatingsCollection).doc(userId).get();
    if (doc.exists) {
      return UserRating.fromJson(doc.data()!);
    }
    return null;
  }

  // Get ratings for a user
  static Stream<List<Rating>> getUserRatings(String userId) {
    return _firestore
        .collection(_ratingsCollection)
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Rating.fromJson(doc.data());
          }).toList();
        });
  }

  // Check if user can rate (request completed)
  static Future<bool> canRate(String userId, String requestId) async {
    final rating = await _firestore
        .collection(_ratingsCollection)
        .where('fromUserId', isEqualTo: userId)
        .where('requestId', isEqualTo: requestId)
        .limit(1)
        .get();
    
    return rating.docs.isEmpty;
  }
}
