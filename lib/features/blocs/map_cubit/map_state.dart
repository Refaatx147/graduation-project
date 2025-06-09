import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class MapState extends Equatable {
  final int activeArrowIndex; // 0: up, 1: right, 2: down, 3: left

  const MapState({
    this.activeArrowIndex = 0,
  });

  @override
  List<Object?> get props => [activeArrowIndex];
}

class MapInitial extends MapState {
  const MapInitial() : super();
}

class MapLoading extends MapState {
  const MapLoading() : super();
}

class MapError extends MapState {
  final String error;
  final bool isPermissionError;

  const MapError({
    required this.error,
    this.isPermissionError = false,
  }) : super();

  @override
  List<Object?> get props => [error, isPermissionError, activeArrowIndex];
}

class MapLoaded extends MapState {
  final LatLng currentLocation;
  final LatLng? destination;
  final double? distanceToDestination;
  final String? estimatedArrivalTime;
  final bool isNavigating;
  final bool isLocationUpdating;
  final String? patientName;
  final DateTime? lastLocationUpdate;

  const MapLoaded({
    required this.currentLocation,
    this.destination,
    this.distanceToDestination,
    this.estimatedArrivalTime,
    this.isNavigating = false,
    this.isLocationUpdating = false,
    this.patientName,
    this.lastLocationUpdate,
    int activeArrowIndex = 0,
  }) : super(activeArrowIndex: activeArrowIndex);

  MapLoaded copyWith({
    LatLng? currentLocation,
    LatLng? destination,
    double? distanceToDestination,
    String? estimatedArrivalTime,
    bool? isNavigating,
    bool? isLocationUpdating,
    String? patientName,
    DateTime? lastLocationUpdate,
    int? activeArrowIndex,
  }) {
    return MapLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      distanceToDestination: distanceToDestination ?? this.distanceToDestination,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      isNavigating: isNavigating ?? this.isNavigating,
      isLocationUpdating: isLocationUpdating ?? this.isLocationUpdating,
      patientName: patientName ?? this.patientName,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      activeArrowIndex: activeArrowIndex ?? this.activeArrowIndex,
    );
  }

  @override
  List<Object?> get props => [
        currentLocation,
        destination,
        distanceToDestination,
        estimatedArrivalTime,
        isNavigating,
        isLocationUpdating,
        patientName,
        lastLocationUpdate,
        activeArrowIndex,
      ];
}

class PatientLoaded extends MapState {
  final LatLng currentLocation;
  final LatLng? destination;
  final double? distanceToDestination;
  final String? estimatedArrivalTime;
  final bool isNavigating;

  const PatientLoaded({
    required this.currentLocation,
    this.destination,
    this.distanceToDestination,
    this.estimatedArrivalTime,
    this.isNavigating = false,
    int activeArrowIndex = 0,
  }) : super(activeArrowIndex: activeArrowIndex);

  PatientLoaded copyWith({
    LatLng? currentLocation,
    LatLng? destination,
    double? distanceToDestination,
    String? estimatedArrivalTime,
    bool? isNavigating,
    int? activeArrowIndex,
  }) {
    return PatientLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      distanceToDestination: distanceToDestination ?? this.distanceToDestination,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      isNavigating: isNavigating ?? this.isNavigating,
      activeArrowIndex: activeArrowIndex ?? this.activeArrowIndex,
    );
  }

  @override
  List<Object?> get props => [
        currentLocation,
        destination,
        distanceToDestination,
        estimatedArrivalTime,
        isNavigating,
        activeArrowIndex,
      ];
}

class CaregiverState extends MapState {
  final LatLng patientLocation;
  final LatLng? destination;
  final double? distanceToPatient;
  final String? patientName;
  final bool isTracking;

  const CaregiverState({
    required this.patientLocation,
    this.destination,
    this.distanceToPatient,
    this.patientName,
    this.isTracking = false,
    int activeArrowIndex = 0,
  }) : super(activeArrowIndex: activeArrowIndex);

  CaregiverState copyWith({
    LatLng? patientLocation,
    LatLng? destination,
    double? distanceToPatient,
    String? patientName,
    bool? isTracking,
    int? activeArrowIndex,
  }) {
    return CaregiverState(
      patientLocation: patientLocation ?? this.patientLocation,
      destination: destination ?? this.destination,
      distanceToPatient: distanceToPatient ?? this.distanceToPatient,
      patientName: patientName ?? this.patientName,
      isTracking: isTracking ?? this.isTracking,
      activeArrowIndex: activeArrowIndex ?? this.activeArrowIndex,
    );
  }

  @override
  List<Object?> get props => [
        patientLocation,
        destination,
        distanceToPatient,
        patientName,
        isTracking,
        activeArrowIndex,
      ];
}