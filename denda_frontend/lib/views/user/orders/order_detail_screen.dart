import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../../../constants/app_colors.dart'; // Đảm bảo đường dẫn này đúng với project của bạn

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isCancelling = false;

  int _getStatusStep(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 0;
      case OrderStatus.processing: return 1;
      case OrderStatus.shipping: return 2;
      case OrderStatus.completed: return 3;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOrder = context.watch<OrderProvider>().orders.firstWhere(
          (o) => o.id == widget.order.id,
          orElse: () => widget.order,
        );

    int currentStep = _getStatusStep(currentOrder.status);
    
    // Việt hóa trạng thái hiển thị
    String statusText = "CHỜ DUYỆT";
    if (currentOrder.status == OrderStatus.processing) statusText = "ĐANG LÀM";
    if (currentOrder.status == OrderStatus.shipping) statusText = "ĐANG GIAO";
    if (currentOrder.status == OrderStatus.completed) statusText = "HOÀN THÀNH";
    if (currentOrder.status == OrderStatus.cancelled) statusText = "ĐÃ HỦY";

    Color statusColor = AppColors.warning;
    if (currentOrder.status == OrderStatus.completed) statusColor = AppColors.primary;
    if (currentOrder.status == OrderStatus.cancelled) statusColor = AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background, // Đồng bộ màu nền hệ thống
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Màu xanh lá chủ đạo phong cách hiện đại
        elevation: 0,
        title: Text(
          'Chi tiết đơn #${currentOrder.id}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CỤM 1: TRẠNG THÁI ĐƠN HÀNG ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Trạng thái đơn hàng",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  currentOrder.status == OrderStatus.cancelled
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel, color: AppColors.error, size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Đơn hàng này đã bị hủy bỏ",
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStepNode("Chờ duyệt", currentStep >= 0, currentStep == 0),
                            _buildLine(currentStep >= 1),
                            _buildStepNode("Đang làm", currentStep >= 1, currentStep == 1),
                            _buildLine(currentStep >= 2),
                            _buildStepNode("Đang giao", currentStep >= 2, currentStep == 2),
                            _buildLine(currentStep >= 3),
                            _buildStepNode("Hoàn thành", currentStep >= 3, currentStep == 3),
                          ],
                        ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- CỤM 2: THÔNG TIN GIAO HÀNG ---
            const Text(
              "Thông tin giao hàng",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Địa chỉ
                  _buildInfoRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.error,
                    label: "Địa chỉ nhận hàng",
                    value: currentOrder.deliveryAddress ?? "Chưa cập nhật",
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFF0F0F0), height: 1),
                  ),
                  // Phương thức thanh toán
                  _buildInfoRow(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Colors.blue,
                    label: "Hình thức thanh toán",
                    value: currentOrder.paymentMethod ?? "Chưa cập nhật",
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFF0F0F0), height: 1),
                  ),
                  // Thời gian đặt
                  _buildInfoRow(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: AppColors.warning,
                    label: "Thời gian đặt đơn",
                    value: currentOrder.orderDate.toString().substring(0, 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- CỤM 3: DANH SÁCH MÓN ĂN ---
            const Text(
              "Danh sách món đã chọn",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentOrder.items.length,
              itemBuilder: (ctx, i) {
                final item = currentOrder.items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEFEFEFEF)), 
                      ),
                      child: const Icon(
                        Icons.local_cafe_rounded,
                        color: Colors.brown,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      item.productName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${item.toppingDescription}\nx${item.quantity}",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                    trailing: Text(
                      "${(item.price * item.quantity).toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFDCDCDC), height: 24),

            // --- CỤM 4: TỔNG THANH TOÁN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng thanh toán:",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${currentOrder.finalAmount.toStringAsFixed(0)}đ",
                  style: const TextStyle(
                    color: Colors.deepOrange, // Đã sửa lỗi Colors.orangeRed không tồn tại
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- NÚT HỦY ĐƠN HÀNG ---
            if (currentOrder.status == OrderStatus.pending)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE), // Màu đỏ nhạt nền nút hủy
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.error, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isCancelling
                      ? null
                      : () => _handleCancelOrder(currentOrder.id as String),
                  child: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.error,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Hủy đơn hàng',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleCancelOrder(String orderId) async {
    final messenger = ScaffoldMessenger.of(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    bool confirmCancel = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Xác nhận hủy đơn',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn hủy đơn hàng?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Không', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Hủy đơn ngay', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ?? false;

    if (!confirmCancel) return;

    setState(() {
      _isCancelling = true;
    });

    final result = await orderProvider.cancelOrder(orderId);

    if (!mounted) return;

    setState(() {
      _isCancelling = false;
    });

    messenger.showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? AppColors.primary : AppColors.error,
      ),
    );
  }

  Widget _buildStepNode(String title, bool isActivated, bool isCurrent) {
    return Column(
      children: [
        Icon(
          isCurrent
              ? Icons.radio_button_checked
              : (isActivated ? Icons.check_circle : Icons.radio_button_off),
          color: isActivated ? AppColors.primary : Colors.grey[400],
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isActivated ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActivated) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActivated ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}