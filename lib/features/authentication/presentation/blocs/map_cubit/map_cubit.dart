import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:grade_pro/core/services/location_service.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final LocationService _locationService;
  final String userId;
  final bool isPatient;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _destinationSubscription;
  Timer? _arrowTimer;

  MapCubit({
    required this.userId,
    required this.isPatient,
    LocationService? locationService,
  })  : _locationService = locationService ?? LocationService(),
        super(const MapInitial()) {
    _initialize();
    _startArrowRotation();
  }

  Future<void> _initialize() async {
    try {
      emit(const MapLoading());

      // Get user data
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final patientName = userData.data()?['name'] as String?;

      if (isPatient) {
        // For patients, start location updates and get initial location
        await _startLocationUpdates();
        final position = await _locationService.getCurrentLocation();
        if (position == null) {
          throw Exception('Could not get current location. Please ensure location services are enabled.');
        }
        final currentLocation = LatLng(position.latitude, position.longitude);
        emit(MapLoaded(
          currentLocation: currentLocation,
          patientName: patientName,
          lastLocationUpdate: DateTime.now(),
        ));
      } else {
        // For caregivers, only listen to patient location
        await _listenToPatientLocation();
        // Get initial patient location from Firestore
        final patientData = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        final location = patientData.data()?['location'] as GeoPoint?;
        if (location == null) {
          throw Exception('Patient location not available. Please ensure the patient has shared their location.');
        }
        
        final currentLocation = LatLng(location.latitude, location.longitude);
        emit(MapLoaded(
          currentLocation: currentLocation,
          patientName: patientName,
          lastLocationUpdate: DateTime.now(),
        ));
      }

      // Listen for destination updates
      _listenToDestination();
    } catch (e) {
      if (e.toString().contains('permission')) {
        emit(MapError(
          error: 'Location permission not granted',
          isPermissionError: true,
        ));
      } else {
        emit(MapError(error: e.toString()));
      }
    }
  }

  Future<void> _startLocationUpdates() async {
    try {
      await _locationService.startLocationUpdates();
      _locationSubscription = _locationService
          .getPatientLocationStream(userId)
          .listen(_handleLocationUpdate);
    } catch (e) {
      emit(MapError(error: e.toString()));
    }
  }

  Future<void> _listenToPatientLocation() async {
    try {
      _locationSubscription = _locationService
          .getPatientLocationStream(userId)
          .listen(_handleLocationUpdate);
    } catch (e) {
      emit(MapError(error: e.toString()));
    }
  }

  void _handleLocationUpdate(LatLng? location) {
    if (location == null) return;

    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        currentLocation: location,
        isLocationUpdating: true,
        lastLocationUpdate: DateTime.now(),
      ));

      // Calculate distance and ETA if there's a destination
      if (currentState.destination != null) {
        _calculateRouteInfo(location, currentState.destination!);
      }
    }
  }

  void _listenToDestination() {
    _destinationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((doc) {
      final destination = doc.data()?['destination'] as GeoPoint?;
      if (destination != null) {
        _handleDestinationUpdate(
          LatLng(destination.latitude, destination.longitude),
        );
      } else {
        _clearDestination();
      }
    });
  }

  void _handleDestinationUpdate(LatLng destination) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        destination: destination,
        isNavigating: true,
      ));

      // Calculate distance and ETA
      _calculateRouteInfo(currentState.currentLocation, destination);
    }
  }

  void _calculateRouteInfo(LatLng start, LatLng end) {
    final distance = const Distance().distance(start, end) / 1000; // Convert to km
    final estimatedTime = _calculateEstimatedTime(distance);

    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        distanceToDestination: distance,
        estimatedArrivalTime: estimatedTime,
      ));
    }
  }

  String _calculateEstimatedTime(double distanceInKm) {
    // Assuming average walking speed of 5 km/h
    const averageSpeed = 5.0;
    final hours = distanceInKm / averageSpeed;
    final minutes = (hours * 60).round();

    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '$hours hours ${remainingMinutes > 0 ? '$remainingMinutes minutes' : ''}';
    }
  }

  Future<void> setDestination(LatLng destination) async {
    try {
      await _locationService.setDestinationForPatient(userId, destination);
    } catch (e) {
      emit(MapError(error: e.toString()));
    }
  }

  Future<void> clearDestination() async {
    try {
      await _locationService.clearDestinationForPatient(userId);
      _clearDestination();
    } catch (e) {
      emit(MapError(error: e.toString()));
    }
  }

  void _clearDestination() {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        destination: null,
        distanceToDestination: null,
        estimatedArrivalTime: null,
        isNavigating: false,
      ));
    }
  }

  Future<void> reloadData() async {
    await _initialize();
  }

  void _startArrowRotation() {
    _arrowTimer?.cancel();
    _arrowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (state is MapLoaded) {
        final currentState = state as MapLoaded;
        final nextIndex = (currentState.activeArrowIndex + 1) % 4;
        emit(currentState.copyWith(activeArrowIndex: nextIndex));
      }
    });
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _destinationSubscription?.cancel();
    _arrowTimer?.cancel();
    return super.close();
  }
}