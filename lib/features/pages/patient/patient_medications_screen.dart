// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientMedicationsScreen extends StatelessWidget {
  const PatientMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 95, 112),
        title: Text(
          'My Medications',
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
              .collection('medications')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading medications',
                  style: GoogleFonts.poppins(),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final medications = snapshot.data?.docs ?? [];

            if (medications.isEmpty) {
              return Center(
                child: Text(
                  'No medications found',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medications',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 33, 95, 112),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...medications.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            _buildMedicationItem(data),
                            if (doc != medications.last) const Divider(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    final List<Timestamp> times = List<Timestamp>.from(medication['times'] ?? []);
    final formattedTimes = times.map((time) {
      final dateTime = time.toDate();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medication Name Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medication_rounded,
                  color: Color.fromARGB(255, 33, 95, 112),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    medication['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 33, 95, 112),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dosage Section
                Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined, 
                      size: 20, 
                      color: Color.fromARGB(255, 33, 95, 112)
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dosage:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 33, 95, 112),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      medication['dosage'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Instructions Section (if available)
                if (medication['instructions']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            medication['instructions'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Times Section
                const SizedBox(height: 12),
                Text(
                  'Scheduled Times:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 33, 95, 112),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: formattedTimes.map((time) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color.fromARGB(255, 33, 95, 112),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 33, 95, 112),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}