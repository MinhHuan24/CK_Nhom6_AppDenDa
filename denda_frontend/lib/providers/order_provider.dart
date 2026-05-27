import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/product_model.dart'; // Đảm bảo file này chứa cả class ProductModel và OptionModel
import 'cart_provider.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  List<OrderModel> get activeOrders {
    return _orders.where((order) => 
      order.status == OrderStatus.pending || 
      order.status == OrderStatus.processing || 
      order.status == OrderStatus.shipping
    ).toList();
  }

  List<OrderModel> get historyOrders {
    return _orders.where((order) => 
      order.status == OrderStatus.completed || 
      order.status == OrderStatus.cancelled
    ).toList();
  }

  Future<void> fetchUserOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final url = Uri.parse('http://10.0.2.2:5019/api/Order/user-orders'); 

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("===== [DEBUG TẢI ĐƠN HÀNG] =====");
      debugPrint("Status Code từ Server: ${response.statusCode}");
      debugPrint("Nội dung Server trả về: ${response.body}");
      debugPrint("========================================");

      if (response.statusCode == 200) {
        final List<dynamic> extractedData = jsonDecode(response.body);
        _orders = extractedData.map((orderJson) => OrderModel.fromJson(orderJson)).toList();
      } else {
        _orders = []; 
      }
    } catch (error) {
      debugPrint("Lỗi kết nối tải đơn hàng từ hệ thống: $error");
      _orders = []; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void handleReorder(OrderModel oldOrder, CartProvider cartProvider) {
    for (var item in oldOrder.items) {
      String sizeName = item.selectedSize.isNotEmpty ? item.selectedSize : "M";
      String sugarName = "100% Đường";
      String iceName = "100% Đá";
      
      // Khởi tạo danh sách đối tượng OptionModel cho toppings
      List<OptionModel> toppings = [];

      if (item.toppingDescription.isNotEmpty) {
        List<String> parts = item.toppingDescription.split(' | ');

        for (var part in parts) {
          if (part.startsWith('Size: ')) {
            sizeName = part.replaceAll('Size: ', '').replaceAll('Size ', ''); // Xử lý loại bỏ chữ "Size " thừa nếu có
          } else if (part.startsWith('Đường: ')) {
            sugarName = part.replaceAll('Đường: ', '');
          } else if (part.startsWith('Đá: ')) {
            iceName = part.replaceAll('Đá: ', '');
          } else if (part.startsWith('Topping: ')) {
            String toppingStr = part.replaceAll('Topping: ', '');
            
            // Ép kiểu danh sách Map thô từ chuỗi cắt được sang thực thể OptionModel chuẩn
            toppings = toppingStr.split(', ').map((e) {
              return OptionModel.fromJson({
                'id': 0,
                'name': e,
                'price': 0.0,
              });
            }).toList();
          }
        }
      }

      // Khởi tạo thực thể ProductModel hợp lệ
      final realProduct = ProductModel.fromJson({
        'id': int.tryParse(item.productId as String) ?? 0, 
        'name': item.productName,
        'imageUrl': item.imageUrl ?? '',
        'price': item.price,
      });

      // Ép kiểu các Map tùy chọn đơn lẻ sang OptionModel trước khi đẩy vào CartProvider
      final selectedSizeOption = OptionModel.fromJson({
        'id': 0,
        'name': sizeName,
        'price': 0.0,
      });

      final selectedSugarOption = OptionModel.fromJson({
        'id': 0,
        'name': sugarName,
        'price': 0.0,
      });

      final selectedIceOption = OptionModel.fromJson({
        'id': 0,
        'name': iceName,
        'price': 0.0,
      });

      // Thực hiện thêm sản phẩm vào giỏ hàng với các thực thể chuẩn xác
      cartProvider.addToCart(
        product: realProduct, 
        size: selectedSizeOption,
        sugar: selectedSugarOption,
        ice: selectedIceOption,
        toppings: toppings, // Truyền danh sách List<OptionModel>
        quantity: item.quantity,
        singlePrice: item.price,
      );
    }
    notifyListeners();
  }

  // Hàm xử lý hủy đơn hàng trực tiếp từ Client gửi lên Server
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      // Khởi tạo URL endpoint gọi tới hàm PUT cancel của C#
      final url = Uri.parse('http://10.0.2.2:5019/api/Order/cancel/$orderId');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Tìm và cập nhật trực tiếp trạng thái đơn hàng trong danh sách local để cập nhật UI ngay lập tức
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex >= 0) {
          // Sao chép lại đối tượng cũ với trạng thái mới là Cancelled
          _orders[orderIndex] = OrderModel(
            id: _orders[orderIndex].id,
            orderDate: _orders[orderIndex].orderDate,
            totalAmount: _orders[orderIndex].totalAmount,
            discountAmount: _orders[orderIndex].discountAmount,
            finalAmount: _orders[orderIndex].finalAmount,
            status: OrderStatus.cancelled, // Chuyển đổi trạng thái enum
            items: _orders[orderIndex].items,
            voucherCode: _orders[orderIndex].voucherCode,
          );
          notifyListeners(); // Phát thông báo cập nhật giao diện
        }
        return {'success': true, 'message': responseData['message'] ?? 'Đã hủy đơn!'};
      } else {
        // Trả về thông báo lỗi từ Backend (Ví dụ: trạng thái đơn đã chuyển sang Processing)
        return {'success': false, 'message': responseData['message'] ?? 'Hủy đơn thất bại.'};
      }
    } catch (error) {
      debugPrint("Lỗi kết nối khi hủy đơn hàng: $error");
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ Đen Đá!'};
    }
  }

  // Hàm gửi danh sách đánh giá của đơn hàng lên Backend .NET
  Future<Map<String, dynamic>> submitOrderReviews({
    required String orderId,
    required List<Map<String, dynamic>> reviewItems,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final url = Uri.parse('http://10.0.2.2:5019/api/Review/submit-order-reviews');
      
      // Đóng gói JSON Payload khớp hoàn toàn 100% với cấu trúc lớp OrderReviewDto trong C#
      final bodyPayload = jsonEncode({
        'orderId': int.tryParse(orderId) ?? 0, // Chuyển đổi mã đơn hàng chuỗi về số nguyên int
        'items': reviewItems.map((item) {
          return {
            'productId': int.tryParse(item['productId'].toString()) ?? 0, // Ép mã sản phẩm về số nguyên int
            'rating': int.tryParse(item['rating'].toString()) ?? 5,       // Đảm bảo rating là int
            'comment': item['comment']?.toString() ?? '',                 // Đảm bảo comment là chuỗi kí tự
          };
        }).toList(),
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: bodyPayload,
      );

      // Kiểm tra tính hợp lệ của dữ liệu phản hồi
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Không nhận được phản hồi từ hệ thống.'};
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Tải lại danh sách đơn hàng để UI cập nhật trạng thái mới (ví dụ ẩn nút đánh giá nếu có)
        await fetchUserOrders();
        return {'success': true, 'message': responseData['message'] ?? 'Đánh giá thành công!'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Gửi đánh giá thất bại.'};
      }
    } catch (error) {
      debugPrint("Lỗi kết nối khi gửi đánh giá: $error");
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ Đen Đá!'};
    }
  }
}