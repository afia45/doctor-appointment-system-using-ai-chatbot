import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatelessWidget {
  // Function to launch the link in a browser
  void _launchMetricsURL() async {
    const url =
        'https://console.firebase.google.com/u/1/project/doctor-appointment-chatb-899d3/firestore/databases/-default-/usage/last-30d'; // Replace with your desired URL // https://console.firebase.google.com/
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
        automaticallyImplyLeading: false,
        title: Text('Usage Metrics'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top line with "Last Updated" text and link
              Wrap(
                spacing: 4.0, // Adds space between the text and link
                runSpacing: 4.0, // Adds space between the lines if wrapped
                children: [
                  Text(
                    'Last Updated 5th December 2024, ',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: _launchMetricsURL,
                    child: Text(
                      'Firestore Metrics',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    ' to view recent updates.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Section 1: Operations Metrics
              SectionWithImage(
                title: 'Operations Metrics',
                imagePath:
                    'assets/images/metric12.png', // Replace with your PNG path
              ),
              SizedBox(height: 34),

              // Section 2: Subscription Metrics
              SectionWithImage(
                title: 'Subscription Metrics',
                imagePath:
                    'assets/images/metric22.png', // Replace with your PNG path
              ),
              SizedBox(height: 34),

              // Section 3: Rules Metrics
              SectionWithImage(
                title: 'Rules Metrics',
                imagePath:
                    'assets/images/metric33.png', // Replace with your PNG path
              ),
              SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget to display a section with title and image
class SectionWithImage extends StatelessWidget {
  final String title;
  final String imagePath;

  const SectionWithImage({
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          //height: 200,
          decoration: BoxDecoration(
              //color: Colors.grey[300],
              //borderRadius: BorderRadius.circular(8),
              ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Image not found',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Error: $error',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
