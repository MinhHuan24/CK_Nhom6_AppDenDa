// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; 
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _token;
  String? _role;

  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get role => _role;

  // Hàm xử lý đăng nhập chính
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners(); 

    final response = await _authService.login(username, password);

    if (response != null && response.token.isNotEmpty) {
      _token = response.token;
      _role = _getRoleFromToken(response.token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', response.token);

      _isLoading = false;
      notifyListeners();
      return true; 
    }

    _isLoading = false;
    notifyListeners();
    return false; 
  }

  // Hàm tự động kiểm tra token cũ khi vừa mở App (Auto Login)
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return false;

    final savedToken = prefs.getString('jwt_token');
    if (savedToken == null || savedToken.isEmpty) return false;

    _token = savedToken;
    _role = _getRoleFromToken(savedToken);
    notifyListeners();
    return true;
  }

  // Hàm đăng ký tài khoản mới kết nối tới API Backend
  Future<bool> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('http://10.0.2.2:5019/api/Auth/register'); 
      
      final Map<String, dynamic> registerData = {
        'Username': username,
        'FullName': fullName,
        'Email': email,
        'Password': password,
      };

      print("Đang gửi dữ liệu Đăng ký: ${jsonEncode(registerData)}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerData),
      );

      print("Mã phản hồi từ Server (Status Code): ${response.statusCode}");
      print("Nội dung phản hồi từ Server (Body): ${response.body}");

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi kết nối hoặc lỗi hệ thống hệ thống: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Hàm Đăng xuất
  Future<void> logout() async {
    _token = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }

  // Hàm giải mã JWT định tuyến phân quyền chính xác
  String _getRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'User';
      
      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String resp = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(resp);

      return claims['role'] ?? claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }
}