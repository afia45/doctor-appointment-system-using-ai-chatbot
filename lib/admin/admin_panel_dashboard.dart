import 'package:doctor_appointment_app/admin/booked_appointments_page.dart';
import 'package:doctor_appointment_app/admin/dashboard_page.dart';
import 'package:doctor_appointment_app/admin/hospital_database_page.dart';
import 'package:doctor_appointment_app/admin/manage_users_page.dart';
import 'package:flutter/material.dart';

class AdminPanelDashboard extends StatefulWidget {
  @override
  _AdminPanelDashboardState createState() => _AdminPanelDashboardState();
}

class _AdminPanelDashboardState extends State<AdminPanelDashboard> {
  int _selectedIndex = 0;

  // Pages corresponding to each drawer menu
  final List<Widget> _pages = [
    DashboardPage(),
    ManageUsersPage(),
    BookedAppointmentsPage(),
    HospitalDatabasePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
    //_navigateToPage(index);
  }

  // Method to handle navigation to different pages
  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageUsersPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookedAppointmentsPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HospitalDatabasePage()),
        );
        break;
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logging Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Logged out successfully')),
              //);
              Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Doctor Appointment Assistant App',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Navigation Items with active highlighting
            _buildDrawerItem(
              context,
              title: 'Dashboard',
              icon: Icons.dashboard,
              index: 0,
            ),
            _buildDrawerItem(
              context,
              title: 'Manage Users',
              icon: Icons.people,
              index: 1,
            ),
            _buildDrawerItem(
              context,
              title: 'Booked Appointments',
              icon: Icons.calendar_today,
              index: 2,
            ),
            _buildDrawerItem(
              context,
              title: 'Hospital Database',
              icon: Icons.local_hospital,
              index: 3,
            ),
            Divider(),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildDrawerItem(BuildContext context, {required String title, required IconData icon, required int index}) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      selected: _selectedIndex == index, // Highlight the active item
      selectedTileColor: Colors.grey[300], // Background color for the active item
      onTap: () => _onItemTapped(index),
    );
  }
}

// // Define each page as separate widgets

// class DashboardPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//         ),
//         Expanded(
//           child: Center(child: Text('Graph from Firebase Analytics')),
//         ),
//         Expanded(
//           child: Center(child: Text('Usage Metrics from Firestore')),
//         ),
//       ],
//     );
//   }
// }

// class ManageUsersPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Manage Users\nTable from Firestore'),
//     );
//   }
// }

// class BookedAppointmentsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Manage Booked Appointments\nTable from Firestore'),
//     );
//   }
// }

// class HospitalDatabasePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Manage Hospital Database\nTable from Firestore'),
//     );
//   }
// }
