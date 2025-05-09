import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/link_users/link_users_state.dart';


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

      // Check existing linkage
     
      // Find patient with shareToken
      final patientQuery = await _firestore.collection('users')
          .where('shareToken', isEqualTo: shareToken)
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (patientQuery.docs.isEmpty) {
        throw Exception('Invalid QR code');
      }

      final patientId = patientQuery.docs.first.id;

      // Batch write for atomic update
      final batch = _firestore.batch();
      
      batch.update(
        _firestore.collection('users').doc(caregiver.uid),
        {'linkedPatient': patientId}
      );
      
      batch.update(
        _firestore.collection('users').doc(patientId),
        {'linkedCaregivers': FieldValue.arrayUnion([caregiver.uid])}
      );

      await batch.commit();
      emit(CaregiverLinked(patientId: patientId));
    } catch (e) {
       final caregiverDoc = await _firestore.collection('users').doc(caregiver!.uid).get();
      if (caregiverDoc.data()?['linkedPatient'] != null) {
     //   print('ahmed ahmed ${caregiverDoc.data()!}') ;


      emit(CaregiverError(message: 'You are already linked to a patient'));
      } else {
        emit(CaregiverError(message: e.toString()));
      }
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