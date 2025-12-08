import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/board.dart';
import '../model/photo.dart'; // TAMBAHKAN IMPORT INI

class BoardService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        "Accept": "application/json",
      },
    ),
  );

  Future<List<Board>> getBoards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      final response = await _dio.get("/boards");

      if (response.statusCode == 200) {
        final jsonData = response.data;

        final List dataList = jsonData["data"]["data"];

        return dataList.map((item) => Board.fromJson(item)).toList();
      } else {
        throw Exception("Gagal memuat boards");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      throw Exception("Gagal memuat boards");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal memuat boards");
    }
  }

  // METHOD BARU: Get Board Photos
  Future<List<Photo>> getBoardPhotos(int boardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      final response = await _dio.get("/boards/$boardId/photos");

      if (response.statusCode == 200) {
        final jsonData = response.data;
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final paginationData = jsonData['data'];
          final List photoList = paginationData['data'] ?? [];
          
          return photoList.map((item) => Photo.fromJson(item)).toList();
        } else {
          throw Exception("Format response tidak valid");
        }
      } else {
        throw Exception("Gagal memuat foto board");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      
      if (e.response?.statusCode == 403) {
        throw Exception("Anda tidak memiliki akses ke board ini");
      } else if (e.response?.statusCode == 404) {
        throw Exception("Board tidak ditemukan");
      }
      
      throw Exception(e.response?.data['message'] ?? "Gagal memuat foto board");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal memuat foto board");
    }
  }

  Future<Board> createBoard({
    required String name,
    String? description,
    dynamic coverImage, // Bisa File (mobile) atau XFile (web)
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      // Prepare FormData
      FormData formData = FormData.fromMap({
        'name': name,
      });

      // Add description if not empty
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }

      // Add cover image if exists
      if (coverImage != null) {
        String fileName;
        MultipartFile multipartFile;
        
        if (coverImage is File) {
          // Mobile: File dari dart:io
          fileName = coverImage.path.split('/').last;
          multipartFile = await MultipartFile.fromFile(
            coverImage.path,
            filename: fileName,
          );
        } else if (coverImage is XFile) {
          // Web atau Mobile: XFile dari image_picker
          fileName = coverImage.name;
          final bytes = await coverImage.readAsBytes();
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
        } else {
          throw Exception('Tipe file tidak didukung');
        }
        
        formData.files.add(MapEntry('cover_image', multipartFile));
      }

      final response = await _dio.post(
        "/boards",
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData['success'] == true) {
          return Board.fromJson(jsonData["data"]);
        }
        throw Exception("Gagal membuat board");
      } else {
        throw Exception("Gagal membuat board");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      
      // Handle validation errors
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['data'];
        if (errors != null) {
          final errorMessages = (errors as Map<String, dynamic>)
              .values
              .map((e) => e[0])
              .join(', ');
          throw Exception(errorMessages);
        }
      }
      
      throw Exception(e.response?.data['message'] ?? "Gagal membuat board");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal membuat board");
    }
  }

  Future<Board> updateBoard({
    required int boardId,
    required String name,
    String? description,
   
    dynamic coverImage, // Bisa File (mobile) atau XFile (web)
    bool removeImage = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      // Prepare FormData
      FormData formData = FormData.fromMap({
        '_method': 'POST', // Laravel method spoofing untuk multipart
        'name': name,
      });

      // Add description if not empty
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }

      // Add flag untuk remove image (jika backend support)
      if (removeImage) {
        formData.fields.add(MapEntry('remove_image', '1'));
      }

      // Add cover image if exists and not removing
      if (coverImage != null && !removeImage) {
        String fileName;
        MultipartFile multipartFile;
        
        if (coverImage is File) {
          // Mobile: File dari dart:io
          fileName = coverImage.path.split('/').last;
          multipartFile = await MultipartFile.fromFile(
            coverImage.path,
            filename: fileName,
          );
        } else if (coverImage is XFile) {
          // Web atau Mobile: XFile dari image_picker
          fileName = coverImage.name;
          final bytes = await coverImage.readAsBytes();
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          );
        } else {
          throw Exception('Tipe file tidak didukung');
        }
        
        formData.files.add(MapEntry('cover_image', multipartFile));
      }

      // Gunakan POST dengan _method=PUT untuk multipart/form-data
      final response = await _dio.post(
        "/boards/$boardId",
        data: formData,
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData['success'] == true) {
          return Board.fromJson(jsonData["data"]);
        }
        throw Exception("Gagal update board");
      } else {
        throw Exception("Gagal update board");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      
      // Handle validation errors
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['data'];
        if (errors != null) {
          final errorMessages = (errors as Map<String, dynamic>)
              .values
              .map((e) => e[0])
              .join(', ');
          throw Exception(errorMessages);
        }
      }
      
      throw Exception(e.response?.data['message'] ?? "Gagal update board");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal update board");
    }
  }

  Future<void> deleteBoard(int boardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      final response = await _dio.delete("/boards/$boardId");

      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData['success'] == true) {
          return;
        }
        throw Exception("Gagal menghapus board");
      } else {
        throw Exception("Gagal menghapus board");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "Gagal menghapus board");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal menghapus board");
    }
  }

  Future<void> addPhotoToBoard({
    required int boardId,
    required int photoId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      final response = await _dio.post(
        "/boards/$boardId/add-photo",
        data: {
          'photo_id': photoId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData['success'] == true) {
          return;
        }
        throw Exception("Gagal menambahkan foto ke board");
      } else {
        throw Exception("Gagal menambahkan foto ke board");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      
      // Handle specific error messages
      if (e.response?.statusCode == 400) {
        throw Exception("Foto sudah ada di board ini");
      } else if (e.response?.statusCode == 403) {
        throw Exception("Anda tidak memiliki akses ke board ini");
      }
      
      throw Exception(e.response?.data['message'] ?? "Gagal menambahkan foto ke board");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal menambahkan foto ke board");
    }
  }

  Future<void> removePhotoFromBoard({
    required int boardId,
    required int photoId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan. Harus login dulu.");
      }

      // set authorization header
      _dio.options.headers["Authorization"] = "Bearer $token";

      final response = await _dio.delete(
        "/boards/$boardId/photos/$photoId",
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        if (jsonData['success'] == true) {
          return;
        }
        throw Exception("Gagal menghapus foto dari board");
      } else {
        throw Exception("Gagal menghapus foto dari board");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data}");
      
      if (e.response?.statusCode == 403) {
        throw Exception("Anda tidak memiliki akses ke board ini");
      }
      
      throw Exception(e.response?.data['message'] ?? "Gagal menghapus foto dari board");
    } catch (e) {
      print("Error: $e");
      throw Exception("Gagal menghapus foto dari board");
    }
  }
}