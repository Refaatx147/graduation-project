// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientManagementTabBar extends StatelessWidget {
  final TabController tabController;

  const PatientManagementTabBar({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  double _responsiveFontSize(BuildContext context, double baseSize) {
    return MediaQuery.of(context).size.width * (baseSize / 450.0); // Base on Samsung A52 width
  }

  double _responsiveIconSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.045;
  }

  double _responsivePadding(BuildContext context, double baseSize) {
    return MediaQuery.of(context).size.width * (baseSize / 360.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07, // 7% of screen height
      padding: EdgeInsets.symmetric(horizontal: _responsivePadding(context, 16)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 168, 167, 166).withOpacity(0.2),
            width: 3,
          ),
        ),
      ),
      child: TabBar(
        automaticIndicatorColorAdjustment: true,
        enableFeedback: true,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        controller: tabController,
        labelColor: const Color(0xff0D343F),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xff0D343F),
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.poppins(
          fontSize: _responsiveFontSize(context, 14),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: _responsiveFontSize(context, 14),
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: _responsiveIconSize(context),
                ),
                SizedBox(width: _responsivePadding(context, 8)),
                Text(
                  'Appointments',
                  style: GoogleFonts.poppins(
                    fontSize: _responsiveFontSize(context, 15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication,
                  size: _responsiveIconSize(context),
                ),
                SizedBox(width: _responsivePadding(context, 8)),
                Text(
                  'Medications',
                  style: GoogleFonts.poppins(
                    fontSize: _responsiveFontSize(context, 15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 