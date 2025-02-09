import 'package:flutter/material.dart';
import 'package:det/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final String apiBaseUrl;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  AuthProvider(this.apiBaseUrl) : _authService = AuthService(apiBaseUrl);
  String? get userId => _user?['id']?.toString();
  String? get email => _user?['email'];
  String? get username => _user?['username'];
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final decodedToken = await _authService.decodeToken();
      if (decodedToken != null) {
        _user = decodedToken;
        print('User loaded: $_user');
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
        _user = decodedToken;
        print('User reloaded: $_user');
      } else {
        print('No user data available');
      }
    } catch (e) {
      print('Error reloading user: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;
}
