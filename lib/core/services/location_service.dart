// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startLocationUpdates() async {
    if (!await requestLocationPermission()) {
      throw Exception('Location permission not granted');
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) async {
      await _updateLocationInFirestore(position);
    });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    final userId = _auth.currentUser?.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final data = await firestore.collection('users').doc(userId).get();

    final linkedPatientId = data.data()?['linkedPatient'] as String?;
    if (linkedPatientId != null) {
      await _firestore.collection('users').doc(linkedPatientId).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
    }
  }

  Future<void> stopLocationUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied. Please grant location permission to use this feature.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied. Please enable location permission in settings.');
      }

      return await Geolocator.getCurrentPosition(
        
       locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Stream<LatLng?> getPatientLocationStream(String patientId) {
    return _firestore
        .collection('users')
        .doc(patientId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          
          final location = doc.data()?['location'] as GeoPoint?;
          if (location == null) return null;
          
          print('New patient location received: ${location.latitude}, ${location.longitude}');
          return LatLng(location.latitude, location.longitude);
        })
        .handleError((error) {
          print('Error in patient location stream: $error');
          return null;
        });
  }

  Future<void> setDestinationForPatient(String caregiverId, LatLng destination) async {
     final userId = _auth.currentUser?.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final data = await firestore.collection('users').doc(userId).get();

    final linkedPatientId = data.data()?['linkedPatient'] as String?;
    if (linkedPatientId != null) {
      await _firestore.collection('users').doc(linkedPatientId).update({
        'destination': GeoPoint(destination.latitude, destination.longitude),
        'destinationSetAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> clearDestinationForPatient(String patientId) async {
    await _firestore.collection('users').doc(patientId).update({
      'destination': FieldValue.delete(),
      'destinationSetAt': FieldValue.delete(),
    });
  }
}