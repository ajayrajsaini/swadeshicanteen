class Category {
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;

  Category({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      name: json['name'],
      description : json["description"],
      imageUrl: json['imageUrl'],
    );
  }
}
