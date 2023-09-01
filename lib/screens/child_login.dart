import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_loc2/screens/child_register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'childhome.dart';


class ChildLoginPage extends StatefulWidget {
  const ChildLoginPage({Key? key}) : super(key: key);

  @override
  _ChildLoginPageState createState() => _ChildLoginPageState();
}

class _ChildLoginPageState extends State<ChildLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChildRegisterPage(), // Replace with the appropriate registration page
      ),
    );
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Example validation
    if (username.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Username or password cannot be empty'),
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
      var url = Uri.parse('https://childtrackr-backend-production.up.railway.app/child/childlogin');
      // var url = Uri.parse('http://10.0.2.2:3000/childlogin'); // Replace with your actual API endpoint
      var body = jsonEncode({'username': username, 'password': password});
      var headers = {'Content-Type': 'application/json'};

      var response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = jsonDecode(response.body);
        bool isAuthenticated = data['isAuthenticated'];

        if (isAuthenticated) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userType', 'child');
          prefs.setString('childUsername', username);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChildHomePage(username: username)  // Pass the username to ParentHomePage
            ),
          );
        } else {
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
              title: const Text('Error'),
              content: const Text('Failed to connect to the server'),
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
                        controller: _usernameController,
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



