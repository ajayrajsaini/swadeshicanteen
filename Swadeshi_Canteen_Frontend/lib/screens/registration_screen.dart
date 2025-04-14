import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:ajio_mart/widgets/nav_bar_widget.dart';
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  final String contact;
  final String type;

  RegistrationScreen({required this.contact, required this.type});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to send registration data to the server
  Future<void> registerUser(String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse(APIConfig.register),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        widget.type: widget.contact
      }),
    );

    if (response.statusCode == 200) {
      // Successfully registered, navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
      SharedPrefsHelper.saveUserContactInfo(widget.type, widget.contact);
      Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        NavBarWidget(contactType : widget.type , contactValue:  widget.contact)), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
    } else if (response.statusCode == 400) {
      // Show error message if registration fails
      SharedPrefsHelper.saveUserContactInfo(widget.type, widget.contact);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome Back')),
      );
      Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        NavBarWidget(contactType : widget.type , contactValue:  widget.contact)), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle("Register"),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with registration
                    registerUser(_firstNameController.text.trim(),
                        _lastNameController.text.trim());
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
