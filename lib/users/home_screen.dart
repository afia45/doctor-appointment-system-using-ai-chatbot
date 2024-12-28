//import 'package:doctor_appointment_app/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/users/gemini_chatbot/ask_any_question_page.dart';
import 'package:doctor_appointment_app/users/open_maps.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatbot/chat_screen.dart';
import 'calendar_page.dart';
import 'appointment_list_page.dart';
import 'bmi_calculation_page.dart';
import 'doctor_list_page.dart';
import 'call_emergency_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'translations.dart'; // Import translations

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  final VoidCallback onLogout; // Define the onLogout callback

  HomeScreen({required this.onLogout}); // Constructor accepts onLogout
}

class _HomeScreenState extends State<HomeScreen> {
  //final NotificationService _notificationService = NotificationService();
  String _languageCode = 'en'; // Default language
  User? user = FirebaseAuth.instance.currentUser; // Get current user
  Map<String, dynamic>? nextAppointment;

  void _changeLanguage(String languageCode) {
    setState(() {
      _languageCode = languageCode;
    });
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNextAppointment(); // Fetch the next appointment when the screen loads
  }

  Future<int?> _fetchRunningSerialNumber(String hospital, String department,
      String doctor, String date, String timeSlot) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get(); // Fetch all users

      for (var userDoc in querySnapshot.docs) {
        final appointmentsSnapshot = await userDoc.reference
            .collection('appointments')
            .where('hospital', isEqualTo: hospital)
            .where('department', isEqualTo: department)
            .where('doctor', isEqualTo: doctor)
            .where('date', isEqualTo: date)
            .where('time_slot', isEqualTo: timeSlot)
            .where('status', isEqualTo: 'Running')
            .get();

        if (appointmentsSnapshot.docs.isNotEmpty) {
          // Convert serial_number to an integer
          return int.tryParse(appointmentsSnapshot.docs.first
                  .data()['serial_number']
                  .toString()) ??
              0;
        }
      }
    } catch (e) {
      print('Error fetching running serial number: $e');
    }
    return null;
  }

  Future<void> _fetchNextAppointment() async {
    try {
      final userId = user?.uid;
      if (userId == null) return;

      // Query appointments sorted by date
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .orderBy('date') // Sort by date field
          .limit(2) //! should be 1 but for testing purpose i put 2!!
          .get();
      print(
          'Fetched Appointments: ${querySnapshot.docs.map((doc) => doc.data())}');
      // Convert Firestore data into DateTime objects and sort locally
      final appointments = querySnapshot.docs
          .where((doc) => doc.data()['status'] != 'Done')
          .map((doc) {
        final data = doc.data();

        final date = data['date']; // e.g., 'dd-MM-yyyy'
        final time = data['time_slot']; // e.g., '10:00 PM'

        // Parse date and time
        final dateFormat = DateFormat('dd-MM-yyyy');
        final timeFormat = DateFormat('hh:mm a');

        final parsedDate = dateFormat.parse(date);
        final parsedTime = timeFormat.parse(time);

        // Combine into a single DateTime object
        final combinedDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        return {
          ...data,
          'combinedDateTime': combinedDateTime, // Add parsed DateTime
        };
      }).toList();

      // Sort by combined DateTime locally
      appointments.sort(
          (a, b) => a['combinedDateTime'].compareTo(b['combinedDateTime']));

      // Get the next appointment
      if (appointments.isNotEmpty) {
        final appointment = appointments.first;
        final runningSerialNumber = await _fetchRunningSerialNumber(
          appointment['hospital'],
          appointment['department'],
          appointment['doctor'],
          appointment['date'],
          appointment['time_slot'],
        );
        setState(() {
          nextAppointment = appointment;
          nextAppointment!['running_serial_number'] = runningSerialNumber;
        });
        print('Next appointment: $nextAppointment');
      } else {
        setState(() {
          nextAppointment = null;
        });
        print('No upcoming appointments');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }
  // void initState() {
  //   super.initState();
  //   _notificationService.initialize();
  //   _scheduleNotifications();
  // }

  // void _scheduleNotifications() {
  //   _notificationService.sendScheduledNotifications();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Removes the back button
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage:
                  AssetImage('assets/images/profile_pic.png'), // Default image
            ),
            SizedBox(width: 10),
            Text(
              user?.displayName ?? user?.email ?? 'User',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.translate_outlined, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(Translations.getTranslation(
                        'selectLanguage', _languageCode)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('English'),
                          onTap: () {
                            _changeLanguage('en');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text('Bangla'),
                          onTap: () {
                            _changeLanguage('bn');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_sharp, color: Colors.white),
            onPressed: widget.onLogout, // Call the onLogout callback
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildNextAppointmentDashboard(), // Add the dashboard
            SizedBox(height: 20),
            // Grid of cards
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: 12 / 7,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        // Navigation logic
                        _navigateToPage(context, index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForCard(index),
                            size: 40,
                            color: Colors.red[700],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _getCardTitle(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAppointmentDashboard() {
    if (nextAppointment == null) {
      return Center(
        child: Text(
          Translations.getTranslation(
              'No Upcoming Appointments', _languageCode),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
    final runningSerialNumber = nextAppointment?['running_serial_number'];
    //Dashboard
    return Container(
      width: double.infinity, // Make the container take the full width
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        //border: Border.all(color: Colors.red), // red border
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${Translations.getTranslation('Next Appointment', _languageCode)} '
            '${Translations.getTranslation('on', _languageCode)} ${nextAppointment?['date']} '
            '${Translations.getTranslation('at', _languageCode)} ${nextAppointment?['time_slot']} '
            '${Translations.getTranslation('with', _languageCode)} ${nextAppointment?['doctor']} '
            '${Translations.getTranslation('at', _languageCode)} ${nextAppointment?['hospital']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Text(
          //   '${Translations.getTranslation('date', _languageCode)}: ${nextAppointment?['date']}',
          //   style: TextStyle(fontSize: 14),
          // ),
          // Text(
          //   '${Translations.getTranslation('time_slot', _languageCode)}: ${nextAppointment?['time_slot']}',
          //   style: TextStyle(fontSize: 14),
          // ),
          // Text(
          //   '${Translations.getTranslation('doctor', _languageCode)}: ${nextAppointment?['doctor']}',
          //   style: TextStyle(fontSize: 14),
          // ),
          // Text(
          //   '${Translations.getTranslation('serial_number', _languageCode)}: ${nextAppointment?['serial_number']}',
          //   style: TextStyle(fontSize: 14),
          // ),
          // Serial Number
          Row(
            children: [
              // Serial Number and Running Serial Number together
              Expanded(
                child: Row(
                  children: [
                    // Styled Serial Number
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        '${Translations.getTranslation('Serial No', _languageCode)}: ${nextAppointment?['serial_number']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Space between the two containers
                    // Running Serial Number
                    if (runningSerialNumber != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          '${Translations.getTranslation('Now Running Serial No', _languageCode)}: $runningSerialNumber',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Arrow Button aligned to the end
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RescheduleAppointmentPage(
                        userId: user?.uid ?? '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red background
                  foregroundColor: Colors.white, // White icon
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Return localized card titles
  String _getCardTitle(int index) {
    switch (index) {
      case 0:
        return Translations.getTranslation('makeAppointment', _languageCode);
      case 1:
        return Translations.getTranslation('askAnyQuestions', _languageCode);
      case 2:
        return Translations.getTranslation('checkAppointment', _languageCode);
      case 3:
        return Translations.getTranslation('rescheduleCancel', _languageCode);
      case 4:
        return Translations.getTranslation('bmiCalculation', _languageCode);
      case 5:
        return Translations.getTranslation('doctorList', _languageCode);
      case 6:
        return Translations.getTranslation('callEmergency', _languageCode);
      case 7:
        return Translations.getTranslation('hospitalNearMe', _languageCode);
      default:
        return 'Unknown';
    }
  }

  // Function to navigate to corresponding page
  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AskAnyQuestionPage()),
        );
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CheckAppointmentPage(
                    userId: user?.uid ?? '',
                  )),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RescheduleAppointmentPage(
              userId: user?.uid ?? '',
            ),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BMICalculatorPage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorListPage()),
        );
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CallEmergencyPage()),
        );
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OpenMapsPage()),
        );
        break;
      default:
        break;
    }
  }

  // Function to return the corresponding icon for each card
  IconData _getIconForCard(int index) {
    switch (index) {
      case 0:
        return Icons.message_outlined; // Make Appointment
      case 1:
        return Icons.question_answer; // Make Appointment
      case 2:
        return Icons.calendar_month_rounded; // Check Scheduled Appointment
      case 3:
        return Icons.update; // Reschedule or Cancel
      case 4:
        return Icons.favorite_border_rounded; // BMI Calculation
      case 5:
        return Icons.local_hospital; // Doctor List
      case 6:
        return Icons.add_call; // Call Emergency
      case 7:
        return Icons.add_location_alt_outlined; // Make Appointment
      default:
        return Icons.help;
    }
  }
}
