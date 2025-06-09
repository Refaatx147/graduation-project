

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
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Create notification channel
    await _createNotificationChannel();


    // Set up foreground notification handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static Future<String> getAccessToken() async {
    // This method should return the access token for push notifications.
    // Implement your logic to retrieve the access token here.
final serviceAccountJson = 
{

  "type": "service_account",
  "project_id": "grade-pro-firebase",
  "private_key_id": "72f5d45557a8e7b857e51e3127253c9a46062cd7",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC14QG6AETI09n+\neVr7QLYRTcIdCSMuY5rUKg7dJG7QCXh44Vjw5820gsak1k9QSE9qvvuiFqTe/cyQ\neVbsxGVN6UjSlZfPjEtvYszZoix0CRt8OHJ3zYwg/I2MU3xukYZmz8CBfUN1HNA3\neCDR9EO4WLZejgfbuDYIWMQVPhyuK902CMEaUUzajQn7SVFhiMScKPFAuq5+XRnm\ngJIXPPZkNffhXCGm/BjKzJYhADqJyhHfUYVzX9MYXKHii+Nzv670t0FncxHbFuU1\n08ixVhrgNTr+6cxRZVNhBkrlfrYVSYJTtGCJc87mZ+h1gw8g/aCu1JzCYWoaMy+O\nxD9ORo8VAgMBAAECggEAD45yzNt4BqtkImlz2Di1Oe6qMzyUV0PqusnsIosatU2S\nEdjIeDaDeDSVVAUGnKnKrSkvsbH5IR+ZLyRJxI+Z0JurAGQOK5Dm5NyRA+5kmfor\ncSkM1WVt3mZrnvyHEJf+5G1RnGG/8tTnlE8Ak6SuZCamVpkUX/02Femtv9ljr5vo\nbyBGZKnx+NBPMDyFKp2wrVwVqDwys33wwJcXx+kcsmETbI0Sa+S3wrftL602bZGR\nYnjLBgdVT9jw8sbt4zxTtJazXEdlC8humm51rDbE17kuDeaUGhqQyrLBKyOldtfl\nZz6pS6xW5Or2mNyVjZS3qgs2/xrWXhBqI2t7koS0MwKBgQD+6pX4VzEQXbUvcXel\nYKFulTBCkWMCHQrE141RSJVhjSDNM6qgrRQrZMKm8WaBU2wM7s9hmVlOVh1HgjCy\nwaxgOjToSpo7EeYX1M0lGaXekLm+jIU8SFcK3j8DvoFymDcwem3eBmDu9SUWzmMa\nng9or4echgNwD8D+n0OziKeIHwKBgQC2pvACSSCeRuUNUhfBjaP7qwEKAlpwdARL\nfT+7hVZUoRyerEz2vIUXdootrgp5/jeFqC7FTR505zpoP/tvzaCK/kOZwjorJu2a\n2h2VSkIxSBsQtX98Ecs48sfVAaPiQkF2TzDiLJetq+VJiwej2ghacWN367jzlUSs\nHRMfVHCSSwKBgG8xjodMKTe1WHJAcWsu8lvVMb7nwiNK3catK5R4L8jkkZlQ3y3F\nMZYYFpxRkl/5LpmZldZB2OXFxHHLxUhEGNfErA1jdVEs5owgo/d575Nc19jZXMjF\n2UoBVcVhVP/Si8hWrxP4/lFdl3cSQcJ7jcchQesxvdAk3w9yE0r94e4LAoGAYGLH\n1OzyIZQX22eu0Z0FJBGhgr6rKxyOB6gYscQzQoWirLkQBESHl1IeqOxm6umUMxwF\nUmjX4akD0W+yJ9XDGpYC5mjweUUZrdXcNqPxOkBqx+5/T+Gz9GFpwqYS7Zs5IE25\n5iDSCfvkC2MqrPSp49BiRS5Hc4MZshnFtYrBvPECgYEAtjF5I5F0C4UJ/Qd3of6R\n730bF+9h04hwlpmyfstTttpURAtVMXtbLOnbsP/M931WNlt83AlcW5YXtgR7jL9O\nTfXU2Yw1BOLjvoDtCXM/wL2dup9dUdjw4tLb0KNj1UOwARoxQ5jLNOgUTdqw8NIF\nc0hY4Zx8Mhz++AVr4y7M6bc=\n-----END PRIVATE KEY-----\n",
  "client_email": "think-step-grade-project@grade-pro-firebase.iam.gserviceaccount.com",
  "client_id": "102152365004696023211",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/think-step-grade-project%40grade-pro-firebase.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"

} ;

List<String> scopes = [
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/firebase.database',
        'https://www.googleapis.com/auth/firebase.messaging',
    ];

   http.Client client = await auth.clientViaServiceAccount(
     auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
     scopes,
   );

   // get access token
   auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    client,  
   );

client.close();
   return credentials.accessToken.data;
}
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'emergency_alerts',
          'Emergency Alerts',
          description: 'High priority emergency alerts',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
          sound: RawResourceAndroidNotificationSound('notification')
        ),
      );
    }
  }

 

Future<void> getAndSaveFcmTokenToFirestore() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); 

    }
  } catch (e) {
  }
}


  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    
    // Show local notification
    if (message.notification != null) {
      await _localNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android:  AndroidNotificationDetails(
            'emergency_alerts',
            'Emergency Alerts',
            channelDescription: 'High priority emergency alerts',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            enableVibration: true
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap when app was in background
  }
  
  
  
  
  
  static Future<bool> sendHelpNotificationsToCaregiver(
  String caregiverId, 
  BuildContext context,
) async {
  try {
    // First get current patient info
    final patient = FirebaseAuth.instance.currentUser;
    if (patient == null) {
      return false;
    }

    // Get patient details
    final patientDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patient.uid)
        .get();

  

    // Get caregiver's token
    final caregiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(caregiverId)
        .get();

    final caregiverToken = caregiverDoc.data()?['fcmToken'] as String?;
    if (caregiverToken == null) {
      return false;
    }

    final patientName = patientDoc.data()?['name'] ?? 'Your patient';


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
          "token": caregiverToken,
          "notification": {
            "title": "Emergency Alert",
            "body": "$patientName needs your immediate assistance!",

          },
          "data": {
            "type": "emergency",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "timestamp": DateTime.now().toIso8601String(),
            "patientId": patient.uid,
            "patientName": patientName,
          },
          "android": {         
            "priority": "high",
            "notification": {
              "channel_id": "emergency_alerts",
              "default_sound": false,
              "default_vibrate_timings": true,
              "visibility": "public",
              "sound":"notification"
            }
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      
      // Create notification record in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'helpRequest',
        'senderId': patient.uid,
        'receiverId': caregiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
      
      return true;
    } else {
      
      if (response.body.contains('UNREGISTERED')) {
        // Only try to update if patient is linked to caregiver
        if (caregiverId !='') {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(caregiverId)
                .update({
                  'fcmToken': FieldValue.delete(),
                });
          } catch (e) {
          }
        }
      }
      return false;
    }

  } catch (e) {
    return false;
  }
}

// Update setupTokenRefresh method

}