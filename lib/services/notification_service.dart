import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = {
      'notificationId': _firestore.collection('notifications').doc().id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    await _firestore.collection('notifications').add(notification);
    print('Notification sent to $userId: $title');
  }

  // Send notification to donor when someone requests their donation
  Future<void> notifyDonorOnRequest({
    required String donorId,
    required String donorName,
    required String donationTitle,
    required String recipientName,
  }) async {
    await sendNotification(
      userId: donorId,
      type: 'request',
      title: 'New Donation Request',
      message: '$recipientName has requested your donation: $donationTitle',
      data: {
        'donationTitle': donationTitle,
        'recipientName': recipientName,
      },
    );
  }

  // Send notification to recipient when request is approved
  Future<void> notifyRecipientOnApproval({
    required String recipientId,
    required String recipientName,
    required String donationTitle,
  }) async {
    await sendNotification(
      userId: recipientId,
      type: 'request',
      title: 'Request Approved!',
      message: 'Your request for $donationTitle has been approved. Please arrange pickup.',
      data: {
        'donationTitle': donationTitle,
        'status': 'approved',
      },
    );
  }

  // Send notification to recipient when request is rejected
  Future<void> notifyRecipientOnRejection({
    required String recipientId,
    required String recipientName,
    required String donationTitle,
  }) async {
    await sendNotification(
      userId: recipientId,
      type: 'request',
      title: 'Request Update',
      message: 'Your request for $donationTitle was not approved at this time.',
      data: {
        'donationTitle': donationTitle,
        'status': 'rejected',
      },
    );
  }

  // Send notification for new donation available
  Future<void> notifyRecipientsOfNewDonation({
    required String donationTitle,
    required String donationId,
    required List<String> recipientIds,
  }) async {
    for (var recipientId in recipientIds) {
      await sendNotification(
        userId: recipientId,
        type: 'donation',
        title: 'New Donation Available!',
        message: 'A new donation "$donationTitle" is now available in your area.',
        data: {
          'donationId': donationId,
          'donationTitle': donationTitle,
        },
      );
    }
  }
}
