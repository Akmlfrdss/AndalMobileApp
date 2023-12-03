import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_loc2/screens/parents_register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'parentshome.dart';

class ParentLoginPage extends StatefulWidget {
  const ParentLoginPage({Key? key}) : super(key: key);

  @override
  _ParentLoginPageState createState() => _ParentLoginPageState();
}

class _ParentLoginPageState extends State<ParentLoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ParentRegisterPage(), // Replace with the appropriate registration page
      ),
    );
  }

  Future<void> _login() async {
    String password = _passwordController.text;
    String email = _emailController.text;
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String token = prefs.getString('getToken').toString();
    // bool? isAuthenticated = prefs.getBool('Authenticated');

    // print('${token} , ${isAuthenticated}');
    // Example validation
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Email or password cannot be empty'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Make an HTTP request to authenticate the user
    try {
      var url = Uri.parse(
          'https://childtrackr-backend-production.up.railway.app/user/login'); // Replace with your actual API endpoint
      var body = jsonEncode({'email': email, 'password': password});
      var headers = {'Content-Type': 'application/json'};

      var response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = jsonDecode(response.body);
        bool isAuthenticated = data['isAuthenticated'];
        String getToken = data['token'];

        if (isAuthenticated && getToken.isNotEmpty) {
          bool Authenticated = true;
          String username = data['username'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userType', 'parent');
          prefs.setString('username', username);
          prefs.setString('getToken', getToken);
          prefs.setBool('Authenticated', Authenticated);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ParentHomePage(
                  username: username), // Pass the username to ParentHomePage
            ),
          );
        } else if (response.statusCode == 401) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Invalid username or password'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Handle request failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Log In Gagal'),
              content: const Text('Invalid username or password'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'), // Tampilkan pesan kesalahan
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5863F8), Color(0xFF5FBFF9)],
            begin: Alignment.centerRight,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LatoFont',
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.white),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: _goToRegister,
                  child: const Text(
                    'Belum punya akun? Register disini',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
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
