import 'package:ajio_mart/screens/address_screen.dart';
import 'package:ajio_mart/screens/login_screen.dart';
import 'package:ajio_mart/screens/order_screen.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:ajio_mart/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppStyles.appBarStyle("Profile"),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Full Name section
          ListTile(
            leading: Icon(Icons.person),
            title: Text('${globals.userFirstName} ${globals.userLastName}'),
            subtitle: Text('${globals.userContactValue}'),
            onTap: () {
              // Navigate to Edit Full Name Screen
            },
          ),
          Divider(),

          // Your Addresses section
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Your Addresses'),
            onTap: () {
              // Navigate to the Address Management Screen
              PersistentNavBarNavigator.pushNewScreen(context, screen: AddressScreen(),
                              withNavBar: true,
                              );
            },
          ),
          Divider(),

          // Orders section
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Orders'),
            onTap: () {
              // Navigate to Orders Screen
              PersistentNavBarNavigator.pushNewScreen(context, screen: OrderScreen(),
                              withNavBar: true,
                              );
            },
          ),
          Divider(),

          // Help and Support section
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help and Support'),
            onTap: () {
              // Navigate to Help and Support Screen
              Navigator.pushNamed(context, '/helpSupportScreen');
            },
          ),
          Divider(),

          // Logout section
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle logout functionality
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // Handle logout logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              SharedPrefsHelper.clearUserData();
              globals.clearUserData();
              // Navigate to the login screen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen()), // LoginScreen is your desired destination
                (Route<dynamic> route) =>
                    false, // This removes all previous routes
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
