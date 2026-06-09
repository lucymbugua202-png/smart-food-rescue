import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _chatRoomsCollection = 'chat_rooms';
  static const String _messagesCollection = 'messages';

  // Create a new chat room
  static Future<String> createChatRoom({
    required String foodId,
    required String foodTitle,
    required String donorId,
    required String donorName,
    required String recipientId,
    required String recipientName,
  }) async {
    final chatRoomId = const Uuid().v4();
    
    // Check if chat room already exists
    final existingRooms = await _firestore
        .collection(_chatRoomsCollection)
        .where('foodId', isEqualTo: foodId)
        .where('donorId', isEqualTo: donorId)
        .where('recipientId', isEqualTo: recipientId)
        .get();
    
    if (existingRooms.docs.isNotEmpty) {
      return existingRooms.docs.first.id;
    }
    
    final chatRoom = ChatRoom(
      id: chatRoomId,
      foodId: foodId,
      foodTitle: foodTitle,
      donorId: donorId,
      donorName: donorName,
      donorPhoto: '',
      recipientId: recipientId,
      recipientName: recipientName,
      recipientPhoto: '',
      lastMessage: 'Chat started',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isActive: true,
    );
    
    await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).set(chatRoom.toJson());
    return chatRoomId;
  }

  // Get all chat rooms for a user
  static Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    // Stream for rooms where user is donor
    final donorRooms = _firestore
        .collection(_chatRoomsCollection)
        .where('donorId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatRoom.fromJson(doc.data())).toList());
    
    // Stream for rooms where user is recipient
    final recipientRooms = _firestore
        .collection(_chatRoomsCollection)
        .where('recipientId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatRoom.fromJson(doc.data())).toList());
    
    // Combine both streams into a single stream
    return donorRooms.asyncExpand((donorList) {
      return recipientRooms.map((recipientList) {
        final allRooms = [...donorList, ...recipientList];
        allRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return allRooms;
      });
    });
  }

  // Get messages for a chat room
  static Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessage.fromJson(doc.data());
          }).toList();
        });
  }

  // Send a message
  static Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    final messageId = const Uuid().v4();
    
    final chatMessage = ChatMessage(
      id: messageId,
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );
    
    await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesCollection)
        .doc(messageId)
        .set(chatMessage.toJson());
    
    // Update last message and increment unread count for the other user
    final chatRoom = await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).get();
    final data = chatRoom.data()!;
    
    final isDonor = data['donorId'] == senderId;
    final otherUserId = isDonor ? data['recipientId'] : data['donorId'];
    
    // Get current unread count for the other user
    final currentUnread = data['unreadCount'] ?? 0;
    
    await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': currentUnread + 1,
    });
  }

  // Mark messages as read for a specific user in a chat room
  static Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    final messages = await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesCollection)
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
    
    // Reset unread count for this user
    await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).update({
      'unreadCount': 0,
    });
  }

  // Get unread message count for a user
  static Future<int> getUnreadCount(String userId) async {
    int totalUnread = 0;
    
    final donorRooms = await _firestore
        .collection(_chatRoomsCollection)
        .where('donorId', isEqualTo: userId)
        .get();
    
    for (var doc in donorRooms.docs) {
      final unread = doc.data()['unreadCount'] ?? 0;
      totalUnread += unread is int ? unread : (unread as num).toInt();
    }
    
    final recipientRooms = await _firestore
        .collection(_chatRoomsCollection)
        .where('recipientId', isEqualTo: userId)
        .get();
    
    for (var doc in recipientRooms.docs) {
      final unread = doc.data()['unreadCount'] ?? 0;
      totalUnread += unread is int ? unread : (unread as num).toInt();
    }
    
    return totalUnread;
  }

  // Delete a chat room
  static Future<void> deleteChatRoom(String chatRoomId) async {
    // Delete all messages first
    final messages = await _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesCollection)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    
    // Delete the chat room
    await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).delete();
  }
}
