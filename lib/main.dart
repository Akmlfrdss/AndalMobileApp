import 'package:flutter/material.dart';
import 'package:tracking_loc2/screens/parents_login.dart';
import 'package:tracking_loc2/screens/child_login.dart';

void main() {
  runApp(const MyApp());
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.child_care, size: 100, color:Color(0xFF16BAC5)),
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
