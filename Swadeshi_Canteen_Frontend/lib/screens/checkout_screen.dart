import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/address_edit_screen.dart';
import 'package:ajio_mart/screens/cart_screen.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:ajio_mart/widgets/nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class Address {
  final String id;
  final String addressLine;
  final bool isDefault;

  Address(
      {required this.id, required this.addressLine, required this.isDefault});
}

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartItems;
  CheckoutScreen({required this.cartItems});
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = '';
  bool isExpandedCreditDebitCard = false;
  bool isExpandedUPI = false;
  List<Address> addresses = [];
  Address? defaultAddress;
  bool isLoading = true; // Track loading state

  // Define TextEditingControllers for card and UPI fields
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> fetchAddresses() async {
    // Clear the cached default address before fetching new addresses

    final url = APIConfig.getAllAddresses +
        globals.userContactValue.toString(); // Your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> addressList = jsonDecode(response.body);
        setState(() {
          addresses = addressList.map((json) {
            return Address(
              id: json['_id'],
              addressLine:
                  '${json['name']}, ${json['addressLine1']}, ${json['addressLine2']}, ${json['city']}, ${json['state']}, ${json['postalCode']}',
              isDefault: json['isDefault'],
            );
          }).toList();

          // Check if there are any addresses and set defaultAddress accordingly
          if (addresses.isNotEmpty) {
            defaultAddress =
                addresses.firstWhere((address) => address.isDefault,
                    orElse: () => Address(
                        id: 'no_default', // Some ID to indicate no default
                        addressLine: 'No default address',
                        isDefault: false));
          } else {
            defaultAddress = Address(
                id: 'no_address', // Some ID to indicate no addresses
                addressLine: 'No addresses available',
                isDefault: false);
          }

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

  Future<void> submitOrder({
    required String paymentMethod,
    required String addressId,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    String? upiId,
  }) async {
    final orderData = {
      'user': globals.userContactValue,
      'paymentMethod': paymentMethod,
      'addressId': addressId,
      if (paymentMethod == 'Credit/Debit Card') ...{
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryDate': expiryDate,
        'cvv': cvv,
      },
      if (paymentMethod == 'UPI') ...{
        'upiId': upiId,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(APIConfig.submitOrder), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        print('Order submitted successfully!');
        // Handle success (maybe navigate to another screen or show a message)
        updateProduct(widget.cartItems);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
        );
      }else if(response.statusCode == 400){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select any address.')),
        );
      } else {
        print('Failed to submit order. Error: ${response.body}');
      }
    } catch (e) {
      print('Error during order submission: $e');
    }
  }

  // Function to update rating for all ordered products
Future<void> updateProduct(List<dynamic> cartProducts) async {
  try {
    // Loop through all items in the order
    for (var item in cartProducts) {
      int stock = item['stock']- item['quantity'];
      if(stock<0){
          stock =0;
        }
      final response = await http.put(
        Uri.parse(APIConfig.getProduct + item['_id']), // Replace with your API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'admin'
        },
        
        body: jsonEncode({
          'stock': stock,
          }),
      );

      if (response.statusCode == 200) {
        // Successfully updated rating
        print('Stock Updated');
      } else {
        // Handle error
        print('Failed to update Stock.');
      }
    }
  } catch (e) {
    print('Error updating ratings: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update ratings.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle("Checkout"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (isLoading) // Show loading indicator while fetching addresses
                Center(child: CircularProgressIndicator())
              else if (defaultAddress!.id != 'no_address')
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            defaultAddress!.addressLine,
                            style: TextStyle(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to AddressSelectionScreen and handle address selection
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressSelectionScreen(
                                  addresses: addresses,
                                  onSelectAddress: (selectedAddress) {
                                    setState(() {
                                      defaultAddress = selectedAddress;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Text('Change'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Show "Add" button if no default address is found
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            defaultAddress!.addressLine,
                            style: TextStyle(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Implement change address logic here
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressFormScreen(),
                              ),
                            ).then((_) {
                              fetchAddresses(); // Refresh addresses when coming back
                            });
                          },
                          child: Text('Add Address'),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              Text(
                'Select a payment method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Credit/Debit Card Payment
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   elevation: 4,
              //   child: Column(
              //     children: [
              //       ListTile(
              //         leading: Radio(
              //           value: 'Credit/Debit Card',
              //           groupValue: selectedPaymentMethod,
              //           onChanged: (value) {
              //             setState(() {
              //               selectedPaymentMethod = value.toString();
              //               toggleExpanded('Credit/Debit Card');
              //             });
              //           },
              //         ),
              //         title: Text(
              //           'Credit/Debit Card',
              //           style: TextStyle(
              //               fontSize: 18, fontWeight: FontWeight.bold),
              //         ),
              //         onTap: () {
              //           setState(() {
              //             selectedPaymentMethod = 'Credit/Debit Card';
              //             toggleExpanded('Credit/Debit Card');
              //           });
              //         },
              //       ),
              //       if (isExpandedCreditDebitCard &&
              //           selectedPaymentMethod == 'Credit/Debit Card')
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Column(
              //             children: [
              //               _buildTextField(
              //                 'Card Number',
              //                 TextInputType.number,
              //                 maxLength: 16,
              //                 controller: _cardNumberController,
              //                 inputFormatters: [
              //                   FilteringTextInputFormatter.digitsOnly
              //                 ],
              //               ),
              //               SizedBox(height: 10),
              //               _buildTextField(
              //                 'Cardholder Name',
              //                 TextInputType.text,
              //                 controller: _cardHolderNameController,
              //               ),
              //               SizedBox(height: 10),
              //               Row(
              //                 children: [
              //                   Expanded(
              //                     flex: 2,
              //                     child: _buildTextField(
              //                       'Expiry Date (MM/YY)',
              //                       TextInputType.datetime,
              //                       controller: _expiryDateController,
              //                       inputFormatters: [
              //                         FilteringTextInputFormatter.allow(
              //                             RegExp(r'^[0-9/]*$')),
              //                         LengthLimitingTextInputFormatter(7),
              //                         ExpiryDateTextInputFormatter(),
              //                       ],
              //                     ),
              //                   ),
              //                   SizedBox(width: 10),
              //                   Expanded(
              //                     flex: 1,
              //                     child: _buildTextField(
              //                       'CVV',
              //                       TextInputType.number,
              //                       controller: _cvvController,
              //                       maxLength: 3,
              //                       inputFormatters: [
              //                         FilteringTextInputFormatter.digitsOnly,
              //                       ],
              //                       showCounter: false,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //     ],
              //   ),
              // ),

              // // UPI Payment
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   elevation: 4,
              //   child: Column(
              //     children: [
              //       ListTile(
              //         leading: Radio(
              //           value: 'UPI',
              //           groupValue: selectedPaymentMethod,
              //           onChanged: (value) {
              //             setState(() {
              //               selectedPaymentMethod = value.toString();
              //               toggleExpanded('UPI');
              //             });
              //           },
              //         ),
              //         title: Text(
              //           'UPI',
              //           style: TextStyle(
              //               fontSize: 18, fontWeight: FontWeight.bold),
              //         ),
              //         onTap: () {
              //           setState(() {
              //             selectedPaymentMethod = 'UPI';
              //             toggleExpanded('UPI');
              //           });
              //         },
              //       ),
              //       if (isExpandedUPI && selectedPaymentMethod == 'UPI')
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: _buildTextField(
              //             'UPI ID',
              //             TextInputType.text,
              //             controller: _upiIdController,
              //             inputFormatters: [
              //               FilteringTextInputFormatter.allow(
              //                   RegExp(r'[a-zA-Z0-9@.]')),
              //             ],
              //           ),
              //         ),
              //     ],
              //   ),
              // ),

              // Cash On Delivery
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Radio(
                    value: 'Cash On Delivery',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value.toString();
                        toggleExpanded('Cash On Delivery');
                      });
                    },
                  ),
                  title: Text(
                    'Cash On Delivery',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Cash On Delivery';
                      toggleExpanded('Cash On Delivery');
                    });
                  },
                ),
              ),

              SizedBox(height: 30),

              // Review and Submit Button
              ElevatedButton(
                onPressed: () async {
                  // Check if a payment method is selected
                  if (selectedPaymentMethod.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a payment method.')),
                    );
                    return;
                  }

                  // Validate fields for Credit/Debit Card
                  if (selectedPaymentMethod == 'Credit/Debit Card') {
                    if (_cardNumberController.text.isEmpty ||
                        _cardHolderNameController.text.isEmpty ||
                        _expiryDateController.text.isEmpty ||
                        _cvvController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Please fill all the Credit/Debit Card details.')),
                      );
                      return;
                    }
                  }

                  // Validate fields for UPI
                  if (selectedPaymentMethod == 'UPI') {
                    if (_upiIdController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill the UPI ID.')),
                      );
                      return;
                    }
                  }

                  // Call submitOrder API after validation
                  await submitOrder(
                    paymentMethod: selectedPaymentMethod,
                    addressId: defaultAddress?.id ?? '',
                    cardNumber: _cardNumberController.text,
                    cardHolderName: _cardHolderNameController.text,
                    expiryDate: _expiryDateController.text,
                    cvv: _cvvController.text,
                    upiId: _upiIdController.text,
                  );
                },
                child: Text(
                  'Review and Submit Order',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create text fields
  Widget _buildTextField(
    String label,
    TextInputType keyboardType, {
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool showCounter = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        counterText: showCounter ? null : '',
      ),
    );
  }

  void toggleExpanded(String paymentMethod) {
    setState(() {
      isExpandedCreditDebitCard = paymentMethod == 'Credit/Debit Card';
      isExpandedUPI = paymentMethod == 'UPI';
    });
  }
}

