class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double mrp; // New field for MRP
  final String imageUrl;
  final int? stock;
  final int? rating;
  final int? ratingCount;
  final String? categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.mrp, // Add MRP to constructor
    required this.imageUrl,
    this.stock,
    this.rating,
    this.ratingCount,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(), // Ensure price is a double
      mrp: (json['mrp'] as num).toDouble(), // Parse MRP as a double
      imageUrl: json['imageUrl'] as String,
      stock: json['stock']  ?? 0,
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      categoryId : json['categoryId'] ?? '0',
    );
  }
}
