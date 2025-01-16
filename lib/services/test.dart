import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class testService {
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  final String baseUrl = 'http://192.168.0.3:3000/api/auth';

  // ฟังก์ชันสำหรับเรียกข้อมูลจาก /protected
  Future<Map<String, dynamic>?> getProtectedResource() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/protected'),
        headers: {
          'Authorization': 'Bearer $token', // ส่ง JWT ใน Header
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // ส่งข้อมูลจาก API
      } else {
        print('Access denied: ${response.body}');
        return null; // ถ้าไม่สามารถเข้าถึงได้
      }
    } catch (e) {
      print('Error accessing protected route: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
