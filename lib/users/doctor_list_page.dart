import 'package:doctor_appointment_app/users/chatbot/chat_screen.dart';
import 'package:flutter/material.dart';

class DoctorListPage extends StatelessWidget {
  static const Map<String, Map<String, List<Map<String, dynamic>>>> hospitalData = {
  'Parkview Hospital': {
    'Pediatrics': [
      {'name': 'Dr. Roksana Ahmed', 'imageUrl': 'https://i0.wp.com/parkview.com.bd/wp-content/uploads/2022/03/Dr-Roksana-Ahmed.jpg?fit=600%2C600&ssl=1',
      'daysAvailable': ['Monday', 'Wednesday', 'Friday'],
        'roomNumber': '302',
        'fee': 500,
        'specialties': ['Pediatric Gastroenterology', 'Pediatric Cardiology', 'Pediatric Neurology'],
      }
    ],
    'Psychiatry': [
      {'name': 'Dr. ASM Redwan', 'imageUrl': 'https://i0.wp.com/parkview.com.bd/wp-content/uploads/2019/03/DrASM-Ridwan-Psychiatrist.jpg?fit=600%2C600&ssl=1',
      'daysAvailable': ['Sunday', 'Wednesday', 'Friday'],
        'roomNumber': '410',
        'fee': 500,
        'specialties': ['Child and adolescent psychiatry', 'Old age psychiatry'],
      }

    ],
  },
  'Evercare Hospital': {
    'Cardiology': [
      {'name': 'Dr. Zahiruddin Mahmud Illius', 'imageUrl': 'https://www.evercarebd.com/chattogram/oldsite/consultant/consultant_images/1657999260.jpg',
      'daysAvailable': ['Monday', 'Wednesday', 'Friday'],
        'roomNumber': '302',
        'fee': 500,
        'specialties': ['Heart Surgery', 'Cardiovascular Health'], 
      }
    ],
    'Orthopedics': [
      {'name': 'Dr. Jabeed Jahangir Tuhin', 'imageUrl': 'https://www.evercarebd.com/chattogram/oldsite/consultant/consultant_images/1658142272.jpg',
      'daysAvailable': ['Monday', 'Wednesday', 'Friday'],
        'roomNumber': '302',
        'fee': 410,
        'specialties': ['Orthopaedic General'],
      },
      {'name': 'Dr. Rahul Bhan', 'imageUrl': 'https://www.evercarebd.com/chattogram/oldsite/consultant/consultant_images/Dr.%20Rahul%20Bhan.jpeg',
      'daysAvailable': ['Monday', 'Wednesday', 'Friday'],
        'roomNumber': '302',
        'fee': 405,
        'specialties': ['Orthopaedic General'],
      }
    ],
  },
  'National Hospital': {
    'Neurology': [
      {'name': 'Dr. Abdullah Al Hasan', 'imageUrl': 'https://example.com/abdullah_hasan.jpg',
      'daysAvailable': ['Monday', 'Wednesday', 'Friday'],
        'roomNumber': '302',
        'fee': 500,
        'specialties': ['Heart Surgery', 'Cardiovascular Health'],
      }
    ],
    'Gynecology': [
      {'name': 'Dr. Sharmin Sultana', 'imageUrl': 'https://example.com/sharmin_sultana.jpg',
      'daysAvailable': ['Monday', 'Wednesday', 'Friday'],
        'roomNumber': '302',
        'fee': 500,
        'specialties': ['Heart Surgery', 'Cardiovascular Health'],
      }
    ],
  },
};


  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.red[100],
        title: const Text(
          
          'Doctor List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        //backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: hospitalData.keys.length,
              itemBuilder: (context, hospitalIndex) {
                final hospitalName = hospitalData.keys.elementAt(hospitalIndex);
                final departments = hospitalData[hospitalName]!;
            
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ExpansionTile(
                    title: Text(
                      hospitalName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        //color: Colors.red,
                      ),
                    ),
                    children: departments.entries.map((entry) {
                      final department = entry.key;
                      final doctors = entry.value;
            
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              department,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...doctors.map(
                                  (doctor) {
              final doctorName = doctor['name']!;
              final doctorImageUrl = doctor['imageUrl']!;
              final daysAvailable = doctor['daysAvailable'] as List<String>;
              final roomNumber = doctor['roomNumber'] as String;
              final fee = doctor['fee'] as int;
              final specialties = doctor['specialties'] as List<String>;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
            doctorName,
            style: const TextStyle(color: Colors.black),
                ),
                trailing: const Icon(Icons.arrow_forward, color: Colors.red),
                onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailPage(
                  doctorName: doctorName,
                  department: department,
                  hospital: hospitalName,
                  imageUrl: doctorImageUrl,
                  daysAvailable: daysAvailable,
                  roomNumber: roomNumber,
                  fee: fee,
                  specialties: specialties,
                ),
              ),
            );
                },
              );
            }),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorDetailPage extends StatelessWidget {
  final String doctorName;
  final String department;
  final String hospital;
  final String imageUrl; // New field for the image URL
  final List<String> daysAvailable; // New field for available days
  final String roomNumber; // New field for room number
  final int fee; // New field for consultation fee
  final List<String> specialties; // New field for specialties

  const DoctorDetailPage({
    super.key,
    required this.doctorName,
    required this.department,
    required this.hospital,
    required this.imageUrl, // Accept the image URL
    required this.daysAvailable,
    required this.roomNumber,
    required this.fee,
    required this.specialties,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$doctorName Details',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red[100],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.network(
                    imageUrl, // Display the doctor's image
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.redAccent,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Department: $department',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hospital: $hospital',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 20),
              Text(
                'Room Number: $roomNumber',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                'Consultation Fee: \$${fee.toString()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Text(
                'Available Days:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...daysAvailable.map((day) => Text(
                    day,
                    style: const TextStyle(fontSize: 16),
                  )),
              const SizedBox(height: 20),
              Text(
                'Specialties:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...specialties.map((specialty) => Text(
                    specialty,
                    style: const TextStyle(fontSize: 16),
                  )),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //       'Appointment with $doctorName booked at $hospital',
                    //     ),
                    //   ),
                    // );
                    
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
                          
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    textStyle: const TextStyle(fontSize: 18),
                    
                  ),
                  child: const Text(
                    'Make Appointment',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}