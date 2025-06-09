// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/call_history.dart';

class CallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCallHistory({
    required String receiverId,
    required String receiverName,
    required bool isVideoCall,
    required int duration,
    required String status,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final callHistory = {
        'callerId': userId,
        'callerName': _auth.currentUser?.displayName ?? 'Unknown',
        'receiverId': receiverId,
        'receiverName': receiverName,
        'timestamp': FieldValue.serverTimestamp(),
        'duration': duration,
        'isVideoCall': isVideoCall,
        'status': status,
      };

      // Create a batch write
      final batch = _firestore.batch();

      // Save for caller
      final callerRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('call_history')
          .doc();
      batch.set(callerRef, callHistory);

      // Save for receiver
      final receiverRef = _firestore
          .collection('users')
          .doc(receiverId)
          .collection('call_history')
          .doc();
      batch.set(receiverRef, callHistory);

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error saving call history: $e');
      rethrow;
    }
  }

 Future<List<CallHistory>> getCallHistory() async {
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('call_history')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      DateTime timestamp;

      if (data['timestamp'] is Timestamp) {
        timestamp = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp'] is String) {
        timestamp = DateTime.tryParse(data['timestamp']) ?? DateTime.now();
      } else {
        timestamp = DateTime.now();
      }

      return CallHistory(
        id: doc.id,
        callerId: data['callerId'] ?? '',
        callerName: data['callerName'] ?? '',
        receiverId: data['receiverId'] ?? '',
        receiverName: data['receiverName'] ?? '',
        timestamp: timestamp,
        duration: data['duration'] ?? 0,
        isVideoCall: data['isVideoCall'] ?? false,
        status: data['status'] ?? 'unknown',
      );
    }).toList();
  } catch (e) {
    print('Error getting call history: $e');
    return [];
  }
}

}