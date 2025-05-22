// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_cubit/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  StreamSubscription<User?>? _userSubscription;
  bool isLoading = false;




  AuthCubit({required this.authService}) : super(AuthInitial()) {


    
    // Listen to authentication state changes
    _userSubscription = authService.user.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

String _parseError(String code) {
  switch(code) {
    case 'user-not-found': return 'Account not found';
    case 'wrong-password': return 'Invalid password';
    case 'user-disabled': return 'Account disabled';
    default: return 'Authentication failed';
  }
}
  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> signUpPatient({required String email,required String password}) async {
    emit(AuthLoading());
     isLoading = true;
    try {
  final user = await authService.signUpPatient(
    email: email,
    password: password,
  );
  
    isLoading = false;
  emit(Authenticated(user!));
  

  
} on FirebaseAuthException catch (e) {

          isLoading = false;
    emit(Unauthenticated(errorMessage: _parseError(e.code)));
  }
  }

  Future<void> signUpCaregiver({required String email,required String password,required String name}) async {
     emit(AuthLoading());
     isLoading = true;
    try {
  final user = await authService.signUpCaregiver(
    name: name,
    email: email,
    password: password,
  );
  if (user != null) {
                isLoading = false;
    emit(Authenticated(user));
  } else {
                isLoading = false;
    emit(Unauthenticated(
      errorMessage: 'Invalid caregiver credentials or account type'
    ));
  }
  

  
} on FirebaseAuthException catch (e) {

          isLoading = false;
    emit(Unauthenticated(errorMessage: _parseError(e.code)));
  }
  }
Future<void> signInPatient({required String email, required String password}) async {
    emit(AuthLoading());
                isLoading = true;

    try {
  final user = await authService.signInPatient(
    email: email,
    password: password,
  );
  if (user != null) {
                isLoading = false;

    emit(Authenticated(user));
  } else {
                    isLoading = false;

    emit(Unauthenticated(
      errorMessage: 'Invalid patient credentials or account type'
    ));
  }
} on FirebaseAuthException catch (errorMessage) {
            isLoading = false;
    emit(Unauthenticated(errorMessage: _parseError(errorMessage.code)));
  }
  }

  Future<void> signInCaregiver({required String email, required String password}) async {
    emit(AuthLoading());
         isLoading = true;

    try {
    final user = await authService.signInCaregiver(
      email: email,
      password: password,
    );
   if ( user != null) 
      {
        isLoading = false;
        emit(Authenticated(user));
        }
        else
        {
              isLoading = false;

emit(Unauthenticated(errorMessage: 'Invalid caregiver credentials'));
        }
  } on FirebaseAuthException catch (errorMessage) {
            isLoading = false;

    emit(Unauthenticated(errorMessage: _parseError(errorMessage.code)));
  }
  }


  Future<void> signOut() async {
    emit(AuthLoading());

    await authService.signOut();
    emit(AuthLoggedOut());
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    await authService.resetPassword(email: email);
    // Note: AuthService doesn't provide feedback, so errors can't be handled here.
  }

  Future<void> deleteAccount(String email, String password) async {
    emit(AuthLoading());
    await authService.deleteAccount(email: email, password: password);
  }

  Future<void> updateUsername(String displayName) async {
    emit(AuthLoading());
    await authService.updateUsername(displayName: displayName);
    // Refresh the authenticated state with updated user data
    if (authService.currentUser != null) {
      emit(Authenticated(authService.currentUser!));
    }
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    emit(AuthLoading());
    await authService.resetPasswordFromCurrentPassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      email: email,
    );
  }
}