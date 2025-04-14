class Carousel {
  final String id;
  final String title;
  final List<String> imageUrl;
  final String description;
  final String route;

  Carousel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.route,
  });

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      id: json['_id'],
      title: json['title'],
      imageUrl: List<String>.from(json['imageUrl']),
      description: json['description'],
      route: json['route'],
    );
  }
}
