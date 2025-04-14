import 'package:ajio_mart/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:ajio_mart/models/product_model.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> products;

  const SearchScreen({Key? key, required this.products}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<Product> displayedProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _searchController.addListener(_filterProducts);
    isLoading = false; // Assuming data is loaded
    displayedProducts = widget.products; // Initially show all products
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        displayedProducts = widget.products; // Show all products when search is empty
      } else {
        displayedProducts = widget.products.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // No shadow for a cleaner look
        title: Container(
          height: 50, // Adjust height for a better look
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 3,
                blurRadius: 10,
                offset: Offset(0, 5), // 3D effect with shadow offset
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search Products...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              contentPadding: EdgeInsets.symmetric(vertical: 15), // Center text
            ),
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : displayedProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No products match your search.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductItem(displayedProducts[index]);
                  },
                ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              product.imageUrl ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: ₹${product.price}'), // Only price info shown
        onTap: () {
          // Handle the product tap event here
          // For example, navigate to the product details page or show a dialog
          _onProductTap(product);
        },
      ),
    );
  }

  void _onProductTap(Product product) {
    // Example of navigating to another page with product details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }
}


