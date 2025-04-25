
import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  final String? errorMessage;
  Unauthenticated({this.errorMessage});
}

class AuthLoggedOut extends AuthState {}