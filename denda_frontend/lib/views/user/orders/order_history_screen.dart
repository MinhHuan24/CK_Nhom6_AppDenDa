import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../providers/order_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../models/order_model.dart';
import '../orders/order_detail_screen.dart';
//import '../review/review_screen.dart';
import '../review/select_review_product_screen.dart'; // Đảm bảo import đúng đường dẫn chứa OrderDetailScreen

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchUserOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: const [
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Lịch sử đặt'),
          ],
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(orderProvider.activeOrders, cartProvider, isActive: true),
                _buildOrderList(orderProvider.historyOrders, cartProvider, isActive: false),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, CartProvider cartProvider, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.receipt_long_rounded : Icons.history_rounded, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Bạn không có đơn hàng nào đang chạy.' : 'Lịch sử mua hàng trống.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, cartProvider, isActive);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, CartProvider cartProvider, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mã đơn: ${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Divider(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (ctx, idx) {
                  final item = order.items[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName} (${item.selectedSize})',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(item.price * item.quantity).toStringAsFixed(0)} đ',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(
                    '${order.finalAmount.toStringAsFixed(0)} đ',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ],
              ),
              
              if (isActive) ...[
                if (order.status == OrderStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _handleCancelOrderFromList(order.id as String), // SỬA: Bỏ truyền context
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Hủy đơn'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ]
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == OrderStatus.completed)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SelectReviewProductScreen(
                                order: order,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: const Text('Đánh giá'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber[800],
                          side: BorderSide(color: Colors.amber[800]!),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<OrderProvider>().handleReorder(order, cartProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm toàn bộ các món từ đơn cũ vào giỏ hàng!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.replay_rounded, size: 18, color: Colors.white),
                      label: const Text('Đặt lại món', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // SỬA: Xóa tham số BuildContext context truyền vào
  Future<void> _handleCancelOrderFromList(String orderId) async {
    final messenger = ScaffoldMessenger.of(context);

    final orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    bool confirmCancel =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Xác nhận hủy đơn',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn hủy đơn hàng Đen Đá này trực tiếp từ danh sách không?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Không',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Hủy ngay',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmCancel) return;

    final result = await orderProvider.cancelOrder(orderId);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor:
            result['success']
                ? Colors.green
                : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  Widget _buildStatusBadge(OrderStatus status) {
    String text = '';
    Color color = Colors.grey;

    switch (status) {
      case OrderStatus.pending:
        text = 'Chờ duyệt'; color = Colors.orange;
        break;
      case OrderStatus.processing:
        text = 'Đang pha chế'; color = Colors.blue;
        break;
      case OrderStatus.shipping:
        text = 'Đang giao'; color = Colors.purple;
        break;
      case OrderStatus.completed:
        text = 'Đã giao'; color = Colors.green;
        break;
      case OrderStatus.cancelled:
        text = 'Đã hủy'; color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}