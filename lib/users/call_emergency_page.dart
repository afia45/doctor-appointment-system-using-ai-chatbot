import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallEmergencyPage extends StatelessWidget {
  // Function to make a call to the emergency number
  Future<void> _makeCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Call Emergency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Contact Header
            Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Emergency Contact Buttons
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.red),
                title: Text('Evercare Hospital'),
                subtitle: Text('Location: Plot No. H1, Anannya CDA Residential Area, Oxygen - Kuwaish Rd, Chattogram 4337'),
                trailing: Icon(Icons.call),
                onTap: () => _makeCall('911'),  // Replace with actual emergency number
              ),
            ),
            SizedBox(height: 15),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.red),
                title: Text('National Hospital Chattogram'),
                subtitle: Text('Location: 14/15 Mehedibug, Chittagong 4000'),
                trailing: Icon(Icons.call),
                onTap: () => _makeCall('101'),  // Replace with actual emergency number
              ),
            ),
            SizedBox(height: 15),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.red),
                title: Text('Parkview Hospital'),
                subtitle: Text('Location: 94/103 Katalgong, Chittagong 4000'),
                trailing: Icon(Icons.call),
                onTap: () => _makeCall('100'),  // Replace with actual emergency number
              ),
            ),
            SizedBox(height: 20),

            // Message on how to use the app
            Text(
              'Tap on any emergency hospitals to directly call the corresponding emergency number.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
