import 'product_model.dart';

class CartItemModel {
  final String id; // Mã tự sinh (UUID hoặc Timestamp) để phân biệt các dòng sản phẩm
  final ProductModel product;
  final OptionModel? size;
  final OptionModel? sugar;
  final OptionModel? ice;
  final List<OptionModel> toppings;
  int quantity;
  final double singleCollapsePrice; // Giá của 1 ly sau khi cộng hết option size/topping

  CartItemModel({
    required this.id,
    required this.product,
    this.size,
    this.sugar,
    this.ice,
    required this.toppings,
    required this.quantity,
    required this.singleCollapsePrice,
  });

  // Tính tổng tiền riêng cho nhóm mặt hàng này (Giá 1 ly nhân với số lượng)
  double get totalItemPrice => singleCollapsePrice * quantity;

  // Chuyển đổi thành JSON để gửi lên API Backend
  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'sizeName': size?.name,
      'sugarName': sugar?.name,
      'iceName': ice?.name,
      'toppings': toppings.map((t) => t.name).toList(),
      'quantity': quantity,
      'price': singleCollapsePrice,
    };
  }
}