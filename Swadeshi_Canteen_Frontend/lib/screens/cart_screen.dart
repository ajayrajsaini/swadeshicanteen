import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  String errorMessage = '';
  int totalAmount = 0;
  int deliveryCharge = 0;
  int deliveryFreeAtAmount = 1000;

  void refresh() {
    fetchCartItems();
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    calculateDeliveryCharges();
    try {
      final response = await http.get(
        Uri.parse(
            APIConfig.getAllItemInCart + globals.userContactValue.toString()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body)['items'];
        await fetchProductDetails(items);
      } else {
        throw Exception('Failed to load cart items. Please try again later.');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching cart items: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductDetails(List<dynamic> items) async {
    List<dynamic> detailedItems = [];

    try {
      for (var item in items) {
        final productResponse = await http.get(
          Uri.parse(APIConfig.getProduct + item['productId'].toString()),
        );

        if (productResponse.statusCode == 200) {
          final product = jsonDecode(productResponse.body);
          detailedItems.add({
            '_id': product['_id'],
            'id': item['productId'],
            'name': product['name'] ?? 'Unknown Product',
            'price': item['price'],
            'quantity': item['quantity'],
            'imageUrl': product['imageUrl'] ?? "",
            'stock': product['stock'],
          });
        } else {
          throw Exception(
              'Failed to load product details for product ID ${item['productId']}');
        }
      }

      setState(() {
        cartItems = detailedItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching product details: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(String itemId, int index) async {
    try {
      final response = await http.delete(
        Uri.parse(APIConfig.deleteProductFromCart + itemId),
        headers: {
          'Content-Type': 'application/json',
          'user': globals.userContactValue.toString()
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeAt(index);
        });
        fetchCartItems();
      } else {
        throw Exception('Failed to delete item. Please try again later.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse(APIConfig.updateQuantityInCart),
        body: jsonEncode({
          "user": globals.userContactValue,
          "productId": itemId,
          "quantity": newQuantity
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        throw Exception('Failed to update quantity. Please try again later.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating quantity: $e')),
      );
    }
  }

  int calculateTotalPrice() {
    return cartItems.fold(0, (total, item) {
      return (total + int.parse(item['price'])).toInt();
    });
  }

  calculateDeliveryCharges() async {
    final url = Uri.parse(APIConfig.deliveryCharges);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        deliveryCharge = responseData['delivery_fee'] ??
            0; // Ensure you handle missing data gracefully
        deliveryFreeAtAmount = responseData['min_free_delivery'] ?? 1000;
      } else {
        print(
            'Failed to fetch delivery charges. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching delivery charges: $e');
    }
  }

  Future<void> checkOutOfStockItems() async {
    final outOfStockItems =
        cartItems.where((item) => item['stock'] <= 0).toList();

    if (outOfStockItems.isNotEmpty) {
      // Show the dialog if there are out-of-stock items
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Some items are out of stock"),
            content: Text("Do you want to remove out-of-stock items?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Remove all out-of-stock items
                  for (var item in outOfStockItems) {
                    await deleteItem(item['id'], cartItems.indexOf(item));
                  }
                  fetchCartItems(); // Refresh cart data after deletion
                },
                child: Text("Remove"),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckoutScreen(
                  cartItems: cartItems,
                )),
      ).then((_) => fetchCartItems());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle("Your Cart"),
      body: RefreshIndicator(
        onRefresh: fetchCartItems,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child:
                        Text(errorMessage, style: TextStyle(color: Colors.red)))
                : cartItems.isEmpty
                    ? ListView(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Your cart is empty!',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 20),
                                  Image.asset(
                                    'assets/images/emptyCart.png',
                                    height: 200,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return Card(
                                  margin: EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            item['imageUrl'] != null &&
                                                    item['imageUrl'].isNotEmpty
                                                ? item['imageUrl']
                                                : APIConfig.logoUrl,
                                            fit: BoxFit.contain,
                                            height: 80,
                                            width: 80,
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                              return Image.network(
                                                APIConfig.logoUrl,
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 80,
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item['name'],
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text('₹${item['price']}'),
                                              Text(
                                                item['stock'] > 0
                                                    ? ''
                                                    : 'Out of stock',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: item['stock'] >
                                                                0 &&
                                                            item['quantity'] > 1
                                                        ? () {
                                                            updateQuantity(
                                                                item['id'],
                                                                item['quantity'] -
                                                                    1);
                                                          }
                                                        : null,
                                                  ),
                                                  Text('${item['quantity']}'),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: item['stock'] > 0
                                                        ? () {
                                                            updateQuantity(
                                                                item['id']
                                                                    .toString(),
                                                                item['quantity'] +
                                                                    1);
                                                          }
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            deleteItem(item['id'], index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (calculateTotalPrice() < deliveryFreeAtAmount)
                                        Text(
                                          'Add ₹${(deliveryFreeAtAmount - calculateTotalPrice())} for free delivery.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                    ]),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery Charges:',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '₹${(calculateTotalPrice() < deliveryFreeAtAmount ? deliveryCharge : 0)}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total:',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '₹${(calculateTotalPrice() + (calculateTotalPrice() < deliveryFreeAtAmount ? deliveryCharge : 0))}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: checkOutOfStockItems,
                                  child: Text('Place Order'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 50),
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
