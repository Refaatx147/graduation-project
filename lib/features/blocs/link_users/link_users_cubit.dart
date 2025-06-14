import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/features/blocs/link_users/link_users_state.dart';


class PatientCubit extends Cubit<PatientState> {
  PatientCubit() : super(PatientInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadShareToken() async {
    emit(PatientLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      emit(PatientLoaded(shareToken: doc['shareToken']));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }
}




class CaregiverCubit extends Cubit<CaregiverState> {
  CaregiverCubit() : super(CaregiverInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> linkCaregiverToPatient(String shareToken) async {
    final caregiver = FirebaseAuth.instance.currentUser;

    emit(CaregiverLinking());
    try {
      if (caregiver == null) throw Exception('Not authenticated');

      // Get caregiver's data to access patient name
      final caregiverDoc = await _firestore.collection('users').doc(caregiver.uid).get();
      final patientName = caregiverDoc.data()?['patientName'];
      
      if (patientName == null || patientName.isEmpty) {
        emit(CaregiverError(message: 'Please enter patient name first'));
        return;
      }

      // Check if caregiver is already linked
      if (caregiverDoc.data()?['linkedPatient'] != null) {
        emit(CaregiverError(message: 'You are already linked to a patient'));
        return;
      }

      // Find patient with shareToken
      final patientQuery = await _firestore.collection('users')
          .where('shareToken', isEqualTo: shareToken)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (patientQuery.docs.isEmpty) {
        throw Exception('Invalid QR code');
      }

      final patientDoc = patientQuery.docs.first;
      final patientId = patientDoc.id;

      // Check if patient already has a linked caregiver
      final patientData = patientDoc.data();
      final linkedCaregivers = List<String>.from(patientData['linkedCaregivers'] ?? []);
      if (linkedCaregivers.contains(caregiver.uid)) {
        emit(CaregiverError(message: 'You are already linked to this patient'));
        return;
      }

      // Batch write for atomic update
      final batch = _firestore.batch();
      
      // Update caregiver's document
      batch.update(
        _firestore.collection('users').doc(caregiver.uid),
        {'linkedPatient': patientId}
      );
      
      // Update patient's document with the name from caregiver
      batch.update(
        _firestore.collection('users').doc(patientId),
        {
          'linkedCaregivers': FieldValue.arrayUnion([caregiver.uid]),
          'name': patientName  // Store the name from caregiver in patient's document
        }
      );

      await batch.commit();
      emit(CaregiverLinked(patientId: patientId));
    } catch (e) {
      emit(CaregiverError(message: e.toString()));
    }
  }


  Future<String?> checkIfCaregiverLinked() async {
    final caregiver = FirebaseAuth.instance.currentUser;
    if (caregiver == null) return null;

    final doc = await _firestore.collection('users').doc(caregiver.uid).get();
    final linkedPatient = doc.data()?['linkedPatient'];
    return linkedPatient;
  }
}