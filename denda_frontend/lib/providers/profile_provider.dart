import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  final String _baseUrl = 'http://10.0.2.2:5019/api/auth';
  final String _serverUrl = 'http://10.0.2.2:5019';

  String _name = '';
  String _email = '';
  String _phone = '';
  String _avatarUrl = '';

  bool _isLoading = false;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get avatarUrl => _avatarUrl;
  bool get isLoading => _isLoading;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  String _buildAvatarUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';

    if (rawUrl.startsWith('http')) {
      return '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';
    }

    return '$_serverUrl$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';

        final rawAvatar = data['avatarUrl'] ?? '';
        _avatarUrl = _buildAvatarUrl(rawAvatar);
      }
    } catch (e) {
      debugPrint('Load profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token không tồn tại',
        };
      }

      final uri = Uri.parse('$_baseUrl/upload-avatar');

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final extension = p.extension(imageFile.path).toLowerCase();

      String mimeType = 'image/jpeg';

      if (extension == '.png') {
        mimeType = 'image/png';
      } else if (extension == '.webp') {
        mimeType = 'image/webp';
      }

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("UPLOAD STATUS: ${response.statusCode}");
      debugPrint("UPLOAD BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final rawUrl = data['avatarUrl'] ?? '';

        _avatarUrl = _buildAvatarUrl(rawUrl);

        notifyListeners();

        return {
          'success': true,
          'message': 'Cập nhật ảnh đại diện thành công!',
        };
      } else {
        return {
          'success': false,
          'message': 'Server lỗi: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");

      return {
        'success': false,
        'message': 'Lỗi upload: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': newName,
          'phone': newPhone,
        }),
      );

      if (response.statusCode == 200) {
        _name = newName;
        _phone = newPhone;

        notifyListeners();

        return {
          'success': true,
          'message': 'Cập nhật thành công!',
        };
      }

      return {
        'success': false,
        'message': 'Không thể cập nhật',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '$e',
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('jwt_token');

    _name = '';
    _email = '';
    _phone = '';
    _avatarUrl = '';

    notifyListeners();
  }
}