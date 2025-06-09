// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AppointmentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Stream<List<Appointment>> getPatientAppointmentsStream(String patientId) {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      return _firestore
          .collection('users')
          .doc(patientId)
          .collection('appointments')
          .orderBy('dateTime', descending: false)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error in getPatientAppointmentsStream: $e');
      rethrow;
    }
  }

  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(patientId)
          .collection('appointments')
          .orderBy('dateTime', descending: false)
          .get();

      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error in getPatientAppointments: $e');
      rethrow;
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Verify the caregiver's role and linked patient
      final caregiverDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!caregiverDoc.exists) {
        throw Exception('Caregiver not found');
      }

      final userData = caregiverDoc.data();
      if (userData?['role'] != 'caregiver') {
        throw Exception('User is not a caregiver');
      }

      final linkedPatient = userData?['linkedPatient'];
      if (linkedPatient != appointment.patientId) {
        throw Exception('Caregiver is not linked to this patient');
      }

      final docRef = _firestore
          .collection('users')
          .doc(appointment.patientId)
          .collection('appointments')
          .doc();

      final data = {
        ...appointment.toMap(),
        'id': docRef.id,
        'caregiverId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await docRef.set(data);
    } catch (e) {
      print('Error in addAppointment: $e');
      rethrow;
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Verify the caregiver's permission
      final appointmentDoc = await _firestore
          .collection('users')
          .doc(appointment.patientId)
          .collection('appointments')
          .doc(appointment.id)
          .get();

      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      if (appointmentDoc.data()?['caregiverId'] != currentUser.uid) {
        throw Exception('Not authorized to update this appointment');
      }

      final data = {
        ...appointment.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection('users')
          .doc(appointment.patientId)
          .collection('appointments')
          .doc(appointment.id)
          .update(data);
    } catch (e) {
      print('Error in updateAppointment: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String patientId, String appointmentId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Verify the caregiver's permission
      final appointmentDoc = await _firestore
          .collection('users')
          .doc(patientId)
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!appointmentDoc.exists) {
        throw Exception('Appointment not found');
      }

      if (appointmentDoc.data()?['caregiverId'] != currentUser.uid) {
        throw Exception('Not authorized to delete this appointment');
      }

      await _firestore
          .collection('users')
          .doc(patientId)
          .collection('appointments')
          .doc(appointmentId)
          .delete();
    } catch (e) {
      print('Error in deleteAppointment: $e');
      rethrow;
    }
  }
} 