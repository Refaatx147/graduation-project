import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/core/services/call_service.dart';
import 'package:grade_pro/features/authentication/presentation/pages/call_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_profile.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/authentication/presentation/pages/caregiver/map_caregiver_screen.dart';

class CaregiverNavigationScreen extends StatefulWidget {
  @override
  _CaregiverNavigationScreenState createState() => _CaregiverNavigationScreenState();
}

class _CaregiverNavigationScreenState extends State<CaregiverNavigationScreen> {
  int _currentPageIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? caregiverId = FirebaseAuth.instance.currentUser?.uid;
  String? patientId;
  
  // Initialize _pages with default values
  late List<Widget> _pages = [
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
    const Center(child: CircularProgressIndicator()),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeCallService();
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

  Future<void> _initializeData() async {
    try {
      final data = await FirebaseFirestore.instance.collection('users').doc(caregiverId).get();
      setState(() {
        patientId = data.data()?['linkedPatient'];
        _pages = [
          CaregiverScannerScreen(isInNavigation: true),
          CallPage(isPatient: false),
          MapCaregiverScreen(patientId: patientId ?? ''),
          CaregiverProfileScreen()
        ];
      });
    } catch (e) {
      print('Error initializing data: $e');
      // Keep the default loading indicators if there's an error
    }
  }

  Future<void> _logout() async {
    try {
      CallService.disposeCallService();
      await auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/user-select');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    CallService.disposeCallService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0D343F),
        title: Text(
          'Caregiver Dashboard',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(child: _pages[_currentPageIndex]),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Color(0xFFE8F0FE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton("Scan", 0, Icons.qr_code_scanner),
            _navButton("Call", 1, Icons.call),
            _navButton("Map", 2, Icons.map),
            _navButton("Profile", 3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String label, int index, IconData icon) {
    final isSelected = _currentPageIndex == index;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color.fromARGB(255, 10, 62, 76) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color.fromARGB(221, 20, 35, 50),
        elevation: isSelected ? 4 : 1,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        setState(() {
          _currentPageIndex = index;
        });
      },
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
