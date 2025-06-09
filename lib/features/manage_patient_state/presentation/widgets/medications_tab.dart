// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/manage_patient_state/medications/domain/models/medication.dart';
import 'package:grade_pro/features/manage_patient_state/medications/data/repositories/medication_repository.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/dialogs/medication_dialog.dart';

class MedicationsTab extends StatefulWidget {
  final String patientId;
  final MedicationRepository medicationRepository;

  const MedicationsTab({
    Key? key,
    required this.patientId,
    required this.medicationRepository,
  }) : super(key: key);

  @override
  State<MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends State<MedicationsTab> {
  Future<void> _addMedication() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const MedicationDialog(),
    );

    if (result != null) {
      final medication = Medication(
        id: '', // Will be set by Firestore
        patientId: widget.patientId,
        caregiverId: '', // Will be set by repository
        name: result['name'],
        dosage: result['dosage'],
        instructions: result['instructions'],
        times: result['times'],
      );

      try {
        await widget.medicationRepository.addMedication(medication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Medication added successfully',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xff0D343F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error: ${e.toString()}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Medication>>(
      stream: widget.medicationRepository.getPatientMedicationsStream(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.red[300],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff0D343F),
            ),
          );
        }

        final medications = snapshot.data!;

        if (medications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff0D343F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    size: 48,
                    color: Color(0xff0D343F),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No medications yet',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Color(0xff0D343F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add medications to keep track of prescriptions',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addMedication,
                  icon: const Icon(Icons.add, color: Color.fromARGB(255, 67, 255, 192)),
                  label: const Text('Add Medication'),
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: medications.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: _addMedication,
                  icon: const Icon(Icons.add, color: Color.fromARGB(255, 67, 255, 192)),
                  label: const Text('Add Medication'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0D343F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }

            final medication = medications[index - 1];
            return Card(
              color: const Color.fromARGB(255, 255, 255, 255),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            medication.name,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff0D343F),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_alarm, color: Color(0xff0D343F)),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xff0D343F),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                final now = DateTime.now();
                                final dateTime = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  time.hour,
                                  time.minute,
                                );
                                medication.times.add(dateTime);
                              });
                              try {
                                await widget.medicationRepository.updateMedication(medication);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            try {
                              await widget.medicationRepository.deleteMedication(widget.patientId, medication.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Medication deleted successfully')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.scale, size: 16, color: Color(0xff0D343F)),
                        const SizedBox(width: 8),
                        Text(
                          'Dosage: ${medication.dosage}',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xff0D343F),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (medication.instructions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xff0D343F)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Instructions: ${medication.instructions}',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xff0D343F),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Times',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff0D343F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...medication.times.map((time) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xff0D343F)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time, color: Color(0xff0D343F), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            color: Color(0xff0D343F),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (medication.times.length > 1) ...[
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              medication.times.remove(time);
                                            });
                                            try {
                                              await widget.medicationRepository.updateMedication(medication);
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                                );
                                              }
                                            }
                                          },
                                          child: const Icon(Icons.close, color: Color(0xff0D343F), size: 16),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 