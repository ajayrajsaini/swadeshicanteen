class SpecialList {
  final String id;
  final String title;
  final int numberOfProducts;
  final bool showViewAll;
  final List<String> productIdList;

  SpecialList({
    required this.id,
    required this.title,
    required this.numberOfProducts,
    required this.showViewAll,
    required this.productIdList,
  });

  factory SpecialList.fromJson(Map<String, dynamic> json) {
    return SpecialList(
      id: json['_id'] as String,
      title: json['title'] as String,
      numberOfProducts: json['numberOfProducts'] as int,
      showViewAll: json['showViewAll'] as bool,
      productIdList: List<String>.from(json['products'] ?? []), // Ensure this is a List<String>
    );
  }
}
