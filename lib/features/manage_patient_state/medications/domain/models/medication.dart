import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String patientId;
  final String caregiverId;
  final String name;
  final String dosage;
  final String instructions;
  final List<DateTime> times;

  Medication({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.times,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'caregiverId': caregiverId,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'times': times.map((time) => Timestamp.fromDate(time)).toList(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      instructions: map['instructions'] ?? '',
      times: (map['times'] as List<dynamic>?)
              ?.map((time) => (time as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Medication copyWith({
    String? id,
    String? patientId,
    String? caregiverId,
    String? name,
    String? dosage,
    String? instructions,
    List<DateTime>? times,
  }) {
    return Medication(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      times: times ?? this.times,
    );
  }
} 