import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  audio,
}

enum SenderType {
  patient,
  caregiver,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final SenderType senderType;
  final MessageType messageType;
  final String? text;
  final String? audioUrl;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderType,
    required this.messageType,
    this.text,
    this.audioUrl,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderType': senderType.toString(),
      'messageType': messageType.toString(),
      'text': text,
      'audioUrl': audioUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderType: SenderType.values.firstWhere(
        (e) => e.toString() == map['senderType'],
        orElse: () => SenderType.caregiver,
      ),
      messageType: MessageType.values.firstWhere(
        (e) => e.toString() == map['messageType'],
        orElse: () => MessageType.text,
      ),
      text: map['text'],
      audioUrl: map['audioUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
} 