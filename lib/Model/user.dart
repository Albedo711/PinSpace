class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
  });

  // Convert JSON → Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
    );
  }

  // Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'bio': bio,
    };
  }
}
