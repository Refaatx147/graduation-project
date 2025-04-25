import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/call_screen.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/caregiver/caregiver_profile.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/caregiver/caregiver_scanner_screen.dart';
import 'package:grade_pro/features/patient_authentication/presentation/pages/caregiver/map_caregiver.dart';

class CaregiverNavigationScreen extends StatefulWidget {
  @override
  _CaregiverNavigationScreenState createState() => _CaregiverNavigationScreenState();
}

class _CaregiverNavigationScreenState extends State<CaregiverNavigationScreen> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
  CaregiverScannerScreen(),
  CaregiverCallPage()
  ,MapScreen(),
CaregiverProfileScreen()

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية متناسق
      body: Center(child: _pages[_currentPageIndex]),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Color(0xFFE8F0FE), // لون هادي وأنيق متناسق مع الواجهة
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton("Scan", 0, Icons.scanner),
            _navButton("Map", 1, Icons.call),
            _navButton("Call", 2, Icons.map),
            _navButton("Settings", 3, Icons.photo_filter),
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
