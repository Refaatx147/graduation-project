// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:grade_pro/features/manage_patient_state/appointments/data/repositories/appointment_repository.dart';
import 'package:grade_pro/features/manage_patient_state/medications/data/repositories/medication_repository.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/providers/patient_data_provider.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/widgets/appointments_tab.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/widgets/medications_tab.dart';
import 'package:grade_pro/features/manage_patient_state/presentation/widgets/patient_management_tab_bar.dart';

class CaregiverPatientManagement extends StatefulWidget {
  const CaregiverPatientManagement({Key? key}) : super(key: key);

  @override
  State<CaregiverPatientManagement> createState() => _CaregiverPatientManagementState();
}

class _CaregiverPatientManagementState extends State<CaregiverPatientManagement> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _appointmentRepository = AppointmentRepository();
  final _medicationRepository = MedicationRepository();
  final _patientDataProvider = PatientDataProvider();
  String? patientId;
  String? patientName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    try {
      final data = await _patientDataProvider.loadPatientData();
      if (mounted) {
        setState(() {
          patientId = data['patientId'];
          patientName = data['patientName'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patient data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || patientId == null) {
      return const Scaffold(
        backgroundColor: Color(0xffFFF9ED),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff0D343F),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      body: Column(
        children: [
          PatientManagementTabBar(tabController: _tabController),
          Expanded(
            child: TabBarView(
              
              controller: _tabController,
              children: [
                AppointmentsTab(
                  patientId: patientId!,
                  appointmentRepository: _appointmentRepository,
                ),
                MedicationsTab(
                  patientId: patientId!,
                  medicationRepository: _medicationRepository,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}