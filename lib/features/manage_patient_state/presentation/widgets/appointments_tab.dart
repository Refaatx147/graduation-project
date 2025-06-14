// ignore_for_file: unnecessary_string_interpolations, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/manage_patient_state/appointments/data/repositories/appointment_repository.dart';
import 'package:grade_pro/features/manage_patient_state/appointments/domain/models/appointment.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/dialogs/appointment_dialog.dart';
import 'package:intl/intl.dart';

class AppointmentsTab extends StatefulWidget {
  final String patientId;
  final AppointmentRepository appointmentRepository;

  const AppointmentsTab({
    Key? key,
    required this.patientId,
    required this.appointmentRepository,
  }) : super(key: key);

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  @override

  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Appointment>>(
            stream: widget.appointmentRepository.getPatientAppointmentsStream(widget.patientId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState('Error loading appointments');
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xff0D343F)),
                );
              }

              final appointments = snapshot.data!;

              if (appointments.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  // Add Button for when there are appointments
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7, top: 14, left: 16, right: 16, ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addAppointment,
                        icon: const Icon(Icons.add, color: Color.fromARGB(255, 67, 255, 192)),
                        label: const Text('Add Appointment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0D343F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Appointments List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        return _buildAppointmentCard(appointments[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addAppointment() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppointmentDialog(patientId: widget.patientId),
    );

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Row(
            children: [
               const Icon(Icons.check_circle, color: Colors.white),
               const SizedBox(width: 8),
                Text(
                'Appointment added successfully',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xff34C772),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff0D343F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xff0D343F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0D343F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (appointment.description.isNotEmpty) ...[
                        Text(
                          appointment.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff0D343F).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xff0D343F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dateFormat.format(appointment.dateTime)} at ${timeFormat.format(appointment.dateTime)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xff0D343F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff0D343F).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xff0D343F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.location,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xff0D343F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 89,
            color: Color.fromARGB(255, 8, 52, 66),
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments yet',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap + to add a new appointment',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addAppointment,
            icon: const Icon(Icons.add, color: Color.fromARGB(255, 67, 255, 192)),
            label: const Text('Add Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0D343F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}