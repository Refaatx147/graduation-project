// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_pro/features/chat/presentation/pages/caregiver_chat_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:grade_pro/core/constants/zego_constants.dart';
import 'package:grade_pro/features/call/data/repositories/call_repository.dart';
import 'package:grade_pro/features/call/presentation/cubit/call_cubit.dart';
import 'package:grade_pro/features/call/presentation/widgets/call_history_list.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverCallPage extends StatefulWidget {
  const CaregiverCallPage({Key? key}) : super(key: key);

  @override
  State<CaregiverCallPage> createState() => _CaregiverCallPageState();
}

class _CaregiverCallPageState extends State<CaregiverCallPage> {
  late final CallCubit _callCubit;
  final currentUser = FirebaseAuth.instance.currentUser;
  String? patientId;
  String? patientName;
  bool isLoading = true;
  bool isCallActive = false;
  DateTime? callStartTime;
  bool isVideoCall = false;
  bool _isNavigating = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _callCubit = CallCubit(callRepository: CallRepository());
    _callCubit.loadCallHistory();
    _loadPatientData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (!_isNavigating) {
      if (isCallActive) {
        _cleanupCall();
      }
      _callCubit.close();
    }
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    if (_isDisposed) return;
    
    if (currentUser != null) {
      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        if (!_isDisposed) {
          setState(() {
            patientId = userData.data()?['linkedPatient'];
            patientName = userData.data()?['patientName'];
            isLoading = false;
          });
        }
      } catch (e) {
        if (!_isDisposed) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (!_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startCall(bool isVideo) {
    if (patientId != null) {
      setState(() {
        isCallActive = true;
        isVideoCall = isVideo;
        // Don't set callStartTime here - wait for actual connection
      });
      
      ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(patientId!, patientName ?? 'Patient')],
        isVideoCall: isVideo,
        resourceID: ZegoConstants.resourceID,
      ).then((_) {
        // Set callStartTime only when call is actually connected
        setState(() {
          callStartTime = DateTime.now();
        });
      }).catchError((error) {
        if (mounted) {
          setState(() {
            isCallActive = false;
            callStartTime = null;
          });
        }
      });
    }
  }

  void _cleanupCall() async {
    if (patientId != null && patientName != null) {
      int duration = 0;
      if (callStartTime != null) {
        duration = DateTime.now().difference(callStartTime!).inSeconds;
      }
      
      try {
        // First save to Firebase and wait for it to complete
        await _callCubit.saveCallHistory(
          receiverId: patientId!,
          receiverName: patientName!,
          isVideoCall: isVideoCall,
          duration: duration,
          status: 'completed',
        );
        
        
        // Only update UI after Firebase save is complete
        if (mounted) {
          setState(() {
            isCallActive = false;
            callStartTime = null;
          });
          
          // Force immediate refresh of call history
          await _callCubit.loadCallHistory();
          
          // Notify parent widget to rebuild
          if (mounted) {
            setState(() {});
          }
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            isCallActive = false;
            callStartTime = null;
          });
        }
      }
    } else {
      setState(() {
        isCallActive = false;
        callStartTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff0D343F),
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

    return WillPopScope(
      onWillPop: () async {
        _isNavigating = true;
        return true;
      },
      child: BlocProvider.value(
        value: _callCubit,
        child: BlocConsumer<CallCubit, CallState>(
          listener: (context, state) {
            if (state is CallHistoryLoaded) {
              setState(() {});
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                ),
 const  Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child:  CallHistoryList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectedPatientView() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 225, 244, 230).withAlpha(26),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(255, 28, 92, 94).withAlpha(160),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 64,
                color: Color(0xff0D343F),
              ),
              if (isCallActive)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connected to:',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          patientName ?? 'Unknown Patient',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xff0D343F),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCallButton(
              icon: Icons.videocam,
              label: 'Video Call',
              onPressed: () => _startCall(true),
              isVideo: true,
            ),
            const SizedBox(width: 16),
            _buildCallButton(
              icon: Icons.call,
              label: 'Audio Call',
              onPressed: () => _startCall(false),
              isVideo: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChatButton(),
        const SizedBox(height: 16),
        _buildScheduleNotificationButton(),
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

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff0D343F).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: const Color(0xff0D343F),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
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
            subtitle,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isVideo,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isVideo ? const Color(0xff0D343F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff0D343F),
          width: isVideo ? 0 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isVideo ? Colors.white : const Color(0xff0D343F),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isVideo ? Colors.white : const Color(0xff0D343F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff0D343F),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (patientId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaregiverChatScreen(
                    patientId: patientId!,
                    patientName: patientName ?? 'Unknown Patient',
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat,
                  color: Color(0xff0D343F),
                ),
                const SizedBox(width: 8),
                Text(
                  'Chat',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0D343F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleNotificationButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff0D343F),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showScheduleNotificationDialog(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Color(0xff0D343F),
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule Notification',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0D343F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showScheduleNotificationDialog() async {
    final TextEditingController titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Schedule Notification',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff0D343F),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Notification Title',
                    labelStyle: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Color(0xff0D343F),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Select Date',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    'Select Time',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Color(0xff0D343F),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0D343F),
              ),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final scheduledDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  
                  await _scheduleNotification(
                    title: titleController.text,
                    scheduledTime: scheduledDateTime,
                  );
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notification scheduled successfully',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Schedule',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scheduleNotification({
    required String title,
    required DateTime scheduledTime,
  }) async {
    if (patientId == null) return;

    try {
      // Save the scheduled notification to Firestore
      await FirebaseFirestore.instance
          .collection('scheduledNotifications')
          .add({
            'caregiverId': currentUser!.uid,
            'patientId': patientId,
            'title': title,
            'scheduledTime': scheduledTime,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }
}