import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/order_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/order_model.dart';
import '../../../services/review_service.dart';
import 'order_detail_screen.dart';
import '../review/review_screen.dart';

class OrderHistoryTab extends StatefulWidget {
  final List<OrderModel> ordersList;

  const OrderHistoryTab({
    super.key,
    required this.ordersList,
  });

  @override
  State<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<OrderHistoryTab> {
  final ReviewService _reviewService = ReviewService();
  final Map<String, bool> reviewedMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviewedStatus();
  }

  Future<void> loadReviewedStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      for (var order in widget.ordersList) {
        // Chỉ kiểm tra đơn đã hoàn thành
        if (order.status != OrderStatus.completed) continue;

        // Tránh lỗi list rỗng
        if (order.items.isEmpty) continue;

        final firstItem = order.items.first;
        final reviewed = await _reviewService.hasReviewed(
          token: authProvider.token!,
          productId: int.parse(firstItem.productId as String),
          orderId: int.parse(order.id as String),
        );

        reviewedMap['${order.id}_${firstItem.productId}'] = reviewed;
      }
    } catch (e) {
      debugPrint('LOAD REVIEW STATUS ERROR: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (widget.ordersList.isEmpty) {
      return const Center(
        child: Text(
          "Lịch sử mua hàng trống.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.ordersList.length,
      itemBuilder: (ctx, index) {
        final order = widget.ordersList[index];
        final statusString = order.status.toString().split('.').last;
        final isPending = order.status == OrderStatus.pending;
        final firstItem = order.items.isNotEmpty ? order.items.first : null;

        final isReviewed = firstItem == null
            ? false
            : reviewedMap['${order.id}_${firstItem.productId}'] ?? false;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Card(
            color: const Color(0xFF1A1A1A),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Đơn hàng ngày ${order.orderDate.toString().substring(0, 10)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.amber.withAlpha(50) : Colors.green.withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusString.toUpperCase(),
                          style: TextStyle(
                            color: isPending ? Colors.amber : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "${order.items.length} món ăn/đồ uống",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const Divider(color: Colors.white10, height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${order.finalAmount.toStringAsFixed(0)}đ",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Row(
                          children: [
                            // REVIEW
                            if (order.status == OrderStatus.completed) ...[
                              if (!isReviewed && firstItem != null)
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.amber, width: 1.2),
                                    foregroundColor: Colors.amber[300],
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.star_rate_rounded, size: 16),
                                  label: const Text(
                                    "Đánh giá",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReviewScreen(
                                          productId: int.parse(firstItem.productId as String),
                                          orderId: int.parse(order.id as String),
                                          productName: firstItem.productName,
                                          imageUrl: firstItem.imageUrl,
                                        ),
                                      ),
                                    );

                                    // REVIEW SUCCESS
                                    if (result == true) {
                                      reviewedMap['${order.id}_${firstItem.productId}'] = true;
                                      setState(() {});
                                    }
                                  },
                                ),

                              // BADGE ĐÃ REVIEW
                              if (isReviewed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(30),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.verified, color: Colors.green, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Đã đánh giá",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 8),
                            ],

                            // REORDER
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B14F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text(
                                "Đặt lại",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                (orderProvider as dynamic).handleReorder(order, cartProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Đã thêm lại món vào giỏ hàng!"),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}