// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_cubit.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/features/pages/patient/patient_appointments_screen.dart';
import 'package:grade_pro/features/pages/patient/patient_medications_screen.dart';

class HomePatient extends StatelessWidget {
  final UserAuthService authService;

  const HomePatient({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return BlocProvider(
      create: (context) => MapCubit(
        userId: currentUser?.uid ?? '',
        isPatient: true,
      ),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
    return Scaffold(
            backgroundColor: const Color(0xffFFF9ED),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 33, 95, 112),
              title: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color.fromARGB(255, 33, 95, 112)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Text(
                        state is MapLoaded ? state.patientName ?? 'Patient' : 'Patient',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Handle notifications
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              
                child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildHealthOverview(),
                    ],
                  ),
                ),
              ),
          
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 33, 95, 112),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.emergency,
                label: 'Emergency',
                color: Colors.red,
                onTap: () {
                  // Handle emergency
                },
              ),
              _buildActionButton(
                icon: Icons.medical_services,
                label: 'Medications',
                color: const Color.fromARGB(255, 33, 95, 112),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientMedicationsScreen(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.calendar_today,
                label: 'Appointments',
              
                color: const Color.fromARGB(255, 33, 95, 112),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientAppointmentsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color color,
    required String trend,
  }) {
    return Card(

      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
        child: Column(
          

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(


              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 24, color: iconColor),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+')
                        ? Colors.green.withOpacity(0.1)
                        : trend.startsWith('-')
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trend.startsWith('+')
                          ? Colors.green
                          : trend.startsWith('-')
                              ? Colors.red
                              : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
     ) );
  }

  Widget _buildHealthOverview() {
    return Container(
      height: 480,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(

          color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.2),
          width: 1.5,
          
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 33, 95, 112),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.9,
            
            children: [
              _buildHealthCard(
                icon: Icons.favorite,
                iconColor: const Color.fromARGB(255, 247, 15, 11),
                title: 'HEART RATE',
                value: '120 bpm',
                color: const Color.fromARGB(255, 91, 166, 162),
                trend: '+5',
              ),
              _buildHealthCard(
                iconColor: const Color.fromARGB(255, 30, 150, 183),
                icon: Icons.opacity,
                title: 'BLOOD PRESSURE',
                value: '120/80',
                color: const Color.fromARGB(255, 91, 166, 162),
                trend: '-2',
              ),
              _buildHealthCard(
                iconColor: const Color.fromARGB(255, 116, 209, 73),
                icon: Icons.thermostat,
                title: 'TEMPERATURE',
                value: '36.5°C',
                color: const Color.fromARGB(255, 91, 166, 162),
                trend: '0',
              ),
              _buildHealthCard(
                iconColor: const Color.fromARGB(255, 248, 175, 41),
                icon: Icons.show_chart,
                title: 'BLOOD SUGAR',
                value: '98 mg/dL',
                color: const Color.fromARGB(255, 91, 166, 162),
                trend: '-3',
              ),
            ],
          ),
        ],
      ),
    );
  }
}



