// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'http://10.0.2.2:5019/api';

  // Lấy danh mục
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Category'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi ProductService (fetchCategories): $e");
    }
    return [];
  }
  
  // Lấy danh sách món (Có thể lọc theo categoryId)
  Future<List<ProductModel>> fetchProducts({int? categoryId}) async {
    try {
      String url = '$baseUrl/Product';
      if (categoryId != null) {
        url += '?categoryId=$categoryId';
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi ProductService (fetchProducts): $e");
    }
    return [];
  }

  // Lấy danh sách tùy chọn (Size, Đường, Đá, Topping) nhóm theo loại
  Future<Map<String, List<OptionModel>>> fetchOptions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Option'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, List<OptionModel>> groupedOptions = {};
        
        data.forEach((key, value) {
          List<dynamic> list = value;
          groupedOptions[key] = list.map((json) => OptionModel.fromJson(json)).toList();
        });
        
        return groupedOptions;
      }
    } catch (e) {
      print("Lỗi ProductService (fetchOptions): $e");
    }
    return {};
  }

  // Tìm kiếm món
  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Product/search?keyword=$keyword'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        return data
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("Lỗi searchProducts: $e");
    }

    return [];
  }
}