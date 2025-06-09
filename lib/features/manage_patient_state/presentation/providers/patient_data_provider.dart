import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDataProvider {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PatientDataProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>> loadPatientData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return {
        'patientId': null,
        'patientName': null,
      };
    }

    try {
      final userData = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      return {
        'patientId': userData.data()?['linkedPatient'],
        'patientName': userData.data()?['patientName'],
      };
    } catch (e) {
      return {
        'patientId': null,
        'patientName': null,
      };
    }
  }
} 