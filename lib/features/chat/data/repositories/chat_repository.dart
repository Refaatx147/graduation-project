// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> _ensureChatExists(String otherUserId) async {
    final chatId = _getChatId(_currentUserId, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      // Fetch user roles to determine caregiver and patient
      final currentUserDoc = await _firestore.collection('users').doc(_currentUserId).get();
      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();

      final currentUserRole = currentUserDoc.data()?['role'];
      final otherUserRole = otherUserDoc.data()?['role'];

      String? caregiverId;
      String? patientId;

      if (currentUserRole == 'caregiver' && otherUserRole == 'patient') {
        caregiverId = _currentUserId;
        patientId = otherUserId;
      } else if (currentUserRole == 'patient' && otherUserRole == 'caregiver') {
        caregiverId = otherUserId;
        patientId = _currentUserId;
      } else {
        // Handle cases where roles are not as expected or missing
        print('Error: Could not determine caregiver and patient roles for chat creation.');
        // Depending on your app logic, you might throw an error or handle this differently
        return; 
      }

      if (caregiverId != null && patientId != null) {
         // Create chat document with caregiver and patient IDs
        await chatRef.set({
          'caregiverId': caregiverId,
          'patientId': patientId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
         print('ChatRepository: Created new chat document with caregiverId: $caregiverId, patientId: $patientId');
      } else {
         print('ChatRepository: Failed to create chat document due to missing caregiverId or patientId.');
      }
     
    }
     else {
       print('ChatRepository: Chat document $chatId already exists.');
     }
  }

  Future<void> sendMessage({
    required String receiverId,
    required MessageType messageType,
    String? text,
    String? audioUrl,
    required SenderType senderType,
  }) async {
    await _ensureChatExists(receiverId);
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      receiverId: receiverId,
      senderType: senderType,
      messageType: messageType,
      text: text,
      audioUrl: audioUrl,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final chatId = _getChatId(_currentUserId, receiverId);
    
    // Update last message timestamp
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Stream<List<ChatMessage>> getMessages(String otherUserId) {
    final controller = StreamController<List<ChatMessage>>();
    print('ChatRepository: getMessages called for otherUserId: $otherUserId');

    _ensureChatExists(otherUserId).then((_) {
      print('ChatRepository: _ensureChatExists completed for $otherUserId');
      final chatId = _getChatId(_currentUserId, otherUserId);
      print('ChatRepository: Chat ID determined: $chatId');

      // First check if user has access to this chat
      _firestore.collection('chats').doc(chatId).get().then((chatDoc) {
        print('ChatRepository: Fetched chat document for $chatId');
        if (!chatDoc.exists) {
          print('ChatRepository: Chat document $chatId does not exist.');
          controller.addError('Chat not found');
          controller.close();
          return;
        }

        final chatData = chatDoc.data()!;
        print('ChatRepository: Chat data: $chatData');
        if (chatData['caregiverId'] != _currentUserId && chatData['patientId'] != _currentUserId) {
          print('ChatRepository: Access denied for user $_currentUserId to chat $chatId. Caregiver: ${chatData['caregiverId']}, Patient: ${chatData['patientId']}');
          controller.addError('Access denied');
          controller.close();
          return;
        }
        
        print('ChatRepository: Access granted for user $_currentUserId to chat $chatId. Setting up messages stream.');

        // If access is granted, stream the messages
        final messagesStream = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) {
              print('ChatRepository: Messages stream received snapshot.');
              return snapshot.docs
                  .map((doc) => ChatMessage.fromMap(doc.data()))
                  .toList();
            });

        messagesStream.listen(
          (messages) {
            print('ChatRepository: Messages stream added data.');
            controller.add(messages);
          },
          onError: (error) {
            print('ChatRepository: Messages stream encountered error: $error');
            controller.addError(error);
          },
          onDone: () {
            print('ChatRepository: Messages stream is done.');
            controller.close();
          },
        );
      }).catchError((error) {
        print('ChatRepository: Error fetching chat document or setting up stream: $error');
        controller.addError(error);
        controller.close();
      });
    }).catchError((error) {
      print('ChatRepository: Error ensuring chat exists: $error');
      controller.addError(error);
      controller.close();
    });

    return controller.stream;
  }

  Future<void> markMessageAsRead(String messageId, String otherUserId) async {
    await _ensureChatExists(otherUserId);
    
    await _firestore
        .collection('chats')
        .doc(_getChatId(_currentUserId, otherUserId))
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[1]}_${sortedIds[0]}';
  }

  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['isOnline'] ?? false);
  }
} 