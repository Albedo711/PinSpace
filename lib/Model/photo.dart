class Photo {
  final int id;
  final String title;
  final String? description;
  final String imagePath;
  final String category;
  final int width;
  final int height;
  final int userId;
  final String? userName; 
  final bool liked;      // <--- baru
  final int likeCount;   // <--- baru

  Photo({
    required this.id,
    required this.title,
    this.description,
    required this.imagePath,
    required this.category,
    required this.width,
    required this.height,
    required this.userId,
    this.userName,
    this.liked = false,
    this.likeCount = 0,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? "",
      description: json['description']?.toString(),
      imagePath: json['image_path']?.toString() ?? "",
      category: json['category']?.toString() ?? "",
      width: int.tryParse(json['width'].toString()) ?? 0,
      height: int.tryParse(json['height'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      userName: json['user']?['name'],
      liked: json['liked'] ?? false,          // <--- ambil dari API
      likeCount: json['like_count'] ?? 0,     // <--- ambil dari API
    );
  }
}
