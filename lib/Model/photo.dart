class Photo {
  final int id;
  final String title;
  final String? description;
  final String imagePath;
  final String category;
  final int width;
  final int height;

  Photo({
    required this.id,
    required this.title,
    this.description,
    required this.imagePath,
    required this.category,
    required this.width,
    required this.height,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imagePath: json['image_path'],
      category: json['category'],
      width: json['width'],
      height: json['height'],
    );
  }
}
