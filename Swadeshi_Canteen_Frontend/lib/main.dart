// lib/main.dart
import 'package:ajio_mart/screens/sub_category_screen.dart';
import 'package:ajio_mart/splash_screen.dart';
import 'package:ajio_mart/widgets/nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ajio_mart/screens/login_screen.dart';  // Import the LoginScreen here
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // Save user credentials
  static Future<void> saveUserContactInfo(String contactType, String contactValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('contactType', contactType);
    await prefs.setString('contactValue', contactValue);
    await prefs.setBool('isLoggedIn', true);
  }

  // Retrieve user credentials
  static Future<Map<String, String?>> getUserContactInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contactType = prefs.getString('contactType');
    String? contactValue = prefs.getString('contactValue');
    return {
      'contactType': contactType,
      'contactValue': contactValue,
    };
  }

  // Check if the user is logged in
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

}


const String baseUrl = 'https://api.yourapp.com/v1';
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  Firebase.initializeApp();
  bool isLoggedIn = await SharedPrefsHelper.isLoggedIn();
  Map<String, String?> userCredentials = await SharedPrefsHelper.getUserContactInfo();
  runApp(MyApp(isLoggedIn: isLoggedIn, userCredentials: userCredentials));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, String?> userCredentials;

  const MyApp({Key? key, required this.isLoggedIn, required this.userCredentials}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812), 
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Ajio Mart',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: isLoggedIn
          ? SplashScreen()              //SubCategoryScreen(superCategoryId: "aaa")
          : LoginScreen(),
        );
      },
    );
  }
}
