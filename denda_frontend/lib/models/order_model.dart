enum OrderStatus { pending, processing, shipping, completed, cancelled }

class OrderModel {
  final int id;
  final DateTime orderDate;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final String? voucherCode;
  final String? deliveryAddress; 
  final String? paymentMethod;

  OrderModel({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.items,
    this.voucherCode,
    this.deliveryAddress, 
    this.paymentMethod,
  });

  static OrderStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return OrderStatus.pending;
    switch (statusStr.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'processing': return OrderStatus.processing;
      case 'shipping': return OrderStatus.shipping;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? json['Id'] ?? 0,
      orderDate: DateTime.parse(json['orderDate'] ?? json['OrderDate'] ?? DateTime.now().toIso8601String()),
      totalAmount: ((json['totalAmount'] ?? json['TotalAmount'] ?? 0) as num).toDouble(),
      discountAmount: ((json['discountAmount'] ?? json['DiscountAmount'] ?? 0) as num).toDouble(),
      finalAmount: ((json['finalAmount'] ?? json['FinalAmount'] ?? 0) as num).toDouble(),
      status: _parseStatus(json['status'] ?? json['Status']),
      items: ((json['items'] ?? json['Items'] ?? []) as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      voucherCode: json['voucherCode'] ?? json['VoucherCode'],
      deliveryAddress: json['deliveryAddress'] ?? json['DeliveryAddress'],
      paymentMethod: json['paymentMethod'] ?? json['PaymentMethod'],
    );
  }
}

class OrderItemModel {
  final int productId;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double price;
  final String selectedSize;
  final String toppingDescription;

  OrderItemModel({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.selectedSize,
    required this.toppingDescription,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? json['ProductId'] ?? 0,
      productName: json['productName'] ?? json['ProductName'] ?? 'Món ăn',
      imageUrl: json['imageUrl'] ?? json['ImageUrl'],
      quantity: json['quantity'] ?? json['Quantity'] ?? 1,
      price: ((json['price'] ?? json['Price'] ?? 0) as num).toDouble(),
      selectedSize: json['selectedSize'] ?? json['SelectedSize'] ?? 'M',
      toppingDescription: json['toppingDescription'] ?? json['ToppingDescription'] ?? '',
    );
  }
}