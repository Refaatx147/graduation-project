// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AuthService{

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? get currentUser => firebaseAuth.currentUser;

 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<User?> get user => firebaseAuth.authStateChanges();








Future<User?> signUpPatient({required String email,required String password}) async {
    try {
      UserCredential credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create patient document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'role': 'patient',
        'shareToken': _uuid.v4(),
        'createdAt': FieldValue.serverTimestamp(),
        'linkedCaregivers':[], 
      });
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }



 Future<User?> signUpCaregiver({required String email,required String password,required String name}) async {
    try {
      UserCredential credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,

      );
            // Create caregiver document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name':name,
        'role': 'caregiver',
        'linkedPatient': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return credential.user;

    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

 Future<User?> signInPatient({required String email, required String password}) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify patient role
      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (doc.exists && doc.data()?['role'] == 'patient') {
        return credential.user;
      }
      
      // If not a patient, sign out and return null
      await signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      print('Patient login error: ${e.message}');
      return null;
    }
  }

  Future<User?> signInCaregiver({required String email, required String password}) async {
    try {
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify caregiver role
      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (doc.exists && doc.data()?['role'] != 'caregiver') {
                      await signOut();

return null;
      }
      
      // If not a caregiver, sign out and return null
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Caregiver login error: ${e.message}');
      return null;
    }
  }


 Future<String?> getUserRole() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc['role'];
    }
    return null;
  }






  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error sending password reset email: $e");
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
          AuthCredential authCredential=EmailAuthProvider.credential(email: email, password: password);
      await currentUser?.reauthenticateWithCredential(authCredential);
      await currentUser?.delete();
      await firebaseAuth.signOut();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  Future<void> updateUsername({required String displayName}) async {
    try {
      await firebaseAuth.currentUser!.updateDisplayName( displayName);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }


  Future<void> resetPasswordFromCurrentPassword({required String currentPassword,required String newPassword,required String email}) async {
    try {
                AuthCredential authCredential=EmailAuthProvider.credential(email: email, password: currentPassword);
                      await currentUser?.reauthenticateWithCredential(authCredential);
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      print("Error sending password reset email: $e");
    }
  }

  
      Future<bool> isLoggedIn() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }
}