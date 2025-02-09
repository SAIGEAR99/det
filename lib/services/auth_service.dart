import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  final String apiBaseUrl; // แทนที่ dotenv ด้วยตัวแปรที่รับเข้ามา

  AuthService(this.apiBaseUrl); // กำหนด API URL ผ่าน Constructor

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/det/login'),
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

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<Map<String, dynamic>?> decodeToken() async {
    final token = await getToken();

    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}
