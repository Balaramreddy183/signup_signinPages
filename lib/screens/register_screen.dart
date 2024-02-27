import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/login_screen.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void registerUser(BuildContext context) async {
    final String name = nameController.text.trim();
    final String phone_number = phoneNumberController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (name.isEmpty || phone_number.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter all fields.'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    if (!_isValidPhoneNumber(phone_number)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid phone number.'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid email address.'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://65.1.89.184:85/api/signupv1'),
        headers: <String, String>{
          // 'Content-Type': 'application/json; charset=UTF-8',
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
        body:{
          'name': name,
          'phone_number': phone_number,
          'email': email,
          'password': password,
          'user_type': '1',
        }
      );

      if (response.statusCode == 200) {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Successfully registered!'),
          duration: Duration(seconds: 2),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid data. Please check your inputs and try again.'),
          duration: Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to register user. Please try again later.'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred during registration: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }


  bool _isValidPhoneNumber(String value) {
    return RegExp(r'^[0-9]{10}$').hasMatch(value);
  }

  bool _isValidEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
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
              onPressed: () => registerUser(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
