import 'package:ajio_mart/widgets/nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/auth.json',  // Path to your Lottie animation
          width: 400,  // You can set your desired width
          height: 400, // Set the desired height
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Optionally, add some logic here if needed (e.g., navigating after the animation)
    Future.delayed(Duration(seconds: 3), () {
      // After 3 seconds, navigate to the main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBarWidget()),  // Replace with your main screen
      );
    });
  }
}
