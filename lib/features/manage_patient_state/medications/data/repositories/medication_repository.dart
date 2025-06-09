import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/features/manage_patient_state/medications/domain/models/medication.dart';

class MedicationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MedicationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> addMedication(Medication medication) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final medicationWithCaregiver = medication.copyWith(
      caregiverId: user.uid,
    );

    try {
      await _firestore
          .collection('users')
          .doc(medication.patientId)
          .collection('medications')
          .add(medicationWithCaregiver.toMap());
    } catch (e) {
      throw Exception('Failed to add medication: ${e.toString()}');
    }
  }

  Future<void> updateMedication(Medication medication) async {
    try {
      await _firestore
          .collection('users')
          .doc(medication.patientId)
          .collection('medications')
          .doc(medication.id)
          .update(medication.toMap());
    } catch (e) {
      throw Exception('Failed to update medication: ${e.toString()}');
    }
  }

  Future<void> deleteMedication(String patientId, String medicationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete medication: ${e.toString()}');
    }
  }

  Stream<List<Medication>> getPatientMedicationsStream(String patientId) {
    try {
      return _firestore
          .collection('users')
          .doc(patientId)
          .collection('medications')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medication.fromMap(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get medications stream: ${e.toString()}');
    }
  }
} 