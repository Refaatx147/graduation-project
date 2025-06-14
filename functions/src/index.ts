import * as admin from 'firebase-admin';
import { checkScheduledNotifications } from './scheduled_notifications';

// Initialize Firebase Admin at the top level
admin.initializeApp();

// Export the Cloud Function
export { checkScheduledNotifications }; 