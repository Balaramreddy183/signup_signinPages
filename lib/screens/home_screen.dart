import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// HomeScreen Widget
class _HomeScreenState extends State<HomeScreen> {
  TextEditingController? _nameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  bool _isEditing = false;

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  String username = '';
  String phone_number = '';
  String email = '';
  String password = '';
  String user_type = '';

  Future<void> _getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? '';
      phone_number = prefs.getString('phone_number') ?? '';
      email = prefs.getString('email') ?? '';
      password = prefs.getString('password') ?? '';
      user_type = prefs.getString('user_type') ?? '';
    });
    _nameController = TextEditingController(text: username);
    _phoneNumberController = TextEditingController(text: phone_number);
    _emailController = TextEditingController(text: email);
    _passwordController = TextEditingController(text: password);
  }

  Future<void> _saveUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userData = {
      'token': '2b1ffb35-41bf-4314-a722-9b3c91d16bd3', // Replace with valid token
      'details': {
        'name': _nameController!.text,
        'phone_number': _phoneNumberController!.text,
        'password': _passwordController!.text,

      },
    };

    try {
      final response = await http.post(
        Uri.parse('http://65.1.89.184:85/api/updateProfilev1'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',

          'Authorization': 'Bearer f59e3fa7-e6d8-4cf7-afb5-d1b3681a65d8', // Replace with valid token
        },
        body: jsonEncode(userData),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User details saved successfully'),
        ));
        await prefs.setString('name', _nameController!.text);
        await prefs.setString('phone_number', _phoneNumberController!.text);
        await prefs.setString('password', _passwordController!.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save user details. Please try again later.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $username'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: TextField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            ),
            Divider(),
            ListTile(
              title: TextField(
                controller: _phoneNumberController,
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
            ),
            Divider(),
            ListTile(
              title: TextField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            Divider(),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_isEditing) {
                  await _saveUserDetails();
                }
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Text(_isEditing ? 'Save Details' : 'Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
