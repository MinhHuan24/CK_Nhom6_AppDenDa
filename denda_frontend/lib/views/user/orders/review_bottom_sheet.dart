import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/order_model.dart';
import '../../../../providers/order_provider.dart';

class ReviewBottomSheet extends StatefulWidget {
  final OrderModel order;

  const ReviewBottomSheet({super.key, required this.order});

  static void show(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewBottomSheet(order: order),
    );
  }

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final List<Map<String, dynamic>> _reviewData = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var item in widget.order.items) {
      _reviewData.add({
        'productId': item.productId,
        'productName': item.productName,
        'imageUrl': item.imageUrl,
        'rating': 5, 
        'controller': TextEditingController(),
      });
    }
  }

  @override
  void dispose() {
    for (var data in _reviewData) {
      (data['controller'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _submitReview() async {
    setState(() => _isSubmitting = true);

    // 1. Thu thập dữ liệu thô từ giao diện người dùng (Giữ nguyên kiểu gốc)
    final List<Map<String, dynamic>> rawReviewItems = _reviewData.map((data) {
      return {
        'productId': data['productId'], // Giữ nguyên giá trị gốc từ OrderItem
        'rating': data['rating'],
        'comment': (data['controller'] as TextEditingController).text.trim(),
      };
    }).toList();

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    // 2. Gọi hàm Provider, truyền thẳng ID Đơn hàng dạng chuỗi và danh sách thô
    final result = await orderProvider.submitOrderReviews(
      orderId: widget.order.id.toString(), // Đảm bảo luôn luôn là chuỗi String
      reviewItems: rawReviewItems,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // 3. Phản hồi kết quả lên màn hình cho người dùng
    if (result['success'] == true) {
      Navigator.pop(context); // Tắt BottomSheet khi thành công
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? "Xử lý hoàn tất"),
        backgroundColor: result['success'] == true ? const Color(0xFF00B14F) : Colors.red,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, 
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                // ĐÃ SỬA: Thay thế EdgeInsets.bottom(16) thành EdgeInsets.only(bottom: 16)
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              "Đánh giá món uống",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              "Đơn hàng #${widget.order.id} • Hãy chia sẻ cảm nhận của bạn nhé!",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _reviewData.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final itemData = _reviewData[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: itemData['imageUrl'] != null && itemData['imageUrl'].isNotEmpty
                                ? Image.network(
                                    itemData['imageUrl'],
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _buildDefaultIcon(),
                                  )
                                : _buildDefaultIcon(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              itemData['productName'] ?? "Nước uống",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (starIndex) {
                          final int currentStarValue = starIndex + 1;
                          final bool isSelected = currentStarValue <= (itemData['rating'] as int);
                          return IconButton(
                            icon: Icon(
                              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 28,
                            ),
                            color: isSelected ? Colors.amber : Colors.grey[400],
                            onPressed: () {
                              setState(() {
                                itemData['rating'] = currentStarValue;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: itemData['controller'] as TextEditingController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Món này vị thế nào? Bạn có hài lòng không...",
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF00B14F)),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Gửi đánh giá",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 44,
      height: 44,
      color: Colors.amber[50],
      child: const Icon(Icons.local_cafe, color: Colors.orange, size: 20),
    );
  }
}