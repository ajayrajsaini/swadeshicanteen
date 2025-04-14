import 'dart:convert';
import 'package:ajio_mart/theme/app_colors.dart';
import 'package:ajio_mart/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/utils/user_global.dart' as globals;

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productDetails; // Store product details
  int quantityInCart = 0; // To track quantity of the product in the cart
  bool isLoading = true;
  bool hasError = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchProductDetails(); // Fetch product details when the screen is initialized
    checkIfProductInCart(); // Check if the product is already in the cart
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
        checkIfProductInCart(); // Refresh cart data after update
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final response =
          await http.get(Uri.parse(APIConfig.getProduct + widget.productId));
      if (response.statusCode == 200) {
        setState(() {
          productDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching product details: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> checkIfProductInCart() async {
    try {
      final cartResponse = await http.get(Uri.parse(
          APIConfig.getAllItemInCart + globals.userContactValue.toString()));
      if (cartResponse.statusCode == 200) {
        final cartData = json.decode(cartResponse.body);
        List<dynamic> cartItems = cartData['items'] ?? [];
        final cartItem = cartItems.firstWhere(
            (item) => item['productId'] == widget.productId,
            orElse: () => null);
        if (cartItem != null) {
          setState(() {
            quantityInCart = cartItem['quantity'];
          });
        }
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error checking product in cart: $e');
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
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          quantityInCart += quantity;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Product added to cart!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add product to cart!')));
      }
    } catch (error) {
      print('Error adding product to cart: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong!')));
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
          quantityInCart = 0; // Remove the item from the list
        });
        checkIfProductInCart(); // Refresh cart data after update
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  void updateCartQuantity(int newQuantity) {
    setState(() {
      quantityInCart = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppStyles.appBarStyle("Product Details"),
        body: Center(child: CircularProgressIndicator()), // Loading indicator
      );
    }

    if (hasError || productDetails == null) {
      return Scaffold(
        appBar: AppStyles.appBarStyle("Product Details"),
        body: Center(
          child: Text('Failed to load product details',
              style: TextStyle(color: Colors.red, fontSize: 18)),
        ),
      );
    }

    final isInStock = productDetails!['stock'] > 0;
    final double mrp =
        (productDetails!['mrp'] != null && productDetails!['mrp'] is num)
            ? productDetails!['mrp'].toDouble()
            : 0.0;
    final double price =
        (productDetails!['price'] != null && productDetails!['price'] is num)
            ? productDetails!['price'].toDouble()
            : 0.0;

    // Safeguard to avoid division by zero and ensure discount is a valid percentage
    final int discountPercentage =
        (mrp > 0) ? ((mrp - price) / mrp * 100).round() : 0;

    return Scaffold(
      appBar: AppStyles.appBarStyle("Product Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with shadow and error handling
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 244, 243, 241),
                    const Color.fromARGB(255, 194, 202, 194)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16), // Rounded edges
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 4 / 3, // Maintain a 4:3 aspect ratio
                      child: PageView.builder(
                        itemCount: 1 +
                            ((productDetails?['additionalImages']?.length ?? 0)
                                as int),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          // Combine imageUrl and additionalImages into a single source
                          final imageUrl = index == 0
                              ? productDetails!['imageUrl']
                              : productDetails!['additionalImages'][index - 1];

                          return Image.network(
                            imageUrl ?? APIConfig.logoUrl,
                            fit: BoxFit.contain, // Maintain aspect ratio
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                APIConfig.logoUrl,
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      1 +
                          ((productDetails?['additionalImages']?.length ?? 0)
                              as int),
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Product name
            Text(
              productDetails!['name'] ?? 'Unknown Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    const Color.fromARGB(255, 17, 15, 13), // Color of the text
              ),
            ),
            SizedBox(height: 8),

            // Discount badge above the price
            if (discountPercentage > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.orangeAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$discountPercentage% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 5),
            ],

            // Price, MRP, and discount
            Row(
              children: [
                Text(
                  '₹$price',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                SizedBox(width: 8),
                if (mrp > price)
                  Text(
                    '₹$mrp',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 5),

            // Stock availability
            Text(
              isInStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                  fontSize: 18, color: isInStock ? Colors.green : Colors.red),
            ),
            SizedBox(height: 5),

            Row(
              children: List.generate(5, (starIndex) {
                if (starIndex < productDetails!['rating'].floor()) {
                  // Full stars for the integer part of the rating
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 25.0,
                  );
                } else if (starIndex == productDetails!['rating'].floor() &&
                    productDetails!['rating'] % 1 != 0) {
                  // Half star for the decimal part (if rating is not a whole number)
                  return Icon(
                    Icons.star_half,
                    color: Colors.amber,
                    size: 25.0,
                  );
                } else {
                  // Empty stars for the rest
                  return Icon(
                    Icons.star_border,
                    color: Colors.amber,
                    size: 25.0,
                  );
                }
              }),
            ),

            // Product rating and rating count
            Text(
              '(${productDetails!['ratingCount']} ratings)',
              style: TextStyle(fontSize: 10),
            ),
            SizedBox(height: 5),

            // Add to Cart section
            quantityInCart > 0
                ? Opacity(
                    opacity: isInStock ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !isInStock,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 214, 213, 213),
                                  width: 1), // Narrower border, increased width
                              borderRadius: BorderRadius.circular(
                                  45), // Adjusted radius for a sleeker look
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius:
                                      2, // Slightly increased blur for better visual effect
                                  offset: Offset(
                                      3, 3), // More pronounced shadow offset
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center contents horizontally
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    color: Colors.green,
                                    onPressed: quantityInCart > 1
                                        ? () {
                                            updateQuantity(widget.productId,
                                                quantityInCart - 1);
                                          }
                                        : () {
                                            deleteItem(widget.productId);
                                          },
                                  ),
                                  Text(
                                    '$quantityInCart',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    color: Colors.green,
                                    onPressed: isInStock
                                        ? () {
                                            updateQuantity(widget.productId,
                                                quantityInCart + 1);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Opacity(
                    opacity: isInStock ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !isInStock,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isInStock ? AppColors.buttonColor : Colors.grey,
                          shadowColor: Colors.black38,
                          elevation: 5,
                        ),
                        onPressed: isInStock
                            ? () {
                                addToCart(context, widget.productId, 1);
                              }
                            : null,
                        child: Text('Add to Cart'),
                      ),
                    ),
                  ),
            SizedBox(height: 5),

            // Product description
            Text(
              productDetails!['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify, // Align text to justify
            ),
          ],
        ),
      ),
    );
  }
}
