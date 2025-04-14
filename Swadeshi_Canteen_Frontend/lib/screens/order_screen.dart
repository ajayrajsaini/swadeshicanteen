import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/theme/app_style.dart';
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> orders = [];
  Map<String, dynamic> productDetails = {};

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    final response = await http.get(Uri.parse(
        APIConfig.getAllOrders + globals.userContactValue.toString()));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['orders'] is List) {
        setState(() {
          orders = data['orders'].reversed.toList();
        });

        for (var order in orders) {
          if (order['items'].isNotEmpty) {
            String productId = order['items'][0]['productId'];
            fetchProductDetails(productId, order['_id']);
          }
        }
      } else {
        print('Expected a list of orders but got: ${data['orders']}');
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> fetchProductDetails(String productId, String orderId) async {
    final response =
        await http.get(Uri.parse(APIConfig.getProduct + productId));

    if (response.statusCode == 200) {
      final productData = json.decode(response.body);
      setState(() {
        productDetails[orderId] = {
          'name': productData['name'] ?? 'Unknown Product',
          'imageUrl': productData['imageUrl'] ?? '',
        };
      });
    } else {
      print('Failed to load product details');
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle;
      case 'Processing':
        return Icons.sync;
      case 'Shipped':
        return Icons.local_shipping;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.error;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.orange;
      case 'Pending':
        return Colors.yellow;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Text _getDeliveryMessage(String status, DateTime? deliveryDate) {
    String message;
    Color color;

    if (status == 'Cancelled') {
      message = 'Order Cancelled';
      color = Colors.red;
    } else if (status == 'Delivered') {
      message =
          'Delivered on ${deliveryDate?.toLocal().toString().split(' ')[0]}';
      color = Colors.green;
    } else if (deliveryDate == null) {
      message = 'Arriving Soon';
      color = Colors.orange;
    } else {
      message =
          'Arriving on ${deliveryDate?.toLocal().toString().split(' ')[0]}';
      color = Colors.blue;
    }

    return Text(
      message,
      style: TextStyle(color: color, fontSize: 14),
    );
  }

  Future<void> _onRefresh() async {
    await fetchOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle("Orders"),
      body: Container(
        color: const Color.fromARGB(
            255, 237, 236, 236), // Background color for the entire screen
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    "No orders available",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF333333),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final deliveryDate = order['deliveredAt'] != null
                        ? globals.convertGmtToIst(DateTime.parse(order['deliveredAt']).toLocal()) 
                        : null;
                    final orderId = order['_id'];
                    final productDetail = productDetails[orderId];
                    final orderStatus = order['orderStatus'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              productDetail != null &&
                                      productDetail['imageUrl'] != null
                                  ? productDetail['imageUrl']
                                  : APIConfig.logoUrl,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  APIConfig.logoUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          title: Text(
                            order['items'].length > 1 && productDetail != null
                                ? '${productDetail['name']}...and more'
                                : productDetail != null
                                    ? productDetail['name']
                                    : 'Loading...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _getDeliveryMessage(orderStatus, deliveryDate),
                              SizedBox(height: 4),
                              Text(
                                'To: ${order['deliveryAddress'] ?? 'Unknown Address'}',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Icon(
                            _getStatusIcon(orderStatus),
                            color: _getStatusColor(orderStatus),
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
