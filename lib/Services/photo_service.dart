import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../model/photo.dart';
import 'dart:io' as io;

class PhotoService {
  final Dio _dio = Dio();
  final String baseUrl = "http://127.0.0.1:8000/api";

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
      "photo": photoFile,
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
}
