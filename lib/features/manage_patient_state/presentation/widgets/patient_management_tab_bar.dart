// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientManagementTabBar extends StatelessWidget {
  final TabController tabController;

  const PatientManagementTabBar({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        controller: tabController,
        labelColor: const Color(0xff0D343F),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xff0D343F),
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorAnimation: TabIndicatorAnimation.elastic,
        labelStyle: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_note, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Appointments',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.medication, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Medications',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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