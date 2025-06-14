import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _isClosed = false;

  MapCubit({
    required this.userId,
    required this.isPatient,
    LocationService? locationService,
  })  : _locationService = locationService ?? LocationService(),
        super(const MapInitial()) {
    if (userId.isEmpty) {
      emit(const MapError(error: 'Invalid user ID'));
      return;
    }
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

      if (!userData.exists) {
        emit(const MapError(error: 'User not found'));
        return;
      }

      final patientName = userData.data()?['name'] as String?;

      if (isPatient) {
        // For patients, start location updates and get initial location
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
        // For caregivers, check if they are linked to a patient
        final caregiverData = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        if (!caregiverData.exists) {
          emit(const MapError(error: 'Caregiver not found'));
          return;
        }

        final linkedPatientId = caregiverData.data()?['linkedPatient'];
        
        if (linkedPatientId == null || linkedPatientId.isEmpty) {
          // If not linked to a patient, show caregiver's own location
          final position = await _locationService.getCurrentLocation();
          if (position == null) {
            throw Exception('Could not get current location. Please ensure location services are enabled.');
          }
          final currentLocation = LatLng(position.latitude, position.longitude);
          emit(MapLoaded(
            currentLocation: currentLocation,
            patientName: 'Your Location',
            lastLocationUpdate: DateTime.now(),
          ));
        } else {
          // If linked to a patient, listen to patient's location
          await _listenToPatientLocation();
          // Get initial patient location from Firestore
          final patientData = await FirebaseFirestore.instance
              .collection('users')
              .doc(linkedPatientId)
              .get();
          
          if (!patientData.exists) {
            emit(const MapError(error: 'Linked patient not found'));
            return;
          }

          final location = patientData.data()?['location'] as GeoPoint?;
          if (location == null) {
            throw Exception('Patient location not available. Please ensure the patient has shared their location.');
          }
          
          final currentLocation = LatLng(location.latitude, location.longitude);
          emit(MapLoaded(
            currentLocation: currentLocation,
            patientName: patientData.data()?['name'] as String?,
            lastLocationUpdate: DateTime.now(),
          ));
        }
      }

      // Listen for destination updates
      _listenToDestination();
    } catch (e) {
      print('Error in _initialize: $e');
      if (e.toString().contains('permission')) {
        emit(const MapError(
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
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get current location');
      }

      // Update initial location in Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
            'location': GeoPoint(position.latitude, position.longitude),
            'lastLocationUpdate': FieldValue.serverTimestamp(),
          });

      // Set up location stream
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
          timeLimit: Duration(seconds: 3), // Update every 3 seconds
        ),
      ).listen((Position position) async {
        try {
          // Update Firebase with new location
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
                'location': GeoPoint(position.latitude, position.longitude),
                'lastLocationUpdate': FieldValue.serverTimestamp(),
              });

          // Update state
          final currentLocation = LatLng(position.latitude, position.longitude);
          if (!_isClosed && state is MapLoaded) {
            final currentState = state as MapLoaded;
            emit(currentState.copyWith(
              currentLocation: currentLocation,
              isLocationUpdating: true,
              lastLocationUpdate: DateTime.now(),
            ));
          }

          print('Location updated in Firebase: ${position.latitude}, ${position.longitude}');
        } catch (e) {
          print('Error updating location in Firebase: $e');
        }
      });

    } catch (e) {
      print('Error in _startLocationUpdates: $e');
      emit(MapError(error: e.toString()));
    }
  }

  Future<void> _listenToPatientLocation() async {
    try {
      // First check if the caregiver is linked to a patient
      final caregiverData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      final linkedPatientId = caregiverData.data()?['linkedPatient'];
      
      if (linkedPatientId == null) {
        // If not linked to a patient, listen to caregiver's own location
        _locationSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            timeLimit: Duration(seconds: 3),
          ),
        ).listen((position) async {
          if (!_isClosed) {
            final currentLocation = LatLng(position.latitude, position.longitude);
            if (state is MapLoaded) {
              final currentState = state as MapLoaded;
              emit(currentState.copyWith(
                currentLocation: currentLocation,
                isLocationUpdating: true,
                lastLocationUpdate: DateTime.now(),
              ));
            } else {
              emit(MapLoaded(
                currentLocation: currentLocation,
                patientName: 'Your Location',
                isLocationUpdating: true,
                lastLocationUpdate: DateTime.now(),
              ));
            }
          }
        });
        return;
      }

      // If linked to a patient, listen to patient's location
      _locationSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(linkedPatientId)
          .snapshots()
          .listen((snapshot) {
        if (!snapshot.exists) return;

        final location = snapshot.data()?['location'] as GeoPoint?;
        final lastUpdate = snapshot.data()?['lastLocationUpdate'] as Timestamp?;
        
        if (location != null) {
          final currentLocation = LatLng(location.latitude, location.longitude);
          final patientName=snapshot.data()?['name'];
          if (!_isClosed) {
            if (state is MapLoaded) {
              final currentState = state as MapLoaded;
              emit(currentState.copyWith(
                patientName: patientName,
                currentLocation: currentLocation,
                isLocationUpdating: true,
                lastLocationUpdate: lastUpdate?.toDate() ?? DateTime.now(),
              ));
            } else {
              emit(MapLoaded(
                currentLocation: currentLocation,
                patientName: snapshot.data()?['name'] as String?,
                isLocationUpdating: true,
                lastLocationUpdate: lastUpdate?.toDate() ?? DateTime.now(),
              ));
            }
          }
          
          print('Received patient location update: ${location.latitude}, ${location.longitude}');
        }
      }, onError: (error) {
        print('Error listening to patient location: $error');
        if (!_isClosed) {
          emit(const MapError(error: 'Failed to get patient location updates'));
        }
      });

    } catch (e) {
      print('Error in _listenToPatientLocation: $e');
      if (!_isClosed) {
        emit(MapError(error: e.toString()));
      }
    }
  }

  void _handleLocationUpdate(LatLng location) {
    if (!_isClosed && state is MapLoaded) {  // Check if cubit is not closed
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        currentLocation: location,
        isLocationUpdating: true,
        lastLocationUpdate: DateTime.now(),
      ));
    } else {
      emit(MapLoaded(
        currentLocation: location,
        isLocationUpdating: true,
        lastLocationUpdate: DateTime.now(),
      ));
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
    try {
      emit(const MapLoading());
      
      if (isPatient) {
        await _startLocationUpdates();
      } else {
        // For caregivers, check if they are linked to a patient
        final caregiverData = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        final linkedPatientId = caregiverData.data()?['linkedPatient'];
        
        if (linkedPatientId == null) {
          // If not linked to a patient, get caregiver's own location
          final position = await _locationService.getCurrentLocation();
          if (position == null) {
            throw Exception('Could not get current location. Please ensure location services are enabled.');
          }
          final currentLocation = LatLng(position.latitude, position.longitude);

          emit(MapLoaded(
            currentLocation: currentLocation,
            patientName: ' Your Location',
            lastLocationUpdate: DateTime.now(),
          ));
        } else {
          // If linked to a patient, listen to patient's location
          await _listenToPatientLocation();
        }
      }
      
      _listenToDestination();
    } catch (e) {
      print('Error reloading data: $e');
      if (e.toString().contains('permission')) {
        emit(const MapError(
          error: 'Location permission not granted',
          isPermissionError: true,
        ));
      } else {
        emit(MapError(error: e.toString()));
      }
    }
  }

  void _startArrowRotation() {
    _arrowTimer?.cancel();
    _arrowTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!_isClosed && state is MapLoaded) {  // Check if cubit is not closed
        final currentState = state as MapLoaded;
        final nextIndex = (currentState.activeArrowIndex + 1) % 4;
        emit(currentState.copyWith(activeArrowIndex: nextIndex));
      }
    });
  }

  @override
  Future<void> close() async {
    _isClosed = true;  // Set flag before cleanup
    _arrowTimer?.cancel();
    await _locationSubscription?.cancel();
    await _destinationSubscription?.cancel();
    return super.close();
  }
}