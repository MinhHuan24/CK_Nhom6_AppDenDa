import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => [..._items];
  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalItemPrice);
  }

  void addToCart({
    required dynamic product,
    required dynamic size,
    required dynamic sugar,
    required dynamic ice,
    required List<dynamic> toppings,
    required int quantity,
    required double singlePrice,
  }) {
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString();

    _items.add(
      CartItemModel(
        id: uniqueId,
        product: product,
        size: size,
        sugar: sugar,
        ice: ice,
        toppings: List.from(toppings),
        quantity: quantity,
        singleCollapsePrice: singlePrice,
      ),
    );

    notifyListeners();
  }

  void updateQuantity(String cartId, int newQty) {
    final index = _items.indexWhere((item) => item.id == cartId);
    if (index >= 0 && newQty > 0) {
      _items[index].quantity = newQty;
      notifyListeners();
    }
  }

  void removeItem(String cartId) {
    _items.removeWhere((item) => item.id == cartId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  /// GỬI ĐƠN HÀNG LÊN SERVER API 
  Future<bool> checkOutOrder({
    required String note, 
    required String orderType,
    required String address,
    required String paymentMethod,
  }) async {
    if (_items.isEmpty) return false;

    try {
      final url = Uri.parse('http://10.0.2.2:5019/api/Order/checkout');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // Đã mapping đồng bộ tên biến khớp với API thông thường nhận diện
      final Map<String, dynamic> orderPayload = {
        'OrderType': orderType, 
        'Note': note,
        'DeliveryAddress': address,       // Map key truyền lên API
        'PaymentMethod': paymentMethod,   // Map key truyền lên API
        'OrderDetails': _items.map((item) => item.toJson()).toList(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode(orderPayload),
      );

      debugPrint("===== [DEBUG ĐẶT HÀNG] =====");
      debugPrint("Status Code từ Server: ${response.statusCode}");
      debugPrint("Payload gửi đi: ${jsonEncode(orderPayload)}");
      debugPrint("Nội dung Server trả về: ${response.body}");
      debugPrint("========================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearCart(); 
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi kết nối đặt hàng: $e");
      return false;
    }
  }
}