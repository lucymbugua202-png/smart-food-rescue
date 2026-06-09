import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import 'food_service.dart';

class RequestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'requests';

  static Future<void> createRequest(RequestModel request) async {
    try {
      await _firestore.collection(_collection).doc(request.id).set(request.toJson());
      await FoodService.updateFoodStatus(request.foodId, 'requested');
      
      // Send notification to donor
      await _sendNotification(
        recipientId: request.donorId,
        title: 'New Food Request!',
        body: '${request.recipientName} wants to request "${request.foodTitle}"',
        type: 'new_request',
        requestId: request.id,
      );
    } catch (e) {
      print('Error creating request: $e');
      rethrow;
    }
  }

  static Stream<List<RequestModel>> getDonorRequests(String donorId) {
    return _firestore
        .collection(_collection)
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map((snapshot) {
          List<RequestModel> requests = snapshot.docs.map((doc) {
            return RequestModel.fromJson(doc.data());
          }).toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  static Stream<List<RequestModel>> getRecipientRequests(String recipientId) {
    return _firestore
        .collection(_collection)
        .where('recipientId', isEqualTo: recipientId)
        .snapshots()
        .map((snapshot) {
          List<RequestModel> requests = snapshot.docs.map((doc) {
            return RequestModel.fromJson(doc.data());
          }).toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  static Future<void> updateRequestStatus(String requestId, String status) async {
    final request = await getRequest(requestId);
    await _firestore.collection(_collection).doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    if (request != null) {
      // Send notification to recipient
      String title = status == 'approved' ? 'Request Approved! 🎉' : 'Request Update';
      String body = status == 'approved' 
          ? 'Your request for "${request.foodTitle}" has been approved!'
          : 'Your request for "${request.foodTitle}" has been ${status}.';
      
      await _sendNotification(
        recipientId: request.recipientId,
        title: title,
        body: body,
        type: 'request_${status}',
        requestId: requestId,
      );
    }
  }

  static Future<RequestModel?> getRequest(String requestId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(requestId).get();
      if (doc.exists) {
        return RequestModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting request: $e');
      return null;
    }
  }

  static Future<void> _sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    String? requestId,
  }) async {
    try {
      // Get recipient's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(recipientId).get();
      final token = userDoc.data()?['fcmToken'];
      
      if (token != null && token.isNotEmpty) {
        // Create notification document in Firestore
        await _firestore.collection('notifications').add({
          'userId': recipientId,
          'title': title,
          'body': body,
          'type': type,
          'requestId': requestId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Note: In production, you would send via Cloud Function
        print('Notification created for user: $recipientId');
        print('Title: $title');
        print('Body: $body');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
