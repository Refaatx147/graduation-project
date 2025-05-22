// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/link_users/link_users_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/link_users/link_users_state.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientQrScreen extends StatelessWidget {
  const PatientQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientCubit()..loadShareToken(),
      child: Scaffold(
        backgroundColor: const Color(0xffFFF9ED),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 33, 95, 112),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.qr_code, color: Color.fromARGB(255, 33, 95, 112)),
              ),
              const SizedBox(width: 12),
              Text(
                'QR Code',
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
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<PatientCubit>().loadShareToken();
          },
          
            child: SizedBox(
              height: MediaQuery.of(context).size.height - AppBar().preferredSize.height*2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<PatientCubit, PatientState>(
                      builder: (context, state) {
                        if (state is PatientLoaded) {
                          final sharedToken = state.shareToken;
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
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
                                child: QrImageView(
                                data: sharedToken,
                                version: QrVersions.auto,
                                size: 200.0,
                                  foregroundColor: const Color.fromARGB(255, 33, 95, 112),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 69, 163, 173).withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Share this QR code with caregiver',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      color: Color.fromARGB(255, 33, 95, 112),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildLinkedCaregiversSection(),
                            ],
                          );
                        } else if (state is PatientError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Error: ${state.message}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      color: Color.fromARGB(255, 33, 95, 112),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<PatientCubit>().loadShareToken();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 33, 95, 112),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is PatientLoading) {
                          return const CircularProgressIndicator(
                            color: Color.fromARGB(255, 33, 95, 112),
                          );
                        }
                        return Text(
                          'No QR code available',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 33, 95, 112),
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildLinkedCaregiversSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            'Linked Caregivers',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 33, 95, 112),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text(
                  'No caregivers linked yet',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final linkedCaregiverIds = List<String>.from(data['linkedCaregivers'] ?? []);

              if (linkedCaregiverIds.isEmpty) {
                return Text(
                  'No caregivers linked yet',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'caregiver')
                    .where(FieldPath.documentId, whereIn: linkedCaregiverIds)
                    .snapshots(),
                builder: (context, caregiverSnapshot) {
                  if (caregiverSnapshot.hasError) {
                    return const Text('Error loading caregivers');
                  }

                  if (caregiverSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final caregivers = caregiverSnapshot.data?.docs ?? [];

                  return Column(
                    children: caregivers.map((doc) {
                      final caregiverData = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 33, 95, 112),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caregiverData['name'] ?? 'Caregiver',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    caregiverData['email'] ?? '',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
