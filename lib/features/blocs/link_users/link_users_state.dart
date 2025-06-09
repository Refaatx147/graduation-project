abstract class PatientState {}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final String shareToken;
  PatientLoaded({required this.shareToken});
}

class PatientError extends PatientState {
  final String message;
  PatientError({required this.message});
}


abstract class CaregiverState {}

class CaregiverInitial extends CaregiverState {}

class CaregiverLinking extends CaregiverState {}

class CaregiverLinked extends CaregiverState {
  final String patientId;
  CaregiverLinked({required this.patientId});
}

class CaregiverError extends CaregiverState {
  final String message;
  CaregiverError({required this.message});
}