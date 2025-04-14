class SuperCategory {
  final String id;
  final String superCategoryId;
  final String name;
  final String imageUrl;

  SuperCategory({required this.id, required this.superCategoryId, required this.name, required this.imageUrl});

  factory SuperCategory.fromJson(Map<String, dynamic> json) {
    return SuperCategory(
      id: json['_id'],
      superCategoryId: json['superCategoryId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
