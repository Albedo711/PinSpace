import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class UserService {
  final Dio _dio = Dio();
  final String baseUrl = "http://127.0.0.1:8000/api";

  // ---------------------- GET USER PROFILE ----------------------
  Future<UserModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    final response = await _dio.get(
      "$baseUrl/user/profile",
      options: Options(headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception("Gagal mengambil profil user");
    }
  }

  // ---------------------- UPDATE USER PROFILE ----------------------
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? avatarPath,
    Uint8List? avatarBytes, // untuk Web
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    final formData = FormData();

    if (name != null) formData.fields.add(MapEntry('name', name));
    if (email != null) formData.fields.add(MapEntry('email', email));
    if (bio != null) formData.fields.add(MapEntry('bio', bio));

    // Avatar
    if (avatarBytes != null) {
      // Web
      formData.files.add(MapEntry(
        'avatar',
        MultipartFile.fromBytes(
          avatarBytes,
          filename: 'avatar.png',
          contentType: MediaType('image', 'png'),
        ),
      ));
    } else if (avatarPath != null) {
      // Android/iOS
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(
          avatarPath,
          filename: avatarPath.split('/').last,
          // contentType bisa ditambahkan jika perlu, misal image/png
        ),
      ));
    }

    final response = await _dio.post(
      "$baseUrl/user/profile", // POST method sudah benar untuk file upload
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception("Gagal memperbarui profil user");
    }
  }

  // ---------------------- LOGOUT ----------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // hapus token & data user
  }
}
