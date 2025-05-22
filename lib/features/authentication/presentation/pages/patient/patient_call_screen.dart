import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:grade_pro/core/constants/zego_constants.dart';

class PatientCallPage extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

   PatientCallPage({super.key});

  String _generateRoomId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void _sendCallInvitation(String receiverId) {
    if (currentUserId == null) return;
    
    final callID = _generateRoomId(currentUserId!, receiverId);

    ZegoUIKitPrebuiltCallInvitationService().send(
      resourceID: ZegoConstants.resourceID,
      invitees: [ 
        ZegoCallUser(receiverId, 'Caregiver'),
      ],
      callID: callID,
      isVideoCall: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 33, 95, 112),
            ),
          );
        }

        List<String> linkedCaregivers =
            List<String>.from(snapshot.data?['linkedCaregivers'] ?? []);

        if (linkedCaregivers.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff0D343F).withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Color(0xff0D343F),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No linked caregivers found',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff0D343F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please wait for a caregiver to connect with you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xffFFF9ED),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // First Caregiver Card (Main)
              if (linkedCaregivers.isNotEmpty)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(linkedCaregivers[0])
                      .get(),
                  builder: (context, caregiverSnapshot) {
                    if (!caregiverSnapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 33, 95, 112),
                          ),
                        ),
                      );
                    }

                    var caregiverData =
                        caregiverSnapshot.data!.data() as Map<String, dynamic>;
                    return _CaregiverListItem(
                      onCallPressed: () => _sendCallInvitation(linkedCaregivers[0]),
                      name: caregiverData['name'] ?? 'Unknown',
                      role: caregiverData['role'] ?? 'Caregiver',
                      email: caregiverData['email'] ?? 'Unknown',
                    );
                  },
                ),
              // Additional Caregivers (if any)
              if (linkedCaregivers.length > 1)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xff0D343F).withAlpha(26),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Other Caregivers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff0D343F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        linkedCaregivers.length - 1,
                        (index) => FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(linkedCaregivers[index + 1])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            var data = snapshot.data!.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color.fromARGB(255, 33, 95, 112),
                                    radius: 18,
                                    child: Text(
                                      (data['name'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff0D343F),
                                          ),
                                        ),
                                        Text(
                                          data['role'] ?? 'Caregiver',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.video_call,
                                      color: Color.fromARGB(255, 52, 199, 114),
                                      size: 24,
                                    ),
                                    onPressed: () => _sendCallInvitation(linkedCaregivers[index + 1]),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CaregiverListItem extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final VoidCallback onCallPressed;

  const _CaregiverListItem({
    required this.onCallPressed,
    required this.name,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xff0D343F).withAlpha(26),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xff0D343F).withAlpha(26),
                ),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 33, 95, 112),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 33, 95, 112),
                    radius: 32,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name, Role, and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff0D343F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff0D343F).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xff0D343F).withAlpha(153),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Emergency and Record Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xff0D343F).withAlpha(26),
                ),
              ),
            ),
            child: Row(
              children: [
                // Emergency Call
                Expanded(
                  child: _ActionCard(
                    icon: Icons.emergency_outlined,
                    color: Colors.red,
                    title: 'Emergency Call',
                    description: 'Contact caregiver immediately in case of emergency',

                    onPressed: () {
                      // TODO: Implement emergency call
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Record Chat
                Expanded(
                  child: _ActionCard(
                    icon: Icons.record_voice_over_outlined,
                    color: const Color.fromARGB(255, 33, 95, 112),
                    title: 'Record Chat',
                    description: 'Record your conversation with the caregiver',
                    onPressed: () {
                      // TODO: Implement recording
                    },
                  ),
                ),
              ],
            ),
          ),
          // Call Options and History
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                // Call Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallButton(
                      icon: Icons.call,
                      label: 'Audio',
                      onPressed: () {
                        // TODO: Implement audio call
                      },
                    ),
                    const SizedBox(width: 20),
                    _CallButton(
                      icon: Icons.video_call,
                      label: 'Video',
                      onPressed: onCallPressed,
                    ),
                    const SizedBox(width: 20),
                    _CallButton(
                      icon: Icons.logout,
                      label: 'Logout',
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/user',
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error logging out. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Call History
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff0D343F).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xff0D343F).withAlpha(26),
                    ),
                  ),
                  child:SingleChildScrollView(
                   physics: AlwaysScrollableScrollPhysics(),
                    child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Color(0xff0D343F),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Call History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff0D343F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CallHistoryItem(
                        type: 'Video Call',
                        date: 'Today, 2:30 PM',
                        duration: '15:23',
                      ),
                      const Divider(height: 10),
                      _CallHistoryItem(
                        type: 'Audio Call',
                        date: 'Yesterday, 10:15 AM',
                        duration: '08:45',
                      ),
                    ],
                  ),
                ),
            )],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(51),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 52, 199, 114).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 52, 199, 114).withAlpha(51),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: const Color.fromARGB(255, 52, 199, 114),
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 52, 199, 114),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallHistoryItem extends StatelessWidget {
  final String type;
  final String date;
  final String duration;

  const _CallHistoryItem({
    required this.type,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          type == 'Video Call' ? Icons.video_call : Icons.call,
          size: 16,
          color: const Color(0xff0D343F),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff0D343F),
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Text(
          duration,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff0D343F),
          ),
        ),
      ],
    );
  }
} 