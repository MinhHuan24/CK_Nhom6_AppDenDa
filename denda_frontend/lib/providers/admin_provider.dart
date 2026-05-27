import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminProvider with ChangeNotifier {
  final String _baseUrl = 'http://10.0.2.2:5019/api/admin';
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  List<dynamic> _orders = [];
  List<dynamic> _reviews = [];
  bool get isLoading => _isLoading;
  Map<String, dynamic> get stats => _stats;
  List<dynamic> get products => _products;
  List<dynamic> get categories => _categories;
  List<dynamic> get orders => _orders;
  List<dynamic> get reviews => _reviews;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('jwt_token');

    log(token.toString());

    return token;
  }

  Future<void> fetchDashboardStats() async {
    _isLoading = true;

    notifyListeners();

    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard-stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _stats = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    _isLoading = true;

    notifyListeners();

    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _products = data['products'] ?? [];

        _categories = data['categories'] ?? [];
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<bool> saveProduct({
    int? id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = await _getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final url = id == null
          ? Uri.parse('$_baseUrl/products')
          : Uri.parse('$_baseUrl/products/$id');

      final response = id == null
          ? await http.post(
              url,
              headers: headers,
              body: jsonEncode(data),
            )
          : await http.put(
              url,
              headers: headers,
              body: jsonEncode(data),
            );

      if (response.statusCode == 200) {
        await fetchAllProducts();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }

  Future<bool> toggleAvailability(int productId) async {
    try {
      final token = await _getToken();

      final response = await http.patch(
        Uri.parse(
          '$_baseUrl/products/$productId/toggle-availability',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchAllProducts();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      final token = await _getToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchAllProducts();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;

    notifyListeners();

    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _orders = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<bool> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      final token = await _getToken();

      final response = await http.put(
        Uri.parse(
          '$_baseUrl/orders/$orderId/status',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Status': status,
        }),
      );

      if (response.statusCode == 200) {
        await fetchAllOrders();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }
  
  Future<void> fetchAllReviews() async {
    _isLoading = true;

    notifyListeners();

    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/reviews'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _reviews = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<bool> deleteReview(int reviewId) async {
    try {
      final token = await _getToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/reviews/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchAllReviews();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
  try {
    final token = await _getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload-image'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();

    final responseData = await response.stream.bytesToString();

    debugPrint(responseData);

    if (response.statusCode == 200) {
      final data = json.decode(responseData);
      return data['imageUrl'];
    }

    return null;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}
}