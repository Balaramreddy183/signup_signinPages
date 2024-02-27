import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import './register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Uri loginUrl = Uri.parse('http://65.1.89.184:85/api/login');
  final Uri registrationUrl = Uri.parse('http://65.1.89.184:85/api/signupv1');

  Future loginUser(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();


    if (email.isEmpty || password.isEmpty) {
      _showSnackbar(context, 'Please enter both email and password.');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');
      final response = await http.post(
          loginUrl,
          headers: <String, String>{
            // 'Content-Type': 'application/json; charset=UTF-8',
            "Content-Type": "application/x-www-form-urlencoded",
            // 'Authorization' : 'Bearer 9eae2863-e59b-410d-940d-211dc91ec719'
            'Authorization': 'Bearer $authToken',
          },
          encoding: Encoding.getByName('utf-8'),
          body: {
            'email': email.toString(),
            'password': password.toString(),

          }
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 1) {
          final pref = await SharedPreferences.getInstance();

          await pref.setString('name', responseData['details']['name'].toString() );
          await pref.setString('email', responseData['details']['email'].toString() );
          await pref.setString('phone_number', responseData['details']['phone_number'].toString() );
          await pref.setString('password', responseData['details']['password']);

          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> HomeScreen() ), (route) => false);

        } else {
          _showSnackbar(context, 'Invalid email or password.');
        }
      } else {
        _showSnackbar(context, 'Failed to login. Please try again later.');
      }
    } catch (e) {
      _showSnackbar(context, 'An error occurred during login: $e');
      print(e.toString());
    }
  }

  bool _isValidEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => loginUser(context),
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text('New Register Here'),
            ),
          ],
        ),
      ),
    );
  }
}
