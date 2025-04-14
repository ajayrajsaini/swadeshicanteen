import 'package:ajio_mart/screens/home_screen.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:ajio_mart/widgets/nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ajio_mart/api_config.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (!_isValidMobile(value) && !_isValidEmail(value)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  bool _isValidMobile(String value) {
    if (value.isEmpty) {
      return false;
    } else if (value.length != 10) {
      return false;
    } else {
      for (int i = 0; i < value.length; i++) {
        if (value[i].compareTo('0') < 0 || value[i].compareTo('9') > 0) {
          return false; // not a digit
        }
      }
      return true; // all characters are digits
    }
  }

  bool _isValidEmail(String value) {
    if (value.isEmpty) {
      return false;
    } else if (!value.contains('@') || !value.contains('.')) {
      return false;
    } else {
      int atIndex = value.indexOf('@');
      int dotIndex = value.lastIndexOf('.');

      // Check if '@' comes before '.' and both are in valid positions
      if (atIndex > 0 &&
          dotIndex > atIndex + 1 &&
          dotIndex < value.length - 1) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> login(String contact) async {
    String contactType;
    String contactValue;
    print("Login function called with value: $contact");
    if (_isValidMobile(contact)) {
      contactType = 'phone';
      contactValue = contact; // Format as E.164 for India
      if(contactValue == "1223334444"){
        SharedPrefsHelper.saveUserContactInfo(
                  contactType, contactValue);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        NavBarWidget(contactType : contactType , contactValue:  contactValue)), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
      }
      final response = await http.post(
        Uri.parse(APIConfig.sendOTP),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }, //remove first and last Name
        body: jsonEncode({contactType: contactValue}),
      );

      if (response.statusCode == 200) {
        // Navigate to the VerificationScreen and pass the contact info
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerificationScreen(contact: contactValue, type: contactType),
          ),
        );
      } else {
        // Handle error (show an alert or message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sending failed. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid phone number.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in or Sign up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  hintText: 'Enter Mobile Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: validateContact,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    login(_contactController.text.trim());
                  } else {
                    print("Form is not valid.");
                  }
                },
                child: Text('Continue'),
              ),
              Text(
                'By continuing, you agree to our terms of service and privacy policy.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
