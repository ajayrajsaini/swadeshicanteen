import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/models/product_model.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making API calls
import "package:ajio_mart/utils/user_global.dart" as globals;

class SubCategoryScreen extends StatefulWidget {
  final String superCategoryId;

  const SubCategoryScreen({
    Key? key,
    required this.superCategoryId,
  }) : super(key: key);

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<Map<String, dynamic>> subCategories = [];
  List<Product> products = [];
  String selectedCategory = "";
  Map<String, int> cart = {};
  bool isLoading = true;

  Future<void> _refreshData() async {
    fetchCartState();
    fetchSubCategories();
  }

  @override
  void initState() {
    super.initState();
    fetchCartState();
    fetchSubCategories();
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

  Future<void> fetchSubCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            APIConfig.getAllCategoriesInSuperCategory + widget.superCategoryId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subCategories = data
              .map((item) => {
                    'categoryId': item['categoryId'],
                    'imageUrl': item['imageUrl'] ?? '',
                    'name': item['name'] ?? '',
                  })
              .toList();

          if (subCategories.isNotEmpty) {
            selectedCategory = subCategories[0]['categoryId'];
            fetchProducts(selectedCategory);
          }
        });
      } else {
        throw Exception("Failed to load subcategories");
      }
    } catch (error) {
      print("Error fetching subcategories: $error");
    }
  }

  Future<void> fetchProducts(String category) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse(APIConfig.getAllProductsInCategory + category));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map((item) => Product.fromJson(item)).toList();
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (error) {
      print("Error fetching products: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addToCart(
      BuildContext context, String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse(APIConfig.addToCart),
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
      appBar: AppBar(
        title: Text('Subcategories'),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Row(
          children: [
            // Subcategory Menu
            Container(
              width: 100,
              color: Colors.grey[200],
              child: subCategories.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: subCategories.length,
                      itemBuilder: (context, index) {
                        final category = subCategories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category['categoryId'];
                            });
                            fetchProducts(selectedCategory);
                          },
                          child: Container(
                            color: selectedCategory == category['categoryId']
                                ? Colors.teal[100]
                                : Colors.transparent,
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    category['imageUrl'].isNotEmpty
                                        ? category['imageUrl']
                                        : 'https://via.placeholder.com/50',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  category['name'],
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Product Grid
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(5.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final String productId = product.id;
                        final double price = product.price ?? 0;
                        final double mrp = product.mrp ?? 0;
                        final bool isInStock =
                            product.stock != null && (product.stock ?? 0) > 0;
                        final int quantity = cart[productId] ?? 0;

                        double discountPercentage = 0;
                        if (mrp > price && mrp > 0) {
                          discountPercentage = ((mrp - price) / mrp) * 100;
                        }

                        return GestureDetector(
                            onTap: () {
                              // Navigate to the ProductDetailScreen when a product is tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                      productId: product.id),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              margin: EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Optional: Add rounded corners
                                        child: Image.network(
                                          product.imageUrl,
                                          height: 80,
                                          width: 140,
                                          fit: BoxFit
                                              .contain, // Change to contain to center the image fully
                                          // alignment: Alignment.center, // Align the image in the center
                                        ),
                                      ),
                                      if (discountPercentage > 0)
                                        Positioned(
                                          top: 2,
                                          left: 4,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            color: Colors.red,
                                            child: Text(
                                              '${discountPercentage.toStringAsFixed(1)}% OFF',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Product Details
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            if (mrp > 0)
                                              Text(
                                                "₹$mrp",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                            SizedBox(width: 6),
                                            Text(
                                              "₹$price",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          isInStock
                                              ? "In Stock"
                                              : "Out of Stock",
                                          style: TextStyle(
                                            color: isInStock
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Add to Cart / Quantity Buttons
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0), // Adjust padding here
                                    child: quantity > 0
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove,
                                                    size: 16),
                                                onPressed: isInStock &&
                                                        quantity > 1
                                                    ? () {
                                                        updateQuantity(
                                                            productId,
                                                            quantity - 1);
                                                      }
                                                    : isInStock && quantity == 1
                                                        ? () {
                                                            deleteItem(
                                                                productId);
                                                          }
                                                        : null,
                                              ),
                                              Text(
                                                '$quantity',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add, size: 16),
                                                onPressed: isInStock
                                                    ? () {
                                                        updateQuantity(
                                                            productId,
                                                            quantity + 1);
                                                      }
                                                    : null,
                                              ),
                                            ],
                                          )
                                        : Center(
                                            child: ElevatedButton(
                                              onPressed: isInStock
                                                  ? () {
                                                      addToCart(context,
                                                          productId, 1);
                                                    }
                                                  : null,
                                              child: Text(
                                                'Add',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isInStock
                                                    ? Colors.teal
                                                    : Colors.grey,
                                                minimumSize: Size(80, 30),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
