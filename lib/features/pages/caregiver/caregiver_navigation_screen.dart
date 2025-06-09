// ignore_for_file: unused_local_variable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/services/call_service.dart';
import 'package:grade_pro/core/services/push_notifications.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_call_screen.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_profile.dart';
import 'package:grade_pro/features/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/pages/caregiver/map_caregiver_screen.dart';
import 'package:grade_pro/features/widgets/caregiver_app_bar.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/pages/caregiver_patient_management.dart';

class CaregiverNavigationScreen extends StatefulWidget {
  const CaregiverNavigationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CaregiverNavigationScreenState createState() => _CaregiverNavigationScreenState();
}

class _CaregiverNavigationScreenState extends State<CaregiverNavigationScreen> {
  int _currentPageIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? caregiverId = FirebaseAuth.instance.currentUser?.uid;
  String? patientId;
    bool _mounted = true; // Add this flag

  // Initialize _pages with default values
  late List<Widget> _pages = [
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
  ];

  String get _currentTitle {
    switch (_currentPageIndex) {
      case 0:
        return 'Scan Patient';
      case 1:
        return 'Contact Patient';
      case 2:
        return 'Patient Location';
      case 3:
        return 'Patient Management';
      case 4:
        return 'My Profile';
      default:
        return 'Caregiver Dashboard';
    }
  }

  IconData get _currentIcon {
    switch (_currentPageIndex) {
      case 0:
        return Icons.qr_code_scanner;
      case 1:
        return Icons.call;
      case 2:
        return Icons.location_on;
      case 3:
        return Icons.medical_services;
      case 4:
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeCallService();
    _initializeFCMToken();
  }


  Future<void> _initializeCallService() async {
    try {
      // Get user data from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverId)
          .get();
      
      final userName = userData.data()?['name'] ?? 'Caregiver';
      
      // Initialize call service with user data
      await CallService.initializeCallService();
    } catch (e) {
      print('Error initializing call service: $e');
    }
  }


 Future<void> _initializeFCMToken() async {
    if (!_mounted) return;
    await PushNotifications().getAndSaveFcmTokenToFirestore();
  }

  Future<void> _initializeData() async {
    if (!_mounted) return;
    
    try {
      final data = await FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverId)
          .get();
      
      if (!_mounted) return; // Check again after async operation
      
      setState(() {
        patientId = data.data()?['linkedPatient'];
        _pages = [
          const CaregiverScannerScreen(isInNavigation: true),
          const CaregiverCallPage(),
          MapCaregiverScreen(patientId: patientId ?? ''),
          const CaregiverPatientManagement(),
          const CaregiverProfileScreen(),
        ];
      });
    } catch (e) {
      print('Error initializing data: $e');
    }
  }
  @override
  void dispose() {
    _mounted=false;
    CallService.disposeCallService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: CaregiverAppBar(
        title: _currentTitle,
        leadingIcon: _currentIcon,
        onNotificationPressed: () {
          // Handle notifications
        },
      ),
      body: Center(child: _pages[_currentPageIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xff0D343F),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.qr_code_scanner,
                  label: "Scan",
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.call,
                  label: "Contact",
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.map,
                  label: "Map",
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.medical_services,
                  label: "Manage",
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: "Profile",
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentPageIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentPageIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 33, 95, 112) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withAlpha(153),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.white.withAlpha(153),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
