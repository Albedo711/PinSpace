import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: "http://192.168.100.44:8000/api",
    headers: {
      "Accept": "application/json",
    },
  ));

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<List<dynamic>> getComments(int photoId) async {
    final token = await _getToken();

    final response = await dio.get(
      "/photos/$photoId/comments",
      options: Options(headers: {
        "Authorization": "Bearer $token",
      }),
    );

    return response.data["data"]["data"];
  }

  Future<Map<String, dynamic>> addComment(int photoId, String comment) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception("User not logged in (token missing)");
    }

    final response = await dio.post(
      "/photos/$photoId/comments",
      data: {"comment": comment},
      options: Options(headers: {
        "Authorization": "Bearer $token",
      }),
    );

    return response.data;
  }
}
