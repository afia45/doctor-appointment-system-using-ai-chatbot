// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class NotificationService {
//   static final _notificationPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // Initialize timezone data
//     tz.initializeTimeZones();

//     // Android-specific initialization settings
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // Overall initialization settings
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidInitializationSettings);

//     // Initialize the plugin
//     await _notificationPlugin.initialize(initializationSettings);
//   }

//   static Future<void> scheduleNotification({
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//     required int notificationId,
//   }) async {
//     await _notificationPlugin.zonedSchedule(
//       notificationId,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, tz.local), // Schedule for local timezone
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'appointment_reminder_channel', // Channel ID
//           'Appointment Reminders', // Channel name
//           channelDescription: 'Notifications for doctor appointments',
//           importance: Importance.max, // High importance
//           priority: Priority.high, // High priority
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exact, // Required parameter
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission for notifications.");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");
    });
  }

  /// Fetch appointments and send notifications
  Future<void> sendScheduledNotifications() async {
  final now = DateTime.now();

  // Fetch appointments from Firestore
  final snapshot = await FirebaseFirestore.instance.collection('appointments').get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final appointmentDateString = data['appointment_date']; // Format: dd-mm-yyyy
    final userToken = data['fcm_token']; // Store user FCM token in Firestore
    final email = data['email'];

    try {
      // Parse the date from dd-mm-yyyy to DateTime
      final appointmentDate = DateTime.parse(
        '${appointmentDateString.substring(6)}-${appointmentDateString.substring(3, 5)}-${appointmentDateString.substring(0, 2)}'
      );

      final diff = appointmentDate.difference(now).inHours;

      // Check if the notification should be sent
      if (diff == 24 || diff == 6) {
        // Send push notification
        await sendPushNotification(
          token: userToken,
          title: "Appointment Reminder",
          body: "Your appointment is scheduled in $diff hours.",
        );

        // Send email via EmailJS
        await sendEmail(email, appointmentDate.toIso8601String());
      }
    } catch (e) {
      print("Error parsing date for document ${doc.id}: $e");
    }
  }
}

  /// Send a push notification via FCM
  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    const String serverKey = 'bf98e4794a28eae5a721e668d2fbbfa0228de3a6'; // Replace with your Firebase server key
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );

      if (response.statusCode == 200) {
        print("Push notification sent successfully.");
      } else {
        print("Failed to send push notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  /// Send email via EmailJS
  Future<void> sendEmail(String recipientEmail, String appointmentDate) async {
    const String emailJsApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
    const String emailJsServiceId = 'service_bug8qxe';
    const String emailJsTemplateId = 'template_9t1luoj';
    const String emailJsUserId = 'R6sMAPVlfuBB-3b-u';

    try {
      final response = await http.post(
        Uri.parse(emailJsApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': emailJsServiceId,
          'template_id': emailJsTemplateId,
          'user_id': emailJsUserId,
          'template_params': {
            'to_email': recipientEmail,
            //'appointment_date': appointmentDate,
          },
        }),
      );

      if (response.statusCode == 200) {
        print("Email sent successfully.");
      } else {
        print("Failed to send email: ${response.body}");
      }
    } catch (e) {
      print("Error sending email: $e");
    }
  }
}
