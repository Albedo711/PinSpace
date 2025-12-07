import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> submitReport({
    required String type,
    required int id,
    required String reason,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await _dio.post(
      "http://127.0.0.1:8000/api/report",
      data: {
        "type": type,
        "id": id,
        "reason": reason,
        "description": description,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ),
    );

    return response.data;
  }
}
