import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:det/features/auth/providers/auth_provider.dart';


class UserService {
  final String apiBaseUrl;
  final _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  UserService(this.apiBaseUrl); // รับ API URL จาก AuthProvider

  // ฟังก์ชันดึงข้อมูลจาก /user โดยใช้ user_id จาก AuthProvider
  Future<Map<String, dynamic>?> getUserData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      print('❌ User ID not found in AuthProvider');
      return null;
    }

    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/det/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Access denied: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error accessing protected route: $e');
      return null;
    }
  }

  // ฟังก์ชันสำหรับแก้ไขข้อมูลโปรไฟล์
  Future<Map<String, dynamic>?> editProfile(String fullName, String bio, String link, BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      print('❌ User ID not found in AuthProvider');
      return null;
    }

    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/det/user/edit_profile'),
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
        return jsonDecode(response.body);
      } else {
        print('❌ Failed to update profile: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return null;
    }
  }

  // ฟังก์ชันอัปโหลดรูปโปรไฟล์
  Future<Map<String, dynamic>?> uploadProfilePicture(String userId, String filePath) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('❌ Error: Token not found.');
        return null;
      }

      final request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/det/img/upload_profile'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['user_id'] = userId;
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      print('📤 Uploading profile picture for user $userId');

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('✅ Profile picture uploaded successfully.');
        return jsonDecode(responseBody);
      } else {
        print('❌ Error uploading profile picture: ${response.statusCode} - ${response.reasonPhrase}');
        final errorBody = await response.stream.bytesToString();
        print('❌ Response body: $errorBody');
        return null;
      }
    } catch (e) {
      print('❌ Exception occurred while uploading profile picture: $e');
      return null;
    }
  }

  // ฟังก์ชันดึง JWT จาก Secure Storage
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
