// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart'; 
import '../../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _noteController = TextEditingController();
  final _addressController = TextEditingController(); 
  
  String _orderType = 'Takeaway'; 
  String _paymentMethod = 'Cash'; 
  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleCheckout(CartProvider cartProvider) async {
    if (cartProvider.items.isEmpty) return;
    if (_orderType == 'Delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ nhận hàng của bạn!', style: TextStyle(fontWeight: FontWeight.w500)),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3.5,
            ),
          ),
        ),
      ),
    );

    final success = await cartProvider.checkOutOrder(
      note: _noteController.text.trim(),
      orderType: _orderType,
      address: _orderType == 'Delivery' ? _addressController.text.trim() : 'Nhận tại cửa hàng',
      paymentMethod: _paymentMethod,
    );

    Navigator.pop(context); 

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 65),
              SizedBox(height: 14),
              Text(
                'Đặt hàng thành công!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'Đơn hàng Đen Đá Coffee của bạn đã được gửi lên hệ thống. Hãy đợi giây lát để nhân viên chuẩn bị đồ uống nhé.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Tuyệt vời', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt hàng thất bại! Vui lòng thử lại sau.', style: TextStyle(fontWeight: FontWeight.w500)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng hiện tại', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[200], height: 1),
          ),
        ),
        body: cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_cafe_outlined, size: 70, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 20),
                    const Text('Giỏ hàng trống trơn!', style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Hãy lựa chọn những thức uống Đen Đá Signature nhé.', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. CHI TIẾT DANH SÁCH MÓN ĂN ĐÃ CHỌN
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                            child: Text(
                              'CÁC MÓN ĐÃ CHỌN (${cartItems.length})', 
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 0.8)
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (ctx, i) {
                              final item = cartItems[i];
                              
                              List<String> optionsText = [];
                              if (item.size != null) optionsText.add('Size ${item.size!.name}');
                              if (item.sugar != null) optionsText.add('${item.sugar!.name} đường');
                              if (item.ice != null) optionsText.add('${item.ice!.name} đá');
                              if (item.toppings.isNotEmpty) {
                                optionsText.add('+ ${item.toppings.map((t) => t.name).join(", ")}');
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03), 
                                      blurRadius: 12, 
                                      offset: const Offset(0, 4)
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                                            ? Image.network(item.product.imageUrl!, width: 80, height: 80, fit: BoxFit.cover)
                                            : Container(width: 80, height: 80, color: Colors.grey[100], child: const Icon(Icons.coffee, color: Colors.grey)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name, 
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (optionsText.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(optionsText.join(' • '), style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.3)),
                                              ),
                                            const SizedBox(height: 10),
                                            Text(
                                              '${item.singleCollapsePrice.toStringAsFixed(0)}đ', 
                                              style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.w800, fontSize: 15)
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(Icons.cancel_rounded, size: 22, color: Colors.grey[300]),
                                            onPressed: () => cartProvider.removeItem(item.id),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              border: Border.all(color: Colors.grey[200]!),
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: item.quantity > 1 ? () => cartProvider.updateQuantity(item.id, item.quantity - 1) : null,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(6.0),
                                                    child: Icon(Icons.remove_rounded, size: 16, color: item.quantity > 1 ? Colors.black87 : Colors.grey[300]),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text('${item.quantity}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                                                ),
                                                GestureDetector(
                                                  onTap: () => cartProvider.updateQuantity(item.id, item.quantity + 1),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(6.0),
                                                    child: Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // 2. HÌNH THỨC NHẬN HÀNG
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 10),
                            child: Text('HÌNH THỨC NHẬN HÀNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 0.8)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200], 
                              borderRadius: BorderRadius.circular(14)
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _buildOrderTypeButton('Takeaway', 'Đến quán lấy')),
                                Expanded(child: _buildOrderTypeButton('Delivery', 'Giao tận nơi')),
                              ],
                            ),
                          ),

                          // 3. Ô NHẬP ĐỊA CHỈ (Ẩn khi chọn Takeaway, Hiện khi chọn Delivery)
                          if (_orderType == 'Delivery') ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 24, bottom: 10),
                              child: Text('ĐỊA CHỈ GIAO HÀNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 0.8)),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))
                                ]
                              ),
                              child: TextField(
                                controller: _addressController,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Nhập địa chỉ nhận hàng chính xác (Số nhà, tên đường...)',
                                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 16.0),
                                    child: Icon(Icons.location_on_rounded, color: AppColors.error, size: 22),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],

                          // 4. PHƯƠNG THỨC THANH TOÁN
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 10),
                            child: Text('PHƯƠNG THỨC THANH TOÁN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 0.8)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))
                              ]
                            ),
                            child: Column(
                              children: [
                                _buildPaymentMethodTile(
                                  method: 'Cash',
                                  title: 'Tiền mặt tại quầy / Khi nhận đồ',
                                  subtitle: 'Thanh toán trực tiếp bằng tiền mặt',
                                  icon: Icons.money_rounded,
                                  iconColor: Colors.green,
                                ),
                                Divider(height: 1, color: Colors.grey[100]),
                                _buildPaymentMethodTile(
                                  method: 'Transfer',
                                  title: 'Chuyển khoản Ngân hàng / Ví điện tử',
                                  subtitle: 'Chuyển khoản nhanh qua mã QR',
                                  icon: Icons.account_balance_rounded,
                                  iconColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),

                          // 5. Ô NHẬP GHI CHÚ ĐƠN HÀNG
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 10),
                            child: Text('GHI CHÚ ĐƠN HÀNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 0.8)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))
                              ]
                            ),
                            child: TextField(
                              controller: _noteController,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Ít đường, ít đá hoặc ghi chú điểm giao tại đây...',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: Icon(Icons.sticky_note_2_outlined, color: AppColors.primary, size: 22),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // 6. THANH TOÁN TỔNG TIỀN BOTTOM BAR
                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, -6)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Tổng thanh toán', style: TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              '${cartProvider.totalAmount.toStringAsFixed(0)}đ',
                              style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 180,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _handleCheckout(cartProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('ĐẶT HÀNG NGAY', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildOrderTypeButton(String type, String label) {
    final isSelected = _orderType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _orderType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primary : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _paymentMethod == method;
    return ListTile(
      onTap: () => setState(() => _paymentMethod = method),
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
        color: isSelected ? AppColors.primary : Colors.grey[300],
        size: 22,
      ),
    );
  }
}