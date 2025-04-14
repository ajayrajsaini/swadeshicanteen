import 'package:flutter/material.dart';
import 'package:ajio_mart/api_config.dart';
import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:ajio_mart/screens/product_list_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ajio_mart/models/product_model.dart';

class SpecialHomeWidget extends StatefulWidget {
  final String heading;
  final List<String> products;
  final int numberOfProducts;
  final bool showViewAll;

  SpecialHomeWidget({
    required this.heading,
    required this.products,
    required this.numberOfProducts,
    required this.showViewAll,
  });

  @override
  _SpecialHomeWidgetState createState() => _SpecialHomeWidgetState();
}

class _SpecialHomeWidgetState extends State<SpecialHomeWidget> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduct(widget.products);
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

  Future<void> fetchProduct(List<String> productIds) async {
    try {
      for (var productId in productIds) {
        final url = APIConfig.getProduct + productId;
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final product = Product.fromJson(data);
          products.add(product);
        } else {
          print('Failed to load product: ${response.statusCode}');
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.amber.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading and "View All" button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.heading,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (widget.showViewAll)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.amberAccent,
                    child: InkWell(
                      onTap: onViewAllTap,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Horizontal list of products
          Container(
            height: 280,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.numberOfProducts < products.length
                        ? widget.numberOfProducts
                        : products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    double discountPercentage = 0;
    if (product.mrp > product.price && product.mrp > 0) {
      discountPercentage = ((product.mrp - product.price) / product.mrp) * 100;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.amber.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.contain,
                            height: 120,
                            width: 160,
              ),
            ),
            SizedBox(height: 8),
            // Product Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            // Price and MRP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (product.mrp > product.price)
                  Text(
                    '\₹${product.mrp.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                SizedBox(width: 5),
                Text(
                  '\₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            // Discount Badge
            if (discountPercentage > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amberAccent, Colors.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${discountPercentage.toStringAsFixed(1)}% OFF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
