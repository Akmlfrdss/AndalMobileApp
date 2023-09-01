import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'parents_login.dart';

class ParentRegisterPage extends StatefulWidget {
  const ParentRegisterPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<ParentRegisterPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

Future<void> _register() async {
  String username = _userController.text;
  String password = _passwordController.text;

  // Make a POST request to the registration endpoint
  // Uri url = Uri.parse('http://10.0.2.2:3000/register');
  Uri url = Uri.parse('https://childtrackr-backend-production.up.railway.app/user/register');
  Map<String, String> headers = {'Content-Type': 'application/json'};
  String body = '{"username": "$username", "password": "$password"}';

  try {
    http.Response response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Registration successful'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParentLoginPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } if (response.statusCode == 400) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('user already exists'),
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
  } catch (error) {
    print('Error during registration: $error');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred during registration'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            Row(
              children: [
                const SizedBox(width: 20.0),
                Expanded(
                  child: TextFormField(
                    controller: _userController,
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
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
