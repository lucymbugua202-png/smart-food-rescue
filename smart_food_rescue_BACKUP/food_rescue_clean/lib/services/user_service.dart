import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  static Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toJson());
      // Save FCM token after user creation
      await NotificationService.saveToken(user.id);
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  static Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return doc.get('role');
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  static Future<void> incrementDonations(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({
      'totalDonations': FieldValue.increment(1),
    });
  }

  static Future<void> incrementPickups(String userId) async {
    await _firestore.collection(_collection).doc(userId).update({
      'totalPickups': FieldValue.increment(1),
    });
  }

  // Update FCM token
  static Future<void> updateFCMToken(String userId, String token) async {
    await _firestore.collection(_collection).doc(userId).update({
      'fcmToken': token,
    });
  }
}
