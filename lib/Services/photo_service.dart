import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../model/photo.dart';
import 'dart:io' as io;
import 'dart:convert';

class PhotoService {
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.100.44:8000/api";

  Future<List<Photo>> getPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    final response = await _dio.get(
      "$baseUrl/photos",
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    List data = response.data['data']['data'];
    return data.map((item) => Photo.fromJson(item)).toList();
  }

  Future<List<Photo>> getUserPhotos() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? "";

  final response = await _dio.get(
    "$baseUrl/user/photos",
    options: Options(
      headers: {"Authorization": "Bearer $token"},
    ),
  );

  // Ambil array foto dari data pagination
  List data = response.data['data']['data']; // <-- perhatikan 'data' di dalam 'data'
  return data.map((item) => Photo.fromJson(item)).toList();
}

 
  // =============================== UPLOAD ===============================
  Future<Photo> uploadPhoto({
    required String title,
    String? description,
    required String category,
    Uint8List? fileBytes,
    io.File? file,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    MultipartFile photoFile;

    if (kIsWeb) {
      if (fileBytes == null) {
        throw Exception("No image selected (web)");
      }

      photoFile = MultipartFile.fromBytes(
        fileBytes,
        filename: "upload.jpg",
      );
    } else {
      if (file == null) {
        throw Exception("No image selected (mobile)");
      }

      photoFile = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split("/").last,
      );
    }

    final formData = FormData.fromMap({
      "title": title,
      "description": description,
      "category": category,
      "image": photoFile,
    });

    final response = await _dio.post(
      "$baseUrl/photos",
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return Photo.fromJson(response.data['data']);
  }

  Future<void> saveLikeStatus(int photoId, bool liked, int count) async {
    final prefs = await SharedPreferences.getInstance();
    String likedPhotosStr = prefs.getString('liked_photos') ?? '{}';
    Map<String, dynamic> likedPhotos = jsonDecode(likedPhotosStr);

    likedPhotos[photoId.toString()] = {'liked': liked, 'count': count};

    await prefs.setString('liked_photos', jsonEncode(likedPhotos));
  }

  Future<Map<String, dynamic>> getLikeStatus(int photoId) async {
    final prefs = await SharedPreferences.getInstance();
    String likedPhotosStr = prefs.getString('liked_photos') ?? '{}';
    Map<String, dynamic> likedPhotos = jsonDecode(likedPhotosStr);

    if (likedPhotos.containsKey(photoId.toString())) {
      return {
        'liked': likedPhotos[photoId.toString()]['liked'] ?? false,
        'count': likedPhotos[photoId.toString()]['count'] ?? 0,
      };
    }
    return {'liked': false, 'count': 0};
  }

  // =============================== LIKE PHOTO ===============================
  Future<Map<String, dynamic>> likePhoto(int photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    try {
      final response = await _dio.post(
        "$baseUrl/photos/$photoId/like",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to like photo');
      }
    } catch (e) {
      throw Exception('Error liking photo: $e');
    }
  }

  // Mendapatkan like info per photo
Future<Map<String, dynamic>> getPhotoLikes(int photoId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? "";

  final response = await _dio.get(
    "$baseUrl/photos/$photoId/likes",
    options: Options(
      headers: {"Authorization": "Bearer $token"},
    ),
  );

  if (response.statusCode == 200) {
    // {"success": true, "data": {"id":1,"like_count":5,"liked":true}, "message": "..."}
    return response.data['data'];
  } else {
    throw Exception('Failed to fetch photo like info');
  }
}

 Future<Photo> updatePhoto(
    int photoId, {
    required String title,
    String? description,
    required String category,
    Uint8List? fileBytes,
    io.File? file,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    FormData formData;

    if ((fileBytes != null) || (file != null)) {
      MultipartFile photoFile;

      if (kIsWeb) {
        photoFile = MultipartFile.fromBytes(fileBytes!, filename: "upload.jpg");
      } else {
        photoFile =
            await MultipartFile.fromFile(file!.path, filename: file.path.split("/").last);
      }

      formData = FormData.fromMap({
        "title": title,
        "description": description,
        "category": category,
        "image": photoFile,
      });
    } else {
      formData = FormData.fromMap({
        "title": title,
        "description": description,
        "category": category,
      });
    }

    final response = await _dio.post(
      "$baseUrl/photos/$photoId",
      data: formData,
      options: Options(headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      }),
    );

    if (response.statusCode == 200) {
      return Photo.fromJson(response.data['data']);
    } else {
      throw Exception("Gagal memperbarui foto");
    }
  }

// =============================== DELETE PHOTO ===============================
Future<void> deletePhoto(int photoId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? "";

  try {
    final response = await _dio.delete(
      "$baseUrl/photos/$photoId",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus foto');
    }
  } catch (e) {
    throw Exception('Error menghapus foto: $e');
  }
}

}
