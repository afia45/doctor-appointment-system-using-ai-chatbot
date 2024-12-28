import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _users = querySnapshot.docs.map((doc) {
          return {
            'uid': doc.id,
            'email': doc['email'] ?? 'No email',
            'name': doc['name'] ?? 'No name',
            'created_at': doc['created_at'] != null
                ? (doc['created_at'] as Timestamp).toDate().toString()
                : 'No date',
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $e')));
    }
  }

  Future<void> _deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      setState(() {
        _users.removeWhere((user) => user['uid'] == uid);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Text('Manage Users'),
        centerTitle: true,
      ),
      body: _users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50, // Background color
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      border: Border.all(
                        color: Colors.grey.shade300, // Border color
                        width: 2, // Border width
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        user['name'] ?? 'No name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email'] ?? 'No email'),
                          Text('Created at: ${user['created_at']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user['uid']),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
