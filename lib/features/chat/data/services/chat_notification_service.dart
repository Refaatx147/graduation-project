import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/core/services/push_notifications.dart';
import 'package:grade_pro/features/chat/domain/models/chat_message.dart';

class ChatNotificationService {
  static Future<void> sendMessageNotification(ChatMessage message) async {
    try {
      // Get sender's name
      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(message.senderId)
          .get();
      
      final senderName = senderDoc.data()?['name'] ?? 'Someone';
      final messageType = message.messageType == MessageType.text ? 'message' : 'voice message';
      
      // Send notification
      await PushNotifications.sendNotification(
        receiverId: message.receiverId,
        title: 'New $messageType from $senderName',
        body: message.messageType == MessageType.text 
            ? message.text ?? ''
            : 'Sent you a voice message',
        data: {
          'type': 'chat_message',
          'messageId': message.id,
          'senderId': message.senderId,
          'senderType': message.senderType.toString(),
          'messageType': message.messageType.toString(),
          'chatId': '${message.senderId}_${message.receiverId}',
        },
      );
    } catch (e) {
      // Handle error silently
      print('Error sending chat notification: $e');
    }
  }

  static Future<void> markMessageAsRead(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      // Handle error silently
      print('Error marking message as read: $e');
    }
  }
} 