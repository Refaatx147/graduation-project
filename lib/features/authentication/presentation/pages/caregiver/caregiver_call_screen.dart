import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:grade_pro/core/constants/zego_constants.dart';

class CaregiverCallPage extends StatefulWidget {
  const CaregiverCallPage({Key? key}) : super(key: key);

  @override
  State<CaregiverCallPage> createState() => _CaregiverCallPageState();
}

class _CaregiverCallPageState extends State<CaregiverCallPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String? patientId;
  String? patientName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    if (currentUser != null) {
      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        setState(() {
          patientId = userData.data()?['linkedPatient'];
          patientName = userData.data()?['patientName'];
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startCall(bool isVideoCall) {
    if (patientId != null) {
      ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(patientId!, patientName ?? 'Patient')],
        isVideoCall: isVideoCall,
        resourceID: ZegoConstants.resourceID,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 33, 95, 112),
        ),
      );
    }

    if (currentUser == null) {
      return _buildErrorState(
        icon: Icons.error_outline,
        title: 'No user logged in',
        subtitle: 'Please log in to access this feature',
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (patientId != null) ...[
            _buildConnectedPatientView(),
          ] else ...[
            _buildNoPatientView(),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: const Color(0xff0D343F),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xff0D343F),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedPatientView() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 33, 95, 112).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 64,
            color: const Color(0xff0D343F),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connected to:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          patientName ?? 'Unknown Patient',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff0D343F),
          ),
        ),
        const SizedBox(height: 32),
        _buildCallButton(
          icon: Icons.videocam,
          label: 'Start Video Call',
          onPressed: () => _startCall(true),
        ),
        const SizedBox(height: 16),
        _buildCallButton(
          icon: Icons.call,
          label: 'Start Audio Call',
          onPressed: () => _startCall(false),
        ),
      ],
    );
  }

  Widget _buildNoPatientView() {
    return _buildErrorState(
      icon: Icons.person_off,
      title: 'No patient connected',
      subtitle: 'Please scan the patient\'s QR code first',
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D343F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 