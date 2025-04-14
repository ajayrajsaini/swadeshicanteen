import 'dart:convert';
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/models/product_model.dart'; // Assuming this model exists
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CategoryHomeWidget extends StatefulWidget {
  final String heading;
  final String description;
  final String categoryId;
  final int numberOfProducts;

  CategoryHomeWidget({
    required this.heading,
    required this.description,
    required this.categoryId,
    required this.numberOfProducts,
  });

  @override
  _CategoryHomeWidgetState createState() => _CategoryHomeWidgetState();
}

class _CategoryHomeWidgetState extends State<CategoryHomeWidget> {
  List<Product> products = [];
  bool isLoading = true;
  bool showViewAll = true;

  @override
  void initState() {
    super.initState();
    fetchProduct(widget.categoryId);
  }

  void onViewAllTap() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ProductScreen(
        products: products,
        categoryName: widget.heading,
      ),
      withNavBar: true,
    );
  }

  Future<void> fetchProduct(String categoryId) async {
    try {
      final url = APIConfig.getAllProductsInCategory + categoryId;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic>? data = json.decode(response.body);

        if (data != null && data.isNotEmpty) {
          products.clear();
          for (var item in data) {
            final product = Product.fromJson(item);
            products.add(product);
          }
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty && !isLoading) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading and "View All" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.heading,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700], // Darker amber for contrast
                ),
              ),
              if (showViewAll && onViewAllTap != null)
                GestureDetector(
                  onTap: onViewAllTap,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[600], // Softer teal
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Horizontal list of products
        isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                height: 240,
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          'No products available.',
                          style: TextStyle(color: Colors.amber[600]),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.numberOfProducts < products.length
                            ? widget.numberOfProducts + (showViewAll ? 1 : 0)
                            : products.length,
                        itemBuilder: (context, index) {
                          if (index < widget.numberOfProducts &&
                              index < products.length) {
                            return _buildProductCard(products[index]);
                          } else if (showViewAll &&
                              index == widget.numberOfProducts) {
                            return _buildViewAllButton();
                          }
                          return SizedBox.shrink();
                        },
                      ),
              ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    double discountPercentage = 0;
    if (product.mrp > product.price && product.mrp > 0) {
      discountPercentage = ((product.mrp - product.price) / product.mrp) * 100;
    }

    return InkWell(
      onTap: () {
        if (product.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.amber[50]!,
              Colors.amber[100]!
            ], // Light amber gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? product.imageUrl!
                    : 'https://via.placeholder.com/150',
                fit: BoxFit.contain,
                height: 120,
                width: 190,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  'https://via.placeholder.com/150',
                  fit: BoxFit.contain,
                            height: 120,
                            width: 190,
                ),
              ),
            ),
            SizedBox(height: 10),
            if (product.name != null)
              Text(
                product.name!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800], // Darker text for readability
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (product.mrp != null)
                  Text(
                    '\₹${product.mrp!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                SizedBox(width: 5),
                if (product.price != null)
                  Text(
                    '\₹${product.price!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700], // Softer teal for price
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4),
            if (discountPercentage > 0)
              Text(
                '${discountPercentage.toStringAsFixed(1)}% off',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return InkWell(
      onTap: onViewAllTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 80,
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal[100]!,
              Colors.teal[200]!
            ], // Light teal gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'View All',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
