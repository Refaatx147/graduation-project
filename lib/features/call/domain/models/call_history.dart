import 'package:cloud_firestore/cloud_firestore.dart';

class CallHistory {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final DateTime timestamp;
  final int duration;
  final bool isVideoCall;
  final String status; // 'completed', 'missed', 'declined'

  CallHistory({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.timestamp,
    required this.duration,
    required this.isVideoCall,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isVideoCall': isVideoCall,
      'duration': duration,
      'status': status,
    };
  }

  factory CallHistory.fromMap(Map<String, dynamic> map) {
    DateTime timestamp;
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      timestamp = DateTime.parse(map['timestamp'] as String);
    } else {
      timestamp = DateTime.now();
    }

    return CallHistory(
      id: map['id'] as String,
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      timestamp: timestamp,
      isVideoCall: map['isVideoCall'] as bool,
      duration: map['duration'] as int,
      status: map['status'] as String,
    );
  }
}