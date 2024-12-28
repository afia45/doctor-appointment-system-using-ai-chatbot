//import 'package:doctor_appointment_app/users/notification_service.dart';
import 'package:doctor_appointment_app/users/appointment_list_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // For calendar widget
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore integration
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for user email
import 'package:intl/intl.dart'; // Add this import
import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckAppointmentPage extends StatefulWidget {
  final String userId; // The user ID passed to the page
  CheckAppointmentPage({required this.userId});
  @override
  _CheckAppointmentPageState createState() => _CheckAppointmentPageState();
}

class _CheckAppointmentPageState extends State<CheckAppointmentPage> {
  // To hold the selected date
  DateTime _selectedDate = DateTime.now();

  // A map to store appointments fetched from Firestore
  Map<DateTime, List<String>> _appointments = {};

  // Firestore and Auth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsFromFirestore();
  }

  // Fetch appointments from Firestore for the logged-in user
  Future<void> _fetchAppointmentsFromFirestore() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("No logged-in user.");
        return;
      }
      final userEmail = currentUser.email;
      print("Current user email: $userEmail");

      // Query Firestore for the user document by email
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        print("No user found with email: $userEmail");
        return;
      }

      final userDoc = userSnapshot.docs.first;
      final userId = userDoc.id;

      // Fetch appointments subcollection
      final appointmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .get();

      Map<DateTime, List<String>> fetchedAppointments = {};
      //int notificationId = 0;

      for (var appointmentDoc in appointmentsSnapshot.docs) {
        print("Fetched appointment: ${appointmentDoc.data()}");

        final appointment = appointmentDoc.data();

        DateTime date;
        if (appointment['date'] is String) {
          try {
            final dateString = appointment['date'] as String;
            date = DateFormat('dd-MM-yyyy').parse(dateString);
          } catch (e) {
            print("Failed to parse date string: ${appointment['date']} - $e");
            continue;
          }
        } else if (appointment['date'] is Timestamp) {
          date = (appointment['date'] as Timestamp).toDate();
        } else {
          print("Unknown date format: ${appointment['date']}");
          continue;
        }

        final formattedDate = DateTime(date.year, date.month, date.day);
        //final appointmentTime =
        //DateFormat('hh:mm a').parse(appointment['time_slot']);
        //final scheduledTime = DateTime(formattedDate.year, formattedDate.month,
        //formattedDate.day, appointmentTime.hour, appointmentTime.minute);

        // Schedule notifications
        // if (scheduledTime.isAfter(DateTime.now())) {
        //   // Schedule notifications and emails 24 hours before
        //   final reminder24Hours = scheduledTime.subtract(Duration(hours: 24));
        //   if (reminder24Hours.isAfter(DateTime.now())) {
        //     await NotificationService.scheduleNotification(
        //       title: 'Upcoming Appointment',
        //       body:
        //           'Your appointment with ${appointment['doctor']} at ${appointment['hospital']} is scheduled for ${DateFormat('dd-MM-yyyy hh:mm a').format(scheduledTime)}.',
        //       scheduledTime: reminder24Hours,
        //       notificationId: notificationId++,
        //     );
        // await EmailJSService.sendReminderEmail(
        //   toEmail: userEmail!,
        //   subject: "Reminder: Upcoming Appointment (24 Hours)",
        //   message: _composeEmailMessage(appointment, formattedDate),
        // );
        //}

        // Send email reminders
        // final emailSubject = "Reminder: Upcoming Appointment";
        // final emailBody =
        //     "Dear User,\n\nThis is a reminder for your appointment:\n"
        //     "- Doctor: ${appointment['doctor']}\n"
        //     "- Hospital: ${appointment['hospital']}\n"
        //     "- Date: ${DateFormat('dd-MM-yyyy').format(formattedDate)}\n"
        //     "- Time: ${appointment['time_slot']}\n\n"
        //     "Thank you,\nDoctor Appointment App";

        // Schedule notifications and emails 6 hours before
        // final reminder6Hours = scheduledTime.subtract(Duration(hours: 6));
        // if (reminder6Hours.isAfter(DateTime.now())) {
        //   await NotificationService.scheduleNotification(
        //     title: 'Upcoming Appointment',
        //     body:
        //         'Your appointment with ${appointment['doctor']} at ${appointment['hospital']} is scheduled for ${DateFormat('dd-MM-yyyy hh:mm a').format(scheduledTime)}.',
        //     scheduledTime: reminder6Hours,
        //     notificationId: notificationId++,
        //   );
        // await EmailJSService.sendReminderEmail(
        //   toEmail: userEmail!,
        //   subject: "Reminder: Upcoming Appointment (6 Hours)",
        //   message: _composeEmailMessage(appointment, formattedDate),
        // );
        //   }
        // }

        if (!fetchedAppointments.containsKey(formattedDate)) {
          fetchedAppointments[formattedDate] = [];
        }
        fetchedAppointments[formattedDate]?.add(
            "Appointment with ${appointment['department']} ${appointment['doctor']} at ${appointment['time_slot']} at ${appointment['hospital']}");
      }

      setState(() {
        _appointments = fetchedAppointments;
        print("Appointments loaded: $_appointments");
      });
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  // Helper function to compose email content
  String _composeEmailMessage(Map<String, dynamic> appointment, DateTime date) {
    return "Dear User,\n\nThis is a reminder for your appointment:\n"
        "- Doctor: ${appointment['doctor']}\n"
        "- Hospital: ${appointment['hospital']}\n"
        "- Date: ${DateFormat('dd-MM-yyyy').format(date)}\n"
        "- Time: ${appointment['time_slot']}\n\n"
        "Thank you,\nDoctor Appointment App";
  }

  // Get appointments for the selected date
  List<String> _getAppointmentsForSelectedDate() {
    return _appointments[_selectedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scheduled Appointments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar widget to pick a date
            TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2025, 12, 31),
              selectedDayPredicate: (day) {
                // Normalize both the day and selected date to ignore time differences
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final normalizedSelectedDate = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day);
                return isSameDay(normalizedDay, normalizedSelectedDate);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = DateTime(
                      selectedDay.year, selectedDay.month, selectedDay.day);
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.arrow_left),
                rightChevronIcon: Icon(Icons.arrow_right),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.red, // Change the default purple to red
                  shape: BoxShape.circle, // Keep the circular indicator
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.red
                      .shade200, // Highlight today's date with a different shade
                  shape: BoxShape.circle,
                ),
                markersMaxCount:
                    1, // Ensure only one marker is displayed per day
              ),
              calendarBuilders: CalendarBuilders(
                // Customize the cell for days with appointments
                markerBuilder: (context, day, events) {
                  // Check if there are any events on this day
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  if (_appointments.containsKey(normalizedDay)) {
                    // You can use an icon or colored dot to indicate appointments
                    return Positioned(
                        left: 1,
                        top: 1,
                        child: Icon(
                          Icons.star_border_purple500_rounded,
                          color: Colors.red,
                        ));
                  }
                  return SizedBox.shrink(); // No marker if no appointments
                },
              ),
            ),
            SizedBox(height: 20),

            // Display the appointments for the selected date
            Center(
                child: Column(
              children: [
                Text(
                  'Appointments on ${_selectedDate.toLocal()}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign:
                      TextAlign.center, // Ensures the text inside is centered
                ),
              ],
            )),
            SizedBox(height: 10),

            // List of appointments for the selected date
            _getAppointmentsForSelectedDate().isEmpty
                ? Text('No appointments for this day.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _getAppointmentsForSelectedDate().length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_getAppointmentsForSelectedDate()[index]),
                        leading: Icon(Icons.access_time),
                        trailing: Icon(Icons.info),
                        onTap: () {
                          // Optionally navigate to a detailed appointment page
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RescheduleAppointmentPage(
                                          userId: widget.userId)));
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

//---------------------------------------------------------------
class EmailJSService {
  static const String _emailJSUrl =
      "https://api.emailjs.com/api/v1.0/email/send";
  static const String _serviceID =
      "service_bug8qxe"; // Replace with your EmailJS Service ID
  static const String _templateID =
      "template_9t1luoj"; // Replace with your EmailJS Template ID
  static const String _userID =
      "R6sMAPVlfuBB-3b-u"; // Replace with your EmailJS User ID

  static Future<void> sendReminderEmail({
    required String toEmail,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_emailJSUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "service_id": _serviceID,
          "template_id": _templateID,
          "user_id": _userID,
          "template_params": {
            "to_email": toEmail,
            "subject": subject,
            "body": message,
          },
        }),
      );

      if (response.statusCode == 200) {
        print("Email sent successfully to $toEmail");
      } else {
        print("Failed to send email: ${response.body}");
      }
    } catch (e) {
      print("Error sending email via EmailJS: $e");
    }
  }
}
