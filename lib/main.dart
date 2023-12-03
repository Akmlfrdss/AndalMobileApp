import 'package:flutter/material.dart';
import 'package:tracking_loc2/screens/parents_login.dart';
import 'package:tracking_loc2/screens/child_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_loc2/screens/parentshome.dart';
import 'package:tracking_loc2/screens/childhome.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Pastikan Flutter sudah terinisialisasi
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userType = prefs.getString('userType');
  String? username = prefs.getString('username');
  String? childUsername = prefs.getString('childUsername');
  String token = prefs.getString('getToken').toString();
  bool? isAuthenticated = prefs.getBool('Authenticated');
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'notification for basic tests'),
    ],
    debug: true,
  );

  runApp(
    MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: userType == 'parent' && token.isNotEmpty && isAuthenticated == true
          ? ParentHomePage(
              username:
                  username ?? '') // Ganti dengan halaman orang tua yang sesuai
          : userType == 'child'
              ? ChildHomePage(
                  username: childUsername ??
                      '') // Ganti dengan halaman anak yang sesuai
              : const LandingPage(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landing Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5FBFF9), Color(0xFFEFE9F4)],
            begin: Alignment.centerRight,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'welcome.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LatoFont',
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParentLoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.person_outline_outlined,
                        size: 100, color: Color(0xFF5863F8)),
                    SizedBox(height: 8.0),
                    Text(
                      'Orang Tua',
                      style: TextStyle(color: Color(0xFF5863F8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChildLoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.child_care, size: 100, color: Color(0xFF16BAC5)),
                    SizedBox(height: 8.0),
                    Text(
                      'Anak',
                      style: TextStyle(color: Color(0xFF16BAC5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
