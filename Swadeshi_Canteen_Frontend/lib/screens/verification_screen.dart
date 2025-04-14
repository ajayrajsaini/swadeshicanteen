import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ajio_mart/screens/registration_screen.dart';
import 'package:ajio_mart/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:ajio_mart/widgets/nav_bar_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String contact;
  final String type; // either 'mobile' or 'email'

  VerificationScreen({required this.contact, required this.type});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // You would normally call the API to send the OTP here, but for this example:
      final response = await http.post(
        Uri.parse(APIConfig.sendOTP),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({widget.type: widget.contact}),
      );
      if (response.statusCode == 200) {
        // Navigate to the VerificationScreen and pass the contact info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent successfully.')),
        );
      } else {
        // Handle error (show an alert or message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sending failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();
    if (otp != null) {
      try {
        final response = await http.post(
          Uri.parse(APIConfig.verifyOTP),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            widget.type: widget.contact,
            'otp': otp,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP verified successfully')),
          );
          try {
            final responseFromLogin = await http.post(
              Uri.parse(APIConfig.userLogin),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                widget.type: widget.contact,
              }),
            );
            if (responseFromLogin.statusCode == 200) {
              SharedPrefsHelper.saveUserContactInfo(
                  widget.type, widget.contact);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        NavBarWidget(contactType : widget.type , contactValue:  widget.contact)), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            } else if (responseFromLogin.statusCode == 400) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => RegistrationScreen(
                      contact: widget.contact, type: widget.type),
                ), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Internal server error')),
              );
            }
          } catch (e) {
            print('Login Error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login Error')),
            );
          }
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid verification code')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Internal server error')),
          );
        }
      } catch (e) {
        print('Error verifying OTP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error in verifying OTP')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP is null')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Verify ${widget.type == 'phone' ? 'Mobile Number' : 'Email'}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          children: [
            Text(
              'We have sent an OTP to your ${widget.type == 'phone' ? 'mobile number' : 'email'}: ${widget.contact}',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading ? CircularProgressIndicator() : Text('Submit'),
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: _isLoading ? null : _sendOTP,
              child: Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
