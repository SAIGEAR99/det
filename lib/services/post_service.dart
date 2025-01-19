import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostService {
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/det';

  // ฟังก์ชันสำหรับโพสต์ข้อความพร้อมรูปภาพหลายรูป
  Future<Map<String, dynamic>?> createPost({
    required String userId,
    String? text,
    List<File>? images,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final uri = Uri.parse('$baseUrl/post/create');
      final request = http.MultipartRequest('POST', uri);

      // เพิ่ม Headers
      request.headers['Authorization'] = 'Bearer $token';

      // เพิ่มข้อมูลข้อความและ user_id
      request.fields['user_id'] = userId;
      if (text != null && text.isNotEmpty) {
        request.fields['content'] = text;
      }

      // เพิ่มรูปภาพ (ถ้ามี)
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length && i < 10; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              images[i].path,
            ),
          );
        }
      }

      // ส่งคำขอ
      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody); // คืนค่าผลลัพธ์ที่สำเร็จ
      } else {
        print('Failed to create post: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // ฟังก์ชันดึง JWT จาก Secure Storage
  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
