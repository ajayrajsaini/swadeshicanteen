import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/address_edit_screen.dart';
import 'package:ajio_mart/screens/profile_screen.dart'; // Import the ProfileScreen
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/theme/app_colors.dart'; // Import your app colors file
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<dynamic> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAddresses(); // Fetch addresses when screen initializes
  }

  Future<void> fetchAddresses() async {
    final url = APIConfig.getAllAddresses +
        globals.userContactValue.toString(); // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> addressList = jsonDecode(response.body);
        setState(() {
          addresses = addressList
              .map((json) => {
                    'id': json['_id'],
                    'name': json['name'],
                    'label': json['label'],
                    'addressLine1': json['addressLine1'],
                    'addressLine2': json['addressLine2'],
                    'city': json['city'],
                    'state': json['state'],
                    'postalCode': json['postalCode'],
                    'phoneNumber': json['phoneNumber'],
                    'isDefault': json['isDefault'],
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteAddress(int index) async {
    final url = APIConfig.getAllAddresses +
        addresses[index]["id"]; // Replace with your API URL
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          addresses.removeAt(index);
        });
        print('Deleted address at index: $index');
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfileScreen()), // Navigate to Profile screen
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        return false; // Prevent default back button action
      },
      child: Scaffold(
        appBar: AppStyles.appBarStyle("Manage Addresses"),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchAddresses, // Refresh when pulled down
                child: addresses.isEmpty
                    ? Center(
                        child: Text(
                          'No addresses available.',
                          style: TextStyle(
                              color: AppColors.textColor, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Main Heading with Name
                                            Text(
                                              address[
                                                  'label']!, // Display the name as heading
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 4),

                                            // Subheading with Work/Home
                                            Text(
                                              address[
                                                  'name']!, // Display Work/Home as subheading
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),

                                            // Address
                                            Text(
                                              '${address['addressLine1']}, ${address['addressLine2']}, ${address['state']}, ${address['postalCode']}, ${address['phoneNumber']}',
                                              style: TextStyle(
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Default Address Badge
                                      if (address['isDefault'] ==
                                          true) // Check if it's the default address
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 96, 96, 96),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                          icon: Icon(Icons.edit,
                                              color: AppColors.accentColor),
                                          label: Text(
                                            'Edit',
                                            style: TextStyle(
                                                color: AppColors.accentColor),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddressFormScreen(
                                                          addressId:
                                                              address['id'])),
                                            )
                                                .then((_) {
                                              fetchAddresses(); // Refresh addresses when coming back
                                            });
                                          }),
                                      TextButton.icon(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        label: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () => deleteAddress(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.accentColor,
          onPressed: () {
            // Implement add new address functionality here
            Navigator.of(context)
                .push(
              MaterialPageRoute(builder: (context) => AddressFormScreen()),
            )
                .then((_) {
              fetchAddresses(); // Refresh addresses when coming back
            });
          },
          child: Icon(Icons.add, color: AppColors.backgroundColor),
        ),
      ),
    );
  }
}
