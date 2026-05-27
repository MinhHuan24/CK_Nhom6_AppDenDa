import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        debugPrint('Đăng nhập thất bại: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi kết nối đến Backend: $e');
      return null;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.forgotPassword),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.verifyOtp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.resetPassword),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'newPassword': password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }
}