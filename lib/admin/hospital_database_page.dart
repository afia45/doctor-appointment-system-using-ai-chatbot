//TODO Restructure the whole database format
//TODO Give "Add" button to add hospitals, departments, doctors, days and time slots

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalDatabasePage extends StatefulWidget {
  @override
  _HospitalDatabasePageState createState() => _HospitalDatabasePageState();
}

class _HospitalDatabasePageState extends State<HospitalDatabasePage> {
  List<Map<String, dynamic>> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  // Fetch Hospitals and nested collections
  Future<void> _fetchHospitals() async {
    try {
      QuerySnapshot hospitalSnapshot =
          await FirebaseFirestore.instance.collection('hospitals').get();

      List<Map<String, dynamic>> hospitalData = [];
      for (var hospitalDoc in hospitalSnapshot.docs) {
        Map<String, dynamic> hospital = {
          'id': hospitalDoc.id,
          'name': hospitalDoc['name'],
          'location': hospitalDoc['location'],
          'departments': [],
        };

        QuerySnapshot departmentSnapshot =
            await hospitalDoc.reference.collection('departments').get();
        for (var departmentDoc in departmentSnapshot.docs) {
          Map<String, dynamic> department = {
            'id': departmentDoc.id,
            'name': departmentDoc['name'],
            'doctors': [],
          };

          QuerySnapshot doctorSnapshot =
              await departmentDoc.reference.collection('doctors').get();
          for (var doctorDoc in doctorSnapshot.docs) {
            Map<String, dynamic> doctor = {
              'id': doctorDoc.id,
              'name': doctorDoc['name'],
              'available_days': [],
            };

            QuerySnapshot daysSnapshot =
                await doctorDoc.reference.collection('available_days').get();
            for (var dayDoc in daysSnapshot.docs) {
              Map<String, dynamic> day = {
                'id': dayDoc.id,
                'name': dayDoc['name'],
                'time_slots': [],
              };

              QuerySnapshot slotsSnapshot =
                  await dayDoc.reference.collection('time_slots').get();
              day['time_slots'] = slotsSnapshot.docs
                  .map((slotDoc) => {'id': slotDoc.id, 'name': slotDoc['name']})
                  .toList();

              doctor['available_days'].add(day);
            }

            department['doctors'].add(doctor);
          }

          hospital['departments'].add(department);
        }

        hospitalData.add(hospital);
      }

      setState(() {
        _hospitals = hospitalData;
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
    }
  }

  // Update any Firestore field
  Future<void> _updateField(String path, String field, String newValue) async {
    try {
      await FirebaseFirestore.instance.doc(path).update({field: newValue});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$field updated successfully')));
      _fetchHospitals(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating $field: $e')));
    }
  }

  // Delete any Firestore document
  Future<void> _deleteDocument(String path) async {
    try {
      await FirebaseFirestore.instance.doc(path).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document deleted successfully')));
      _fetchHospitals(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting document: $e')));
    }
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text('Manage Hospital Database'),
        centerTitle: true,
      ),
      body: _hospitals.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                final hospital = _hospitals[index];
                return ExpansionTile(
                  title: _buildEditableTile(
                    title: hospital['name'],
                    path: 'hospitals/${hospital['id']}',
                    field: 'name',
                  ),
                  subtitle: _buildEditableTile(
                    title: hospital['location'],
                    path: 'hospitals/${hospital['id']}',
                    field: 'location',
                  ),
                  children: hospital['departments'].map<Widget>((department) {
                    return ExpansionTile(
                      title: _buildEditableTile(
                        title: department['name'],
                        path: 'hospitals/${hospital['id']}/departments/${department['id']}',
                        field: 'name',
                      ),
                      children: department['doctors'].map<Widget>((doctor) {
                        return ExpansionTile(
                          title: _buildEditableTile(
                            title: doctor['name'],
                            path: 'hospitals/${hospital['id']}/departments/${department['id']}/doctors/${doctor['id']}',
                            field: 'name',
                          ),
                          children: doctor['available_days'].map<Widget>((day) {
                            return ExpansionTile(
                              title: _buildEditableTile(
                                title: day['name'],
                                path:
                                    'hospitals/${hospital['id']}/departments/${department['id']}/doctors/${doctor['id']}/available_days/${day['id']}',
                                field: 'name',
                              ),
                              children: day['time_slots'].map<Widget>((slot) {
                                return ListTile(
                                  title: _buildEditableTile(
                                    title: slot['name'],
                                    path:
                                        'hospitals/${hospital['id']}/departments/${department['id']}/doctors/${doctor['id']}/available_days/${day['id']}/time_slots/${slot['id']}',
                                    field: 'name',
                                  ),
                                  // trailing: IconButton(
                                  //   icon: Icon(Icons.delete, color: Colors.red),
                                  //   onPressed: () {
                                  //     _deleteDocument(
                                  //         'hospitals/${hospital['id']}/departments/${department['id']}/doctors/${doctor['id']}/available_days/${day['id']}/time_slots/${slot['id']}');
                                  //   },
                                  // ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  // Editable Tile
  Widget _buildEditableTile({
    required String title,
    required String path,
    required String field,
  }) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        IconButton(
          icon: Icon(Icons.edit_outlined, color: Colors.grey),
          onPressed: () {
            _showEditDialog(path: path, field: field, currentValue: title);
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteDocument(path);
          },
        ),
      ],
    );
  }

  // Edit Dialog
  void _showEditDialog({required String path, required String field, required String currentValue}) {
    final TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'New Value'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateField(path, field, controller.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
