import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeliveryBoyScreen extends StatefulWidget {
  final String userId; // Pass the delivery boy's user ID
  DeliveryBoyScreen({required this.userId});

  @override
  _DeliveryBoyScreenState createState() => _DeliveryBoyScreenState();
}

class _DeliveryBoyScreenState extends State<DeliveryBoyScreen> {
  List<dynamic> orders = [];
  
  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // Fetch orders assigned to the delivery boy
  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(APIConfig.getAllOrders));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orders = (data['orders'] as List<dynamic>).where((order) {
          return order['assignedDeliveryBoy'] == widget.userId &&
              order['orderStatus'] != 'Delivered'; // Exclude delivered orders
        }).toList();
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final response = await http.put(
      Uri.parse(APIConfig.updateOrder + orderId),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"orderStatus": newStatus}),
    );

    if (response.statusCode == 200) {
      fetchOrders(); // Refresh the list of orders
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } else {
      throw Exception('Failed to update order status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Orders'),
        backgroundColor: Colors.blueAccent,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders, // Call fetchOrders on pull to refresh
        child: orders.isEmpty
            ? Center(
                child: Text(
                  'No assigned orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${order['_id']}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text('Total Price: ₹${order['totalPrice']}',
                              style: TextStyle(fontSize: 16)),
                          Text('Delivery Address: ${order['deliveryAddress']}',
                              style: TextStyle(fontSize: 14)),
                          Text('Payment Method: ${order['paymentMethod']}',
                              style: TextStyle(fontSize: 14)),
                          SizedBox(height: 15),
                          Text('Current Status: ${order['orderStatus']}',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => updateOrderStatus(order['_id'], 'Processing'),
                                child: Text('Processing'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: order['orderStatus'] == 'Processing' ? Colors.orange : Colors.grey,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => updateOrderStatus(order['_id'], 'Shipped'),
                                child: Text('Shipped'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: order['orderStatus'] == 'Shipped' ? Colors.blue : Colors.grey,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => updateOrderStatus(order['_id'], 'Delivered'),
                                child: Text('Delivered'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: order['orderStatus'] == 'Delivered' ? Colors.green : Colors.grey,
                                ),
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
    );
  }
}
