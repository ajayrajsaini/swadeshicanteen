import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/theme/app_colors.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'dart:convert';
import 'package:ajio_mart/screens/product_detail_screen.dart';

class AllProductScreen extends StatefulWidget {
  const AllProductScreen({Key? key}) : super(key: key);

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<AllProductScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  // Map to store quantity of each product in the cart
  Map<String, int> productQuantities = {};

  void refresh() async {
    setState(() {
      isLoading = true;
    });
    await fetchCartAndProducts(); // Fetch cart and products when refreshing
  }

  @override
  void initState() {
    super.initState();
    fetchCartAndProducts();
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchCartAndProducts(); // Fetch cart and products when refreshing
  }

  // Fetch both products and cart data
  Future<void> fetchCartAndProducts() async {
    try {
      await Future.wait([fetchProducts(), fetchCart()]);
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getProduct));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCart() async {
    final String apiUrl =
        APIConfig.getAllItemInCart + globals.userContactValue.toString();
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final cartData = jsonDecode(response.body);
        setState(() {
          var items = cartData['items'];
          productQuantities = {
            for (var item in items) item['productId']: item['quantity']
          };
        });
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  Future<void> addToCart(
      BuildContext context, String productId, int quantity) async {
    final String apiUrl = APIConfig.addToCart;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({
          "user": globals.userContactValue,
          'productId': productId,
          'quantity': quantity,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          productQuantities[productId] =
              quantity; // Set the quantity in the cart
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added to cart!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product to cart!')),
        );
      }
    } catch (error) {
      print('Error adding product to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong!')),
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
        setState(() {
          productQuantities[itemId] = newQuantity; // Update quantity locally
        });
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
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
          productQuantities.remove(itemId); // Remove the item from the list
        });
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.appBarStyle("Products"),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final productId = product['productId'];
                  final double price = (product['price'] is int)
                      ? (product['price'] as int).toDouble()
                      : product['price'] ?? 0.0;

                  final double mrp = (product['mrp'] is int)
                      ? (product['mrp'] as int).toDouble()
                      : product['mrp'] ?? 0.0;

                  final int rating = product['rating'] ?? 0;
                  final bool isInStock = product['stock'] > 0;

                  final double discountPercentage = mrp > price
                      ? ((mrp - price) / mrp * 100).roundToDouble()
                      : 0.0;

                  final quantityInCart = productQuantities[productId] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(productId: productId),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize:
                              MainAxisSize.min, // Adjusts size based on content
                          children: [
                            Image.network(
                              product['imageUrl'] != null &&
                                      product['imageUrl'].isNotEmpty
                                  ? product['imageUrl']
                                  : APIConfig.logoUrl,
                              fit: BoxFit.contain,
                            height: 100,
                            width: 170,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.network(
                                  APIConfig.logoUrl, // Fallback image
                                  fit: BoxFit.contain,
                            height: 100,
                            width: 170,
                                );
                              },
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              product['name'] ?? 'Unknown Name of Product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2, // Limit to 2 lines
                              overflow: TextOverflow
                                  .ellipsis, // Add "..." if text overflows
                            ),
                            
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16.0,
                                );
                              }),
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Text(
                                  "\₹ ${price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                if (mrp > price)
                                  Text(
                                    "\₹ ${mrp.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            if (mrp > price)
                              Text(
                                '$discountPercentage% OFF',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: 5.0),
                            Text(
                              isInStock ? "In Stock" : "Out of Stock",
                              style: TextStyle(
                                color: isInStock ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            // Add to Cart / Increment / Decrement section
                            quantityInCart > 0
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          children: [
                                            Opacity(
                                              opacity: isInStock
                                                  ? 1.0
                                                  : 0.5, // Reduce opacity if out of stock
                                              child: IconButton(
                                                icon: Icon(Icons.remove),
                                                color: Colors.green,
                                                onPressed: isInStock &&
                                                        quantityInCart > 1
                                                    ? () {
                                                        updateQuantity(
                                                            productId,
                                                            quantityInCart - 1);
                                                      }
                                                    : isInStock &&
                                                            quantityInCart == 1
                                                        ? () {
                                                            deleteItem(
                                                                productId);
                                                          }
                                                        : null, // Disable if out of stock
                                              ),
                                            ),
                                            Text(
                                              '$quantityInCart',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: isInStock
                                                      ? Colors.green
                                                      : Colors.grey),
                                            ),
                                            Opacity(
                                              opacity: isInStock
                                                  ? 1.0
                                                  : 0.5, // Reduce opacity if out of stock
                                              child: IconButton(
                                                icon: Icon(Icons.add),
                                                color: Colors.green,
                                                onPressed: isInStock
                                                    ? () {
                                                        updateQuantity(
                                                            productId,
                                                            quantityInCart + 1);
                                                      }
                                                    : null, // Disable if out of stock
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: isInStock
                                        ? () {
                                            addToCart(context, productId, 1);
                                          }
                                        : null, // Disable button if out of stock
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isInStock
                                          ? AppColors.buttonColor
                                          : Colors.grey, // Fade color
                                    ),
                                    child: Text('Add to Cart'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
