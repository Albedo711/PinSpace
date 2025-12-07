import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Follow user
  Future<Map<String, dynamic>> followUser(int userId) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse("$baseUrl/follow/$userId"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return _handleResponse(response);
    } catch (e) {
      print("FollowService.followUser ERROR: $e");
      rethrow;
    }
  }

  /// Unfollow user
  Future<Map<String, dynamic>> unfollowUser(int userId) async {
    try {
      final token = await _getToken();

      final response = await http.delete(
        Uri.parse("$baseUrl/follow/$userId"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return _handleResponse(response);
    } catch (e) {
      print("FollowService.unfollowUser ERROR: $e");
      rethrow;
    }
  }

  /// Check if user is following another user
  Future<Map<String, dynamic>> checkFollow(int userId) async {
    try {
      final token = await _getToken();

      print("FollowService.checkFollow: Checking follow status for user $userId");

      final response = await http.get(
        Uri.parse("$baseUrl/follow/$userId/check"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("FollowService.checkFollow: Response status = ${response.statusCode}");
      print("FollowService.checkFollow: Response body = ${response.body}");

      return _handleResponse(response);
    } catch (e) {
      print("FollowService.checkFollow ERROR: $e");
      // Return default value instead of throwing
      return {
        "success": true,
        "data": {
          "is_following": false
        }
      };
    }
  }

  /// Get current user ID from SharedPreferences
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    print("FollowService.getCurrentUserId: user_id = $userId");
    return userId;
  }

  /// Get token from SharedPreferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("FollowService._getToken: Token not found in SharedPreferences");
      throw Exception("Token not found. Please login first.");
    }

    print("FollowService._getToken: Token found (length: ${token.length})");
    return token;
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle both success=true and success not present
        if (json["success"] == true || !json.containsKey("success")) {
          return json;
        }
      }

      // Handle error response
      throw Exception(json["message"] ?? "Request failed with status ${response.statusCode}");
    } catch (e) {
      if (e is FormatException) {
        throw Exception("Invalid response format: ${response.body}");
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFollowers(int userId) async {
  try {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId/followers"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List dataList = jsonData['data']['data']; // ambil list sebenarnya
      return List<Map<String, dynamic>>.from(dataList);
    } else {
      throw Exception("Failed to fetch followers: ${response.statusCode}");
    }
  } catch (e) {
    print("FollowService.getFollowers ERROR: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> getFollowing(int userId) async {
  try {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId/following"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List dataList = jsonData['data']['data']; // ambil list sebenarnya
      return List<Map<String, dynamic>>.from(dataList);
    } else {
      throw Exception("Failed to fetch following: ${response.statusCode}");
    }
  } catch (e) {
    print("FollowService.getFollowing ERROR: $e");
    return [];
  }
}

}