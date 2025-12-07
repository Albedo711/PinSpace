import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 && json["success"] == true) {
      final token = json["data"]["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setBool("isLoggedIn", true);

      return {"success": true, "data": json["data"]};
    }

    return {
      "success": false,
      "message": json["message"] ?? "Login gagal"
    };
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String confirmPassword) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": confirmPassword,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 201 && json["success"] == true) {
      final token = json["data"]["token"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return {"success": true, "data": json["data"]};
    }

    return {
      "success": false,
      "message": json["message"] ?? "Register gagal"
    };
  }
}
