// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 95, 112),
        title: Text(
          'My Appointments',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('appointments')
              .orderBy('dateTime', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading appointments',
                  style: GoogleFonts.poppins(),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final appointments = snapshot.data?.docs ?? [];
            if (appointments.isEmpty) {
              return Center(
                child: Text(
                  'No appointments found',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            }

            final now = DateTime.now();
            final upcomingAppointments = appointments.where((doc) {
              final date = (doc['dateTime'] as Timestamp).toDate();
              return date.isAfter(now);
            }).toList();

            final pastAppointments = appointments.where((doc) {
              final date = (doc['dateTime'] as Timestamp).toDate();
              return date.isBefore(now);
            }).toList();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (upcomingAppointments.isNotEmpty) ...[
                      _buildAppointmentsSection(
                        'Upcoming Appointments',
                        upcomingAppointments,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (pastAppointments.isNotEmpty)
                      _buildAppointmentsSection(
                        'Past Appointments',
                        pastAppointments,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection(String title, List<QueryDocumentSnapshot> appointments) {
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
            title,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 33, 95, 112),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...appointments.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Column(
              children: [
                _buildAppointmentItem(data),
                if (doc != appointments.last) const Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment) {
    final date = (appointment['dateTime'] as Timestamp).toDate();
    final formattedDate = _formatDate(date);
    final formattedTime = _formatTime(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Date/Time Column with colored background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 33, 95, 112),
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 33, 95, 112),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    appointment['title'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location with icon
                  if (appointment['location']?.isNotEmpty ?? false)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color.fromARGB(255, 33, 95, 112),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            appointment['location'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  // Description if available
                  if (appointment['description']?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              appointment['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateOnly == DateTime(tomorrow.year, tomorrow.month, tomorrow.day)) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}