// Custom TextInputFormatter to handle MM/YY input
class ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits and a forward slash
    String newText = newValue.text.replaceAll('/', '');

    if (newText.length >= 4) {
      newText = newText.substring(0, 4); // Limit to 4 digits (MMYY)
    }

    // Insert / after 2 digits
    if (newText.length >= 2) {
      newText = newText.substring(0, 2) + '/' + newText.substring(2);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AddressSelectionScreen extends StatelessWidget {
  final List<Address> addresses;
  final Function(Address) onSelectAddress;

  AddressSelectionScreen(
      {required this.addresses, required this.onSelectAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle("Select Address"),
      body: addresses.isEmpty
          ? Center(child: Text('No addresses available.'))
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(address.addressLine),
                    subtitle:
                        address.isDefault ? Text('(Default Address)') : null,
                    onTap: () {
                      onSelectAddress(
                          address); // Call the callback to select the address
                      Navigator.pop(
                          context, true); // Go back to the CheckoutScreen
                    },
                  ),
                );
              },
            ),
    );
  }
}


class OrderSuccessScreen extends StatefulWidget {
  @override
  _OrderSuccessScreenState createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  final GlobalKey<CartScreenState> _cartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pop two screens off the navigation stack
        Navigator.of(context).pop(); // First pop
        await Future.delayed(const Duration(milliseconds: 100)); // Delay for animation
        Navigator.of(context).pop(); // Second pop
        return false; // Prevent the default back action
      },
      child: Scaffold(
        appBar: AppStyles.appBarStyle("Order Status"),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle, // Success icon
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Thank you for your order!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // Access NavBarWidget's state to update the navigation index
                  final navBarWidgetState =
                      context.findAncestorStateOfType<NavBarWidgetState>();

                  // First, refresh the Cart screen if necessary
                  if (_cartKey.currentState != null) {
                    _cartKey.currentState!.refresh(); // Assuming refresh() exists in CartScreenState
                  }

                  // Switch to the HomeScreen by updating the NavBar index to 0
                  if (navBarWidgetState != null) {
                    navBarWidgetState.updateCurrentIndex(0); // Set index to 0 for HomeScreen
                  }

                  // Pop two screens off the navigation stack and wait for the pop to complete
                  Navigator.of(context).pop(); // First pop
                  await Future.delayed(const Duration(milliseconds: 100)); // Delay to allow pop animation
                  Navigator.of(context).pop(); // Second pop
                },
                child: Text('Continue Shopping'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.yellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

