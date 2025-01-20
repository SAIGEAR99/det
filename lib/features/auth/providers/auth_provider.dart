import 'package:flutter/material.dart';
import 'package:det/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  // สร้าง getter สำหรับดึง user_id และ username
  String? get userId => _user?['id']?.toString();  // แปลง 'id' จาก int เป็น String
  String? get email => _user?['email']; // ใช้ 'email' จาก _user แทน
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final decodedToken = await _authService.decodeToken();
      if (decodedToken != null) {
        _user = decodedToken; // เก็บข้อมูลจาก decodedToken
        print('User loaded: $_user'); // Debug: ดูค่าที่โหลดได้
      } else {
        print('No user found in JWT');
      }
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadUser() async {
    try {
      final decodedToken = await _authService.decodeToken();
      if (decodedToken != null) {
        _user = decodedToken; // อัปเดตข้อมูลผู้ใช้ใหม่
        print('User reloaded: $_user');
      } else {
        print('No user data available');
      }
    } catch (e) {
      print('Error reloading user: $e');
    } finally {
      notifyListeners(); // แจ้งให้ UI อัปเดตข้อมูล
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;
}
