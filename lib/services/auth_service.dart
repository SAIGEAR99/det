import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
  final String baseUrl = 'http://192.168.0.3:3000/api/auth';

  // ฟังก์ชันล็อกอิน
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // ดึง token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // ลบ token เมื่อล็อกเอาท์
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}
