class Board {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String? coverImage;
  final int photosCount;

  Board({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverImage,
    required this.photosCount,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      coverImage: json['cover_image'],
      photosCount: json['photos_count'] ?? 0,
    );
  }
}
