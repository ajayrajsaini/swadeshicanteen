import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/theme/app_colors.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:ajio_mart/utils/user_global.dart" as globals;
import 'dart:convert';
import 'package:ajio_mart/screens/product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  final List<dynamic> products;
  final String categoryName;

  const ProductScreen({
    Key? key,
    required this.products,
    required this.categoryName,
  }) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Map<String, int> cart = {}; // To store productId and its quantity in the cart
  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    fetchCartState(); // Fetch cart state when the screen loads
  }

  // Method to fetch the cart data from the server
  Future<void> fetchCartState() async {
    final String apiUrl =
        APIConfig.getAllItemInCart + globals.userContactValue.toString();
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final cartData = jsonDecode(response.body);
        setState(() {
          var items = cartData['items'];
          cart = {for (var item in items) item['productId']: item['quantity']};
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }
  // Future<void> fetchCartState() async {
  //   final String apiUrl = APIConfig.getAllItemInCart +
  //       globals.userContactValue.toString(); // Endpoint to get cart items

  //   try {
  //     final response = await http.get(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print(data);
  //       // Parse the response and populate the cart with productId and quantity
  //       setState(() {
  //         cart = {
  //           for (var item in data['cartItems'])
  //             item['productId']: item['quantity']
  //         };
  //         isLoading = false;
  //       });
  //     } else {
  //       throw Exception('Failed to load cart');
  //     }
  //   } catch (error) {
  //     print('Error fetching cart: $error');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Method to add product to cart
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
          cart[productId] = quantity;
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

  // Method to update product quantity in cart
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
          cart[itemId] = newQuantity;
        });
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Method to delete a product from cart
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
          cart.remove(itemId); // Remove the item from the list
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
      appBar: AppStyles.appBarStyle(widget.categoryName),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: widget.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final product = widget.products[index];
                final String productId = product.id;
                final int rating = product.rating ?? 0;
                final double price = product.price ?? 0;
                final double mrp = product.mrp ?? 0; // Get MRP
                final bool isInStock =
                    product.stock != null && product.stock > 0;
                final int quantityInCart = cart[productId] ?? 0;

                // Calculate discount percentage
                double discountPercentage = 0;
                if (mrp > price && mrp > 0) {
                  discountPercentage = ((mrp - price) / mrp) * 100;
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize.min, // Adjust size based on content
                        children: [
                          Image.network(
                            (product.imageUrl != null &&
                                    product.imageUrl.isNotEmpty)
                                ? product.imageUrl!
                                : APIConfig.logoUrl,
                            fit: BoxFit.contain,
                            height: 100,
                            width: 170,
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            product.name ?? 'Unknown Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2, // Limit to 2 lines
                            overflow:
                                TextOverflow.ellipsis, // Truncate with "..."
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            children: List.generate(5, (starIndex) {
                              if (starIndex < rating.floor()) {
                                // Full stars for the integer part of the rating
                                return Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16.0,
                                );
                              } else if (starIndex == rating.floor() &&
                                  rating % 1 != 0) {
                                // Half star for the decimal part (if rating is not a whole number)
                                return Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 16.0,
                                );
                              } else {
                                // Empty stars for the rest
                                return Icon(
                                  Icons.star_border,
                                  color: Colors.amber,
                                  size: 16.0,
                                );
                              }
                            }),
                          ),
                          SizedBox(height: 5.0),
                          // MRP and Discounted Price
                          Row(
                            children: [
                              if (mrp > 0)
                                Text(
                                  "\₹ $mrp",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              SizedBox(width: 5),
                              Text(
                                "\₹ $price",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          // Display discount percentage if applicable
                          if (discountPercentage > 0)
                            Text(
                              '${discountPercentage.toStringAsFixed(1)}% off',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          SizedBox(height: 4.0),
                          Text(
                            isInStock ? "In Stock" : "Out of Stock",
                            style: TextStyle(
                              color: isInStock ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          // Add to Cart or Quantity Controls
                          quantityInCart > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Opacity(
                                        opacity: isInStock
                                            ? 1.0
                                            : 0.4, // Reduce opacity when out of stock
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              color: Colors.green,
                                              onPressed: isInStock &&
                                                      quantityInCart > 1
                                                  ? () {
                                                      updateQuantity(productId,
                                                          quantityInCart - 1);
                                                    }
                                                  : isInStock &&
                                                          quantityInCart == 1
                                                      ? () {
                                                          deleteItem(productId);
                                                        }
                                                      : null, // Disable when out of stock
                                            ),
                                            Text(
                                              '$quantityInCart',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              color: Colors.green,
                                              onPressed: isInStock
                                                  ? () {
                                                      updateQuantity(productId,
                                                          quantityInCart + 1);
                                                    }
                                                  : null, // Disable when out of stock
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton(
                                  onPressed: isInStock
                                      ? () {
                                          addToCart(context, productId, 1);
                                        }
                                      : null,
                                  child: Text('Add to Cart'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInStock
                                        ? AppColors.buttonColor
                                        : Colors.grey,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
