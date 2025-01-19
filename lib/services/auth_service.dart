import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/det';


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

  // ถอดรหัส JWT
  Future<Map<String, dynamic>?> decodeToken() async {
    final token = await getToken();

    if (token == null) return null;

    // แยก JWT ออกเป็น 3 ส่วน: header, payload, signature
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    // Decode และแปลง payload เป็น Map
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
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
