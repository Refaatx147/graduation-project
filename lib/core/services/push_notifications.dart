// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotifications {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
static Future<void> initialize() async {
    try {
      // Request permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
        announcement: true,
        carPlay: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Get initial token
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
          // Handle notification tap based on type
          if (details.payload != null) {
            final data = jsonDecode(details.payload!);
            if (data['type'] == 'scheduled_reminder') {
              // Handle scheduled reminder tap
              debugPrint('Scheduled reminder tapped: ${data['notificationId']}');
            }
          }
        },
      );

      // Create notification channel with all settings
      await _createNotificationChannel();

      // Set up foreground notification handlers
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('Message opened app: ${message.data}');
        _handleMessageOpenedApp(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e, stackTrace) {
      debugPrint('Error initializing push notifications: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling a background message: ${message.messageId}');
    // Add your background message handling logic here
  }

  static Future<String> getAccessToken() async {
    try {
      // Service account details
      const serviceAccount ={
 
};


      debugPrint('Initializing service account credentials...');
      
      final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);
      
      debugPrint('Creating HTTP client...');
      final client = await auth.clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging']
      );
      
      debugPrint('Getting access token...');
      final accessToken = client.credentials.accessToken.data;
      client.close();
      
      debugPrint('Successfully obtained access token');
      return accessToken;
    } catch (e, stackTrace) {
      debugPrint('Error getting access token: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to obtain access token: $e');
    }
  }

  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'emergency_alerts',
        'Emergency Alerts',
        description: 'High priority emergency alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableLights: true,
        ledColor: Color(0xff0D343F),
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

 

static Future<String?> getAndSaveFcmTokenToFirestore() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('No authenticated user found');
      return null;
    }

    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('Retrieved FCM token: $token');

    if (token == null || token.isEmpty) {
      debugPrint('Failed to get FCM token');
      return null;
    }

    // Validate token format
    if (!token.contains(':')) {
      debugPrint('Invalid FCM token format');
      return null;
    }

    // Save token to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
          'platformVersion': Platform.operatingSystemVersion,
        }, SetOptions(merge: true));

    debugPrint('FCM token saved to Firestore');

    // Set up token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed: $newToken');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
            'fcmToken': newToken,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
    });

    return token;
  } catch (e, stackTrace) {
    debugPrint('Error saving FCM token: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
}

static Future<String?> getFcmTokenFromFirestore(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      debugPrint('User document not found');
      return null;
    }

    final token = doc.data()?['fcmToken'] as String?;
    if (token == null || token.isEmpty) {
      debugPrint('FCM token not found in user document');
      return null;
    }

    // Check token age
    final lastUpdate = doc.data()?['lastTokenUpdate'] as Timestamp?;
    if (lastUpdate != null) {
      final age = DateTime.now().difference(lastUpdate.toDate());
      if (age.inDays > 7) {  // Token is older than 7 days
        debugPrint('FCM token is too old, requesting new token');
        return await getAndSaveFcmTokenToFirestore();
      }
    }

    return token;
  } catch (e) {
    debugPrint('Error getting FCM token from Firestore: $e');
    return null;
  }
}

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Handling foreground message with data: ${message.data}');
    debugPrint('Notification content: ${message.notification?.title} - ${message.notification?.body}');
    
    // Show local notification
    if (message.notification != null) {
      try {
        await _localNotifications.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: const AndroidNotificationDetails(
              'emergency_alerts',
              'Emergency Alerts',
              channelDescription: 'High priority emergency alerts',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              playSound: true,
              sound: const RawResourceAndroidNotificationSound('notification'),
              enableVibration: true,
              visibility: NotificationVisibility.public,
              category: AndroidNotificationCategory.alarm,
            ),
          ),
          payload: jsonEncode(message.data),
        );
        debugPrint('Local notification displayed successfully');
      } catch (e) {
        debugPrint('Error showing local notification: $e');
      }
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap when app was in background
  }
  
  
  
  
  
  static Future<bool> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    try {
      // Get receiver's token
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      if (!receiverDoc.exists) {
        debugPrint('Receiver document does not exist');
        return false;
      }

      final receiverToken = receiverDoc.data()?['fcmToken'] as String?;
      if (receiverToken == null || receiverToken.isEmpty) {
        debugPrint('Receiver FCM token is null or empty');
        return false;
      }

      // Validate token format (basic check)
      if (!receiverToken.contains(':')) {
        debugPrint('Invalid FCM token format');
        return false;
      }

      try {
        final String accessToken = await getAccessToken();
        const String endpoint = 'https://fcm.googleapis.com/v1/projects/grade-pro-firebase/messages:send';
        
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "message": {
              "token": receiverToken,
              "notification": {
                "title": title,
                "body": body,
              },
              "data": {
                ...data,
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "timestamp": DateTime.now().toIso8601String(),
              },
              "android": {         
                "priority": "high",
                "notification": {
                  "channel_id": "emergency_alerts",
                  "default_sound": false,
                  "default_vibrate_timings": true,
                  "visibility": "public",
                  "sound": "notification"
                }
              }
            }
          }),
        );

        debugPrint('FCM Response Status: ${response.statusCode}');
        debugPrint('FCM Response Body: ${response.body}');

        if (response.statusCode == 200) {
          // Create notification record in Firestore
          await FirebaseFirestore.instance.collection('notifications').add({
            'type': 'helpRequest',
            'senderId': FirebaseAuth.instance.currentUser!.uid,
            'receiverId': receiverId,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'sent',
            'title': title,
            'body': body,
            'data': data,
          });
          
          return true;
        } else {
          if (response.body.contains('UNREGISTERED') || 
              response.body.contains('INVALID_ARGUMENT') ||
              response.body.contains('NOT_FOUND')) {
            debugPrint('Invalid or expired FCM token, removing from database');
            await FirebaseFirestore.instance
                .collection('users')
                .doc(receiverId)
                .update({
                  'fcmToken': FieldValue.delete(),
                });
          }
          return false;
        }
      } catch (e) {
        debugPrint('Error sending FCM notification: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error in sendNotification: $e');
      return false;
    }
  }

  // Keep the original emergency help function for backward compatibility
  static Future<bool> sendHelpNotificationsToCaregiver(
    String caregiverId, 
    BuildContext context,
  ) async {
    final patient = FirebaseAuth.instance.currentUser;
    if (patient == null) return false;

    // Ensure patient token is up-to-date
    await getAndSaveFcmTokenToFirestore();

    final patientDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patient.uid)
        .get();

    final patientName = patientDoc.data()?['name'] ?? 'Your patient';

    return sendNotification(
      receiverId: caregiverId,
      title: "Emergency Alert",
      body: "$patientName needs your immediate assistance!",
      data: {   
        "type": "helpRequest",
        "patientId": patient.uid,
        "patientName": patientName,
      },
    );
  }
}