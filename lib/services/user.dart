import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:det/features/auth/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  final String baseUrl = '${dotenv.env['API_BASE_URL']}/det';

  // ฟังก์ชันดึงข้อมูลจาก /user โดยใช้ user_id จาก AuthProvider
  Future<Map<String, dynamic>?> getUserData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      print('User ID not found in AuthProvider');
      return null;
    }

    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // ถ้าเรียก API สำเร็จ
      } else {
        print('Access denied: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error accessing protected route: $e');
      return null;
    }
  }

  // ฟังก์ชันสำหรับแก้ไขข้อมูลโปรไฟล์
  Future<Map<String, dynamic>?> editProfile(String fullName, String bio, String link, BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      print('User ID not found in AuthProvider');
      return null;
    }

    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/edit_profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'full_name': fullName,
          'bio': bio,
          'link': link,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // ถ้าแก้ไขโปรไฟล์สำเร็จ
      } else {
        print('Failed to update profile: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadProfilePicture(String userId, String filePath) async {
    final token = await getToken();
    if (token == null) return null;

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/img/upload_profile'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['user_id'] = userId;
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody); // คืนค่ารูปภาพที่อัปเดตกลับมา
    } else {
      print('Error uploading profile picture: ${response.statusCode}');
      return null;
    }
  }



  // ฟังก์ชันดึง JWT จาก Secure Storage
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);  // อ่าน JWT จาก Secure Storage
  }
}
