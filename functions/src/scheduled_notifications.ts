import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

export const checkScheduledNotifications = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    
    try {
      // Get all pending notifications that are due
      const snapshot = await admin.firestore()
        .collection('scheduledNotifications')
        .where('status', '==', 'pending')
        .where('scheduledTime', '<=', now)
        .get();

      const batch = admin.firestore().batch();
      const promises: Promise<void>[] = [];

      for (const doc of snapshot.docs) {
        const notification = doc.data();
        
        // Get patient's FCM token
        const patientDoc = await admin.firestore()
          .collection('users')
          .doc(notification.patientId)
          .get();
        
        const patientToken = patientDoc.data()?.fcmToken;
        
        if (patientToken) {
          // Send the notification
          const message: admin.messaging.TokenMessage = {
            token: patientToken,
            notification: {
              title: notification.title,
              body: `Scheduled reminder from your caregiver`,
            },
            data: {
              type: 'scheduled_reminder',
              notificationId: doc.id,
              timestamp: now.toDate().toISOString()
            },
            android: {
              priority: 'high',
              notification: {
                channelId: 'emergency_alerts',
                priority: 'high' as const,
                sound: 'notification',
                visibility: 'public',
                defaultVibrateTimings: false,
                vibrateTimingsMillis: [0, 1000, 500, 1000]
              }
            }
          };

          console.log('Attempting to send notification:', {
            patientId: notification.patientId,
            title: notification.title,
            token: patientToken.substring(0, 10) + '...' // Log only part of the token for security
          });

          promises.push(
            admin.messaging().send(message)
              .then(() => {
                console.log('Successfully sent notification to patient:', notification.patientId);
                // Mark notification as sent
                batch.update(doc.ref, {
                  status: 'sent',
                  sentAt: now,
                });
              })
              .catch((error) => {
                console.error('Error sending notification:', error);
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                  console.log('Invalid token, removing from database for patient:', notification.patientId);
                  // Remove invalid token
                  batch.update(patientDoc.ref, {
                    fcmToken: admin.firestore.FieldValue.delete(),
                  });
                }
                // Mark notification as failed
                batch.update(doc.ref, {
                  status: 'failed',
                  error: error.message,
                  updatedAt: now,
                });
              })
          );
        } else {
          // Mark notification as failed if no token found
          batch.update(doc.ref, {
            status: 'failed',
            error: 'No FCM token found for patient',
            updatedAt: now,
          });
        }
      }

      // Wait for all notifications to be processed
      await Promise.all(promises);
      
      // Commit all the status updates
      await batch.commit();
      
      console.log(`Processed ${snapshot.size} scheduled notifications`);
    } catch (error) {
      console.error('Error processing scheduled notifications:', error);
    }
  }); 