// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// Unique call ID
String generateRoomId(String user1, String user2) {
  final sorted = [user1, user2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

class CallPage extends StatefulWidget {
  final bool isPatient;

  const CallPage({super.key, required this.isPatient});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();

    if (currentUserId != null) {
      ZegoUIKitPrebuiltCallInvitationService().init(
        notificationConfig: ZegoCallInvitationNotificationConfig(
  androidNotificationConfig: ZegoCallAndroidNotificationConfig(
    callIDVisibility: true,
    showFullScreen: true,
    
    callChannel: ZegoCallAndroidNotificationChannelConfig(vibrate: true),
  ),
),
        appID: 1417893468,
        appSign:
            '24422e49f6e8d6e106f5d840f96b247dee62e5832d54d462e568075c4ef4b3e4',
        userID: currentUserId!,
        userName: widget.isPatient ? 'mohamed' : 'ahmed',
        plugins: [ZegoUIKitSignalingPlugin()],

      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPatient ? 'My Caregivers' : 'My Patients'),
      ),
      body: widget.isPatient ? PatientCallPage() : CaregiverCallPage(),
    );
  }
}

class PatientCallPage extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  PatientCallPage({super.key});

  void sendCallInvitation(String receiverId) async{
    final callID = generateRoomId(currentUserId!, receiverId);
            //    String? name =  await  FirebaseFirestore.instance.collection('users').doc(currentUserId).get().then((snapshot) => snapshot['name']);

    ZegoUIKitPrebuiltCallInvitationService().send(
      resourceID: 'GradeProject',
      
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
          return const Center(child: CircularProgressIndicator());
        }

        List<String> linkedCaregivers =
            List<String>.from(snapshot.data?['linkedCaregivers'] ?? []);

        if (linkedCaregivers.isEmpty) {
          return const Center(child: Text('No linked caregivers found'));
        }

        return ListView.builder(
          itemCount: linkedCaregivers.length,
          itemBuilder: (context, index) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(linkedCaregivers[index])
                  .get(),
              builder: (context, caregiverSnapshot) {
                if (!caregiverSnapshot.hasData) {
                  return Center(
                    child: 
                      Text('loading', textAlign: TextAlign.center, style: TextStyle(fontSize: 17,color: Color.fromARGB(255, 8, 44, 54),),),
                  
                  );
                }

                var caregiverData =
                    caregiverSnapshot.data!.data() as Map<String, dynamic>;
                return _UserListItem(
                  onCallPressed: () =>
                      sendCallInvitation(linkedCaregivers[index]),
                  name: caregiverData['name'],
                  role: caregiverData['role'],
                );
              },
            );
          },
        );
      },
    );
  }
}

class CaregiverCallPage extends StatelessWidget {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  CaregiverCallPage({super.key});

  void sendCallInvitation(String receiverId) async{
    final callID = generateRoomId(currentUserId!, receiverId);
         //   String name =  await  FirebaseFirestore.instance.collection('users').doc(currentUserId).get().then((snapshot) => snapshot['name']);

    ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ 
          
          ZegoCallUser(receiverId,
        'Patient',
     ) ],
        callID: callID,
        isVideoCall: true,
      resourceID: 'GradeProject',

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
          return const Center(child: CircularProgressIndicator());
        }

        String linkedPatient = snapshot.data?['linkedPatient'] ?? '';

        if (linkedPatient.isEmpty) {
          return const Center(child: Text('No linked patients found'));
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(linkedPatient)
              .get(),
          builder: (context, patientSnapshot) {
            if (!patientSnapshot.hasData) {
              return const ListTile(
                leading: CircularProgressIndicator(),
              );
            }

            var patientData =
                patientSnapshot.data!.data() as Map<String, dynamic>;

            return _UserListItem(
              onCallPressed: () => sendCallInvitation(linkedPatient),
              name: patientData['name'] ?? 'Patient',
              role: patientData['role'],
            );
          },
        );
      },
    );
  }
}

class _UserListItem extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onCallPressed;

  const _UserListItem({
    required this.onCallPressed,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 232, 230, 230),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(

        leading: CircleAvatar(
backgroundColor: Colors.deepOrange[200],
foregroundColor: Colors.white,
          child: Text(name[0].toUpperCase()),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: onCallPressed,
        ),
      ),
    );
  }
}
