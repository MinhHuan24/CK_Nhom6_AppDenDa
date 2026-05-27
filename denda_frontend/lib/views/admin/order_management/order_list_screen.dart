import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;

      case 'Preparing':
        return Colors.blue;

      case 'Shipping':
        return Colors.purple;

      case 'Completed':
        return Colors.green;

      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xác nhận';

      case 'Preparing':
        return 'Đang pha chế';

      case 'Shipping':
        return 'Đang giao';

      case 'Completed':
        return 'Hoàn tất';

      default:
        return 'Đã huỷ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A2F),
        foregroundColor: Colors.white,
        title: const Text(
          "Quản lý đơn hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: adminProvider.orders.length,
              itemBuilder: (ctx, index) {
                final order = adminProvider.orders[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    title: Text(
                      "Đơn #${order['Id']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(order['CustomerName']),
                    ),

                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['Status'])
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _getStatusText(order['Status']),
                        style: TextStyle(
                          color: _getStatusColor(order['Status']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              "Tổng tiền",
                              "${order['FinalAmount']}đ",
                            ),

                            _buildInfoRow(
                              "Thanh toán",
                              order['PaymentMethod'],
                            ),

                            _buildInfoRow(
                              "Địa chỉ",
                              order['DeliveryAddress'],
                            ),

                            const Divider(height: 30),

                            ...((order['Details'] ?? []) as List)
                                .map(
                              (item) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${item['ProductName']} x${item['Quantity']}",
                                      ),
                                    ),
                                    Text(
                                      "${item['PriceAtOrder']}đ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildActionButton(
                              adminProvider,
                              order,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Text(value))
        ],
      ),
    );
  }

  Widget _buildActionButton(
    AdminProvider provider,
    dynamic order,
  ) {
    if (order['Status'] == 'Pending') {
      return _button(
        "Xác nhận đơn",
        Colors.blue,
        () => provider.updateOrderStatus(
          order['Id'],
          'Preparing',
        ),
      );
    }

    if (order['Status'] == 'Preparing') {
      return _button(
        "Bắt đầu giao",
        Colors.purple,
        () => provider.updateOrderStatus(
          order['Id'],
          'Shipping',
        ),
      );
    }

    if (order['Status'] == 'Shipping') {
      return _button(
        "Hoàn tất đơn",
        Colors.green,
        () => provider.updateOrderStatus(
          order['Id'],
          'Completed',
        ),
      );
    }

    return const SizedBox();
  }

  Widget _button(
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}