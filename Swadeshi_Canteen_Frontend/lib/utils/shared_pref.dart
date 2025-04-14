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

  // Clear user data when logging out
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
