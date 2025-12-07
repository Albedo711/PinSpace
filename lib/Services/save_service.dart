import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/photo.dart';

class SaveService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  /// Ambil semua foto yang sudah disimpan user
  Future<List<Photo>> getSavedPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login kembali.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/user/saves"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Cek struktur response dari API
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final paginationData = jsonData['data'];
        final List photoList = paginationData['data'] ?? [];
        
        // Mapping data - perhatikan struktur relasi dari controller
        return photoList.map((item) {
          // Jika data sudah berupa Photo langsung
          if (item['photo'] != null) {
            return Photo.fromJson(item['photo']);
          }
          // Jika data adalah Photo langsung
          return Photo.fromJson(item);
        }).toList();
      } else {
        throw Exception("Format response tidak valid");
      }
    } else if (response.statusCode == 401) {
      throw Exception("Sesi login telah berakhir. Silakan login kembali.");
    } else {
      throw Exception("Gagal mengambil saved photos (${response.statusCode})");
    }
  }

  /// Simpan / unsave foto (toggle)
  Future<Map<String, dynamic>> savePhoto(int photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/photos/$photoId/save"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal save photo");
    }
  }

  /// Cek apakah foto sudah disimpan user
  Future<bool> isPhotoSaved(int photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/photos/$photoId/is-saved"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['saved'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error checking save status: $e");
      return false;
    }
  }
}