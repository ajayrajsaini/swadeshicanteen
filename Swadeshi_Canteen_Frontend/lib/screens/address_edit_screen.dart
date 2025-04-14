import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/theme/app_colors.dart';

class AddressFormScreen extends StatefulWidget {
  final String? addressId; // Nullable addressId for edit
  const AddressFormScreen({Key? key, this.addressId}) : super(key: key);

  @override
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Address fields
   // TextEditingControllers for each field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String label = 'Home'; // Default address type (Home/Work)
  bool isDefault = false;

  // Initialize the address if editing
  @override
  void initState() {
    super.initState();
    if (widget.addressId != null) {
      fetchAddressData(); // Fetch address if editing
    }
  }

  Future<void> fetchAddressData() async {
    if (widget.addressId != null) {
      try {
        print(APIConfig.getAddress + widget.addressId!);
        final response = await http
            .get(Uri.parse(APIConfig.getAddress + widget.addressId!));
        print('response recieved');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final userAddress = data['userAddress'];
          setState(() {
            nameController.text = userAddress['name'] ?? '';
            addressLine1Controller.text = userAddress['addressLine1'] ?? '';
            addressLine2Controller.text = userAddress['addressLine2'] ?? '';
            cityController.text = userAddress['city'] ?? '';
            stateController.text = userAddress['state'] ?? '';
            postalCodeController.text = userAddress['postalCode'] ?? '';
            phoneController.text = userAddress['phoneNumber'] ?? '';
            label = userAddress['label'] ?? 'Home';
            isDefault = userAddress['isDefault'] ?? false;
          });
        }
      } catch (e) {
        print('Error fetching address: $e');
      }
    }
  }

  Future<void> saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> requestData = {
        "user": globals.userContactValue,
        "name": nameController.text,
        "addressLine1": addressLine1Controller.text,
        "addressLine2": addressLine2Controller.text,
        "city": cityController.text,
        "state": stateController.text,
        "postalCode": postalCodeController.text,
        "phoneNumber": phoneController.text,
        "label": label,
        "isDefault": isDefault,
      };

      try {
        // If addressId is null, add a new address
        if (widget.addressId == null) {
          final response = await http.post(
            Uri.parse(APIConfig.getAllAddresses),
            body: jsonEncode(requestData),
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 201) {
            Navigator.pop(context,true);
          } else {
            throw Exception('Failed to add address');
          }
        } else {
          // If addressId exists, update the existing address
          final response = await http.put(
            Uri.parse(APIConfig.getAllAddresses + widget.addressId!),
            body: jsonEncode(requestData),
            headers: {'Content-Type': 'application/json'},
          );
          if (response.statusCode == 200) {
            Navigator.pop(context,true); // Go back after updating
          } else {
            throw Exception('Failed to update address');
          }
        }
      } catch (e) {
        print('Error saving address: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle(widget.addressId == null ? 'Add Address' : 'Edit Address'),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController, // Use controller
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: addressLine1Controller, // Use controller
                      decoration: InputDecoration(labelText: 'Address Line 1'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address line 1';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: addressLine2Controller, // Use controller
                      decoration: InputDecoration(labelText: 'Address Line 2'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address line 2';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: cityController, // Use controller
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                    TextFormField(
                      controller: stateController, // Use controller
                      decoration: InputDecoration(labelText: 'State'),
                    ),
                    TextFormField(
                      controller: postalCodeController, // Use controller
                      decoration: InputDecoration(labelText: 'Postal Code'),
                    ),
                    TextFormField(
                      controller: phoneController, // Use controller
                      decoration: InputDecoration(labelText: 'Phone'),
                    ),
                    DropdownButtonFormField<String>(
                      value: label,
                      items: ['Home', 'Work'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          label = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Address Type'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Set as Default'),
                        Switch(
                          value: isDefault,
                          onChanged: (value) {
                            setState(() {
                              isDefault = value;
                            });
                          },
                          activeColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.addressId == null
                          ? 'Add Address'
                          : 'Save Address'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}