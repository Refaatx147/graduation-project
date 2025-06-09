import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String patientId;
  final String caregiverId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.isCompleted = false,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      caregiverId: data['caregiverId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'caregiverId': caregiverId,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'isCompleted': isCompleted,
    };
  }
} 