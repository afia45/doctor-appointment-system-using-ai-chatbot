import 'package:doctor_appointment_app/users/chatbot/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore integration

class RescheduleAppointmentPage extends StatefulWidget {
  final String userId; // The user ID passed to the page

  RescheduleAppointmentPage({required this.userId});

  @override
  _RescheduleAppointmentPageState createState() =>
      _RescheduleAppointmentPageState();
}

class _RescheduleAppointmentPageState extends State<RescheduleAppointmentPage> {
  late Future<List<Map<String, dynamic>>> appointments;

  @override
  void initState() {
    super.initState();
    _removePastAppointments(); // Clean up past appointments
    appointments = fetchAppointments(widget.userId); // Fetch appointments
  }

  // Function to fetch user's appointments from Firestore
  Future<List<Map<String, dynamic>>> fetchAppointments(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .get();

    List<Map<String, dynamic>> appointments = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> appointmentData = doc.data() as Map<String, dynamic>;
      appointmentData['appointmentId'] =
          doc.id; // Add the document ID to the data
      appointments.add(appointmentData);
    }
    return appointments;
  }

  // Function to delete past appointments
  Future<void> _removePastAppointments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime now = DateTime.now();

    // Get all appointments for the user
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .doc(widget.userId)
        .collection('appointments')
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> appointmentData = doc.data() as Map<String, dynamic>;

      // Parse the date field
      String appointmentDateStr = appointmentData['date'];
      String appointmentTimeStr = appointmentData['time_slot'];
      // Combine the date and time into a DateTime object
      DateTime appointmentDateTime = DateFormat('dd-MM-yyyy HH:mm a').parse(
        '$appointmentDateStr $appointmentTimeStr',
      );

      // Compare the appointment date with the current date
      if (appointmentDateTime.isBefore(now)) {
        // Delete past appointments
        await firestore
            .collection('users')
            .doc(widget.userId)
            .collection('appointments')
            .doc(doc.id)
            .delete();
      }
    }

    // Refresh the state to remove deleted appointments from the UI
    setState(() {
      appointments = fetchAppointments(widget.userId);
    });
  }

  // Function to show a warning dialog before canceling the appointment
  void _showCancelDialog(Map<String, dynamic> appointment) {
    // Parse the date and time fields
    String appointmentDateStr = appointment['date']; // e.g., '04-12-2024'
    String appointmentTimeStr = appointment['time_slot']; // e.g., '02:30 PM'
    // Combine the date and time into a DateTime object
    DateTime appointmentDateTime = DateFormat('dd-MM-yyyy hh:mm a').parse(
      '$appointmentDateStr $appointmentTimeStr',
    );

    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the difference in hours
    Duration difference = appointmentDateTime.difference(now);

    // Check if the appointment is within 6 hours
    if (difference.inHours < 6) {
      // Show error dialog
      _showErrorDialog(
          'Canceling or rescheduling is not allowed within 6 hours of the appointment time.');
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _cancelAppointment(appointment); // Proceed with cancellation
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without canceling
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a warning dialog before rescheduling
  void _showRescheduleDialog(Map<String, dynamic> appointment) {
    // Parse the date and time fields
    String appointmentDateStr = appointment['date']; // e.g., '04-12-2024'
    String appointmentTimeStr = appointment['time_slot']; // e.g., '02:30 PM'

    // Combine the date and time into a DateTime object
    DateTime appointmentDateTime = DateFormat('dd-MM-yyyy hh:mm a').parse(
      '$appointmentDateStr $appointmentTimeStr',
    );

    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the difference in hours
    Duration difference = appointmentDateTime.difference(now);

    // Check if the appointment is within 6 hours
    if (difference.inHours < 6) {
      // Show error dialog
      _showErrorDialog(
          'Rescheduling is not allowed within 6 hours of the appointment time.');
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(
              'Your current appointment will be deleted. Do you want to reschedule?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rescheduleAppointment(appointment);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Function to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Action Not Allowed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Reschedule the appointment
  void _rescheduleAppointment(Map<String, dynamic> appointment) async {
    // Cancel the previous appointment in Firestore
    await _cancelAppointment(appointment);

    // Navigate to the reschedule page (or chatbot)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(),
      ),
    );
  }

  // Cancel the appointment
  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Delete the appointment from Firestore
    await firestore
        .collection('users')
        .doc(widget.userId)
        .collection('appointments')
        .doc(appointment['appointmentId']) // Use the actual document ID
        .delete();

    setState(() {
      appointments =
          fetchAppointments(widget.userId); // Refresh the appointments list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.red[100],
        title: Text("Your Appointments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching appointments'));
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          var appointmentList = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: appointmentList.length,
            itemBuilder: (context, index) {
              var appointment = appointmentList[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ListTile(
                              title: Text(
                                'Doctor: ${appointment['doctor']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(appointment['department']),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Serial No: ${appointment['serial_number']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          title: Text(
                            appointment['hospital'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Time: ${appointment['time_slot']} | Date: ${appointment['date']}',
                          ),
                        ),
                        ButtonBar(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _showRescheduleDialog(appointment),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors
                                      .orange, // Orange background for Reschedule button
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                  )),
                              child: Text('Reschedule'),
                            ),
                            TextButton(
                              onPressed: () => _showCancelDialog(appointment),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red, // Red background
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  )),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
