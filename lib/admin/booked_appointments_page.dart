import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookedAppointmentsPage extends StatefulWidget {
  @override
  _BookedAppointmentsPageState createState() => _BookedAppointmentsPageState();
}

class _BookedAppointmentsPageState extends State<BookedAppointmentsPage> {
  List<Map<String, dynamic>> _groupedAppointments = [];
  String? selectedHospital;
  String? selectedDepartment;
  String? selectedDoctor;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  // Fetch all appointments and group them
  Future<void> _fetchAppointments() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> groupedData = [];

      for (var userDoc in usersSnapshot.docs) {
        QuerySnapshot appointmentsSnapshot =
            await userDoc.reference.collection('appointments').get();

        for (var appointment in appointmentsSnapshot.docs) {
          final data = appointment.data() as Map<String, dynamic>;
          groupedData.add({
            'id': appointment.id,
            'userId': userDoc.id,
            ...data,
          });
        }
      }

      setState(() {
        _groupedAppointments = groupedData;
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  // Update the serial number
  Future<void> _updateSerialNumber(
      String userId, String appointmentId, int newSerial) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .update({'serial_number': newSerial});
      _fetchAppointments(); // Refresh data
    } catch (e) {
      print('Error updating serial number: $e');
    }
  }

  // Update the appointment status
  Future<void> _updateStatus(
      String userId, String appointmentId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus});
      _fetchAppointments(); // Refresh data
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Delete an appointment
  Future<void> _deleteAppointment(String userId, String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .doc(appointmentId)
          .delete();
      _fetchAppointments(); // Refresh data
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }

  // Build Dropdowns for Filtering
  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? selectedValue,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: items.contains(selectedValue)
          ? selectedValue
          : null, // Ensure valid value
      decoration:
          InputDecoration(labelText: label, border: OutlineInputBorder()),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(e.toString()),
              ))
          .toList(),
      onChanged: (value) {
        onChanged(value);
        if (value == null) return;
      },
    );
  }

  // Build Appointment List
  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return Center(child: Text('No appointments available.'));
    }

    // Sort by serial number
    appointments.sort((a, b) {
      // Ensure serial_number is parsed into int for both a and b
      int serialA = int.tryParse(a['serial_number'].toString()) ?? 0;
      int serialB = int.tryParse(b['serial_number'].toString()) ?? 0;
      return serialA.compareTo(serialB);
    });

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return ListTile(
          title: Text('Patient: ${appointment['name']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Serial: ${appointment['serial_number']}'),
              Text('Status: ${appointment['status']}'),
              Text('Time Slot: ${appointment['time_slot']}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Up Arrow Button
              IconButton(
                icon: Icon(Icons.arrow_upward),
                onPressed: index > 0
                    ? () {
                        // Swap with the appointment above
                        final aboveAppointment = appointments[index - 1];
                        final int currentSerial = int.tryParse(
                                appointment['serial_number']?.toString() ??
                                    '0') ??
                            0;
                        final int aboveSerial = int.tryParse(
                                aboveAppointment['serial_number']?.toString() ??
                                    '0') ??
                            0;

                        _updateSerialNumber(appointment['userId'],
                            appointment['id'], aboveSerial);
                        _updateSerialNumber(aboveAppointment['userId'],
                            aboveAppointment['id'], currentSerial);
                      }
                    : null, // Disable if at the top
              ),
              // Down Arrow Button
              IconButton(
                icon: Icon(Icons.arrow_downward),
                onPressed: index < appointments.length - 1
                    ? () {
                        // Swap with the appointment below
                        final belowAppointment = appointments[index + 1];
                        final int currentSerial = int.tryParse(
                                appointment['serial_number']?.toString() ??
                                    '0') ??
                            0;
                        final int belowSerial = int.tryParse(
                                belowAppointment['serial_number']?.toString() ??
                                    '0') ??
                            0;
                        _updateSerialNumber(
                            appointment['userId'],
                            appointment['id'],
                            belowSerial);
                        _updateSerialNumber(
                            belowAppointment['userId'],
                            belowAppointment['id'],
                            currentSerial);
                      }
                    : null, // Disable if at the bottom
              ),
              // Popup Menu for other actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Delete') {
                    _deleteAppointment(
                        appointment['userId'], appointment['id']);
                  } else {
                    _updateStatus(
                        appointment['userId'], appointment['id'], value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 'Running', child: Text('Mark as Running')),
                  PopupMenuItem(value: 'Done', child: Text('Mark as Done')),
                  PopupMenuItem(
                      value: 'Delete', child: Text('Delete Appointment')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtered appointments
    final filteredAppointments = _groupedAppointments.where((appointment) {
      return (selectedHospital == null ||
              appointment['hospital'] == selectedHospital) &&
          (selectedDepartment == null ||
              appointment['department'] == selectedDepartment) &&
          (selectedDoctor == null || appointment['doctor'] == selectedDoctor) &&
          (selectedDate == null || appointment['date'] == selectedDate);
    }).toList();

    // Unique filtering options
    final hospitals = _groupedAppointments
        .map((appointment) => appointment['hospital'] as String?)
        .where((hospital) => hospital != null) // Filter out nulls
        .map((hospital) => hospital!)
        .toSet()
        .toList();

    final departments = _groupedAppointments
        .where((appointment) => appointment['hospital'] == selectedHospital)
        .map((appointment) => appointment['department'] as String?)
        .where((department) => department != null) // Filter out nulls
        .map((department) => department!)
        .toSet()
        .toList();

    final doctors = _groupedAppointments
        .where((appointment) =>
            appointment['hospital'] == selectedHospital &&
            appointment['department'] == selectedDepartment)
        .map((appointment) => appointment['doctor'] as String?)
        .where((doctor) => doctor != null) // Filter out nulls
        .map((doctor) => doctor!)
        .toSet()
        .toList();

    final dates = _groupedAppointments
        .where((appointment) =>
            appointment['hospital'] == selectedHospital &&
            appointment['department'] == selectedDepartment &&
            appointment['doctor'] == selectedDoctor)
        .map((appointment) => appointment['date'] as String?)
        .where((date) => date != null) // Filter out nulls
        .map((date) => date!)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Booked Appointments'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filters
            //Text('Filter',textAlign: TextAlign.start,),
            _buildDropdown<String>(
              label: 'Select Hospital',
              items: hospitals,
              selectedValue: selectedHospital,
              onChanged: (value) {
                setState(() {
                  selectedHospital = value;
                  selectedDepartment = null;
                  selectedDoctor = null;
                  selectedDate = null;
                });
              },
            ),
            SizedBox(height: 8),
            _buildDropdown<String>(
              label: 'Select Department',
              items: departments,
              selectedValue: selectedDepartment,
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                  selectedDoctor = null;
                  selectedDate = null;
                });
              },
            ),
            SizedBox(height: 8),
            _buildDropdown<String>(
              label: 'Select Doctor',
              items: doctors,
              selectedValue: selectedDoctor,
              onChanged: (value) {
                setState(() {
                  selectedDoctor = value;
                  selectedDate = null;
                });
              },
            ),
            SizedBox(height: 8),
            _buildDropdown<String>(
              label: 'Select Date',
              items: dates,
              selectedValue: selectedDate,
              onChanged: (value) {
                setState(() {
                  selectedDate = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'All Booked Patients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Appointment List
            Expanded(child: _buildAppointmentsList(filteredAppointments)),
          ],
        ),
      ),
    );
  }
}
