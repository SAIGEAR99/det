import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PostService {
  final String apiBaseUrl;
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  // รับค่า API URL จาก AuthProvider ตอนสร้าง Instance
  PostService(this.apiBaseUrl);

  // ฟังก์ชันสร้างโพสต์
  Future<Map<String, dynamic>?> createPost({
    required String userId,
    String? text,
    List<File>? images,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final uri = Uri.parse('$apiBaseUrl/det/post/create'); // ใช้ API URL จาก `AuthProvider`
      final request = http.MultipartRequest('POST', uri);

      // เพิ่ม Headers
      request.headers['Authorization'] = 'Bearer $token';

      // เพิ่มข้อมูลโพสต์
      request.fields['user_id'] = userId;
      if (text != null && text.isNotEmpty) {
        request.fields['content'] = text;
      }

      // อัปโหลดรูปภาพ (ถ้ามี)
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files.add(await http.MultipartFile.fromPath('images', image.path));
        }
      }

      // ส่งคำขอไปยัง API
      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        print('❌ Failed to create post: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating post: $e');
      return null;
    }
  }

  // ดึง JWT Token
  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}

