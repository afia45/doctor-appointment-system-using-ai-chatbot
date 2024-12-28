import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> _user = Rx<User?>(null);
  String? studentId; 

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.userChanges());

    // Listen for changes in the user state and navigate accordingly
    ever(_user, (User? user) {
      if (user == null) {
        // If the user is logged out, navigate to login screen
        Get.offAllNamed('/login');
      } else {
        // If user is logged in, check role and navigate to the correct dashboard
        _checkUserRole(user);
      }
    });
  }

  User? get user => _user.value;

  // Login method
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _checkUserRole(userCredential.user!);
      }
    } catch (e) {
      print("Error logging in: $e");
    }
  }

  // Check the user's role and navigate accordingly
  Future<void> _checkUserRole(User user) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      studentId = userDoc['student_id']; // Fetch and store student ID
      String role = userDoc['role'];
      if (role == 'admin') {
        Get.offAllNamed('/adminDashboard');  // Navigate to admin dashboard
      } else if (role == 'student') {
        Get.offAllNamed('/studentDashboard');  // Navigate to student dashboard
      }
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      print('Logging out...');
      await _auth.signOut();
      print('User logged out, redirecting to login screen...');
    } catch (e) {
      print("Error logging out: $e");
    }
  }
}
