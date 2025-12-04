import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

class UserService {
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.1.3:8000/api";

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
    String? avatarPath, // URL atau path baru avatar
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    final formData = FormData.fromMap({
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (bio != null) "bio": bio,
      if (avatarPath != null) "avatar": avatarPath,
    });

    final response = await _dio.post(
      "$baseUrl/user/profile",
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
