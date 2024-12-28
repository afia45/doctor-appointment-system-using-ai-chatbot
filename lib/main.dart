//!--- Device Preview Code -----
//TODO Fix admin - give admin roles (cut out the admin@gmail.com) >Login Page and Main Page
//TODO Notifications + Emails
//TODO
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:doctor_appointment_app/admin/admin_panel_dashboard.dart';
import 'package:doctor_appointment_app/users/home_screen.dart';
//import 'package:doctor_appointment_app/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login_page.dart';
import 'registration_page.dart';
import 'users/generated/l10n.dart'; // Generated localization file
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
//!--------------------------------------------
import 'package:device_preview/device_preview.dart'; // Import DevicePreview
import 'package:flutter/foundation.dart'; // Required for kReleaseMode

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  //await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon', // App icon resource
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic messages',
        defaultColor: const Color.fromARGB(255, 221, 80, 80),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );
  //!--------------------------------------------
  runApp(MyApp());
  // runApp(DevicePreview(
  //     enabled: !kReleaseMode, // Disable Device Preview in Release mode
  //     builder: (context) => MyApp(),),);
  //!--------------------------------------------
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US'); // Default locale is English
  bool _isLoggedIn = false; // Track login status
  bool _isInitializing =
      true; // Track whether Firebase is initialized and login state is checked
  late FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkLoginStatus();
    // });
    _checkLoginStatus(); // Check login status when the app starts
    _initializeFirebaseMessaging(); // Initialize Firebase Messaging
  }

  // ?? Initialize Firebase Messaging and request permissions
  void _initializeFirebaseMessaging() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request notification permissions
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User denied notification permissions');
    }

    // Listen to foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            channelKey: 'basic_channel',
            title: message.notification?.title,
            body: message.notification?.body,
          ),
        );
      }
    });

    Future<void> _firebaseMessagingBackgroundHandler(
        RemoteMessage message) async {
      await Firebase.initializeApp();
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'basic_channel',
          title: message.notification?.title,
          body: message.notification?.body,
        ),
      );
    }

    // Print FCM token for testing
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  // ?? --------Notification END-------------------------------
  // Check if the user is logged in
  _checkLoginStatus() async {
    // Initialize SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Check if the user is logged in with Firebase
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    // If the user is logged in with Firebase, update the login status accordingly
    if (firebaseUser != null) {
      //String email = firebaseUser.email ?? "";
      setState(() {
        _isLoggedIn = true;
        _isInitializing = false; // Set initialization complete
      });

      // Check if the user is an admin
      // if (email == "admin@gmail.com") {
      //   // Navigate to Admin Dashboard if the user is an admin
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             AdminPanelDashboard()), // Replace with your Admin Dashboard screen
      //   );
      // } else {
      //   // Regular user stays on the HomeScreen
      //   setState(() {
      //     _isLoggedIn = true;
      //   });
      // }

      setState(() {
           _isLoggedIn = true;
         });
    } else {
      setState(() {
        _isLoggedIn = isLoggedIn; // Use SharedPreferences as fallback
        _isInitializing = false; // Set initialization complete
      });
    }
  }

  // Set login status to true when user logs in
  _setLoginStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', status); // Save login status
  }

  // Logout function to clear login status
  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false); // Clear login status
    setState(() {
      _isLoggedIn = false; // Update state
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //!--------------------------------------------
      // useInheritedMediaQuery: true, // Required for Device Preview
      // builder: DevicePreview.appBuilder, // Use DevicePreview's builder
      //locale: DevicePreview.locale(context), // Use locale from Device Preview
      //!--------------------------------------------
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      title: 'Doctor Appointment Assistant App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red, // Adjust your preferred color
        ),
        primarySwatch: Colors.red,
        primaryColor: Colors.red, // Sets the primary color
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red[100], // Changes ElevatedButton's default color
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Changes TextButton's default color
          ),
        ),
      ),
      //!--------------------------------------------
      //locale: kReleaseMode ? _locale : DevicePreview.locale(context),
      //!--------------------------------------------
      //locale: _locale, // Apply the selected locale here
      localizationsDelegates: [
        S.delegate, // Generated delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'), // English
        Locale('bn', 'BD'), // Bangla
        // Add other languages here
      ],
      // Define named routes
      routes: {
        '/login': (context) => LoginPage(onLogin: () {
              _setLoginStatus(true); // Set login status when user logs in
              Navigator.pushReplacementNamed(context, '/home');
            }),
        '/registration': (context) => RegistrationPage(),
        '/home': (context) => HomeScreen(onLogout: () {
              _logout(); // Logout user
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            }),
      },
      // Wait until initialization is complete before showing home or splash screen
      home: _isInitializing
          ? Center(child: CircularProgressIndicator())
          : _isLoggedIn
              ? FirebaseAuth.instance.currentUser?.email == "admin@gmail.com"
                  ? AdminPanelDashboard() // Navigate to Admin Dashboard for admins
                  : HomeScreen(onLogout: () {
                      _logout(); // Logout user
                      Navigator.pushReplacementNamed(context, '/login');
                    })
              : SplashScreen(changeLanguage: _changeLanguage),
    );
  }
}
//?----------------------------------------------------------

class SplashScreen extends StatefulWidget {
  final Function(Locale) changeLanguage;

  SplashScreen({required this.changeLanguage});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WelcomePage(changeLanguage: widget.changeLanguage)),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.redAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).appTitle, // Localized string
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).healthPriority, // Localized string
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
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

class WelcomePage extends StatelessWidget {
  final Function(Locale) changeLanguage;

  WelcomePage({required this.changeLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.red],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Language Change Button
            IconButton(
              icon: Icon(
                Icons.translate_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _showLanguageDialog(context);
              },
            ),
            // App Icon or Illustration
            Image.asset(
              'assets/images/icon.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 30),

            // Welcome Text
            Text(
              S.of(context).welcomeMessage, // Localized string
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).healthPriority,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),

            // Sign In Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                S.of(context).signIn, // Localized string
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                            onLogin: () {
                              // Set login status when user logs in
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                S.of(context).login, // Localized string
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).appTitle), // Localized title
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  changeLanguage(Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              // ListTile(
              //   title: Text('Spanish'),
              //   onTap: () {
              //     changeLanguage(Locale('es', 'ES'));
              //     Navigator.pop(context);
              //   },
              // ),
              ListTile(
                title: Text('Bangla'),
                onTap: () {
                  changeLanguage(Locale('bn', 'BD'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
