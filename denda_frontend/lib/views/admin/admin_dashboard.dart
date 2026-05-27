import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import 'package:denda_frontend/views/auth/login_screen.dart';
import 'order_management/order_list_screen.dart';
import 'product_management/product_list_screen.dart';
import 'review_moderation/review_list_screen.dart';
import 'voucher_management/voucher_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardStats();
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn đăng xuất khỏi hệ thống admin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đăng xuất"),
          )
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminProvider>();
    final stats = adminData.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0, backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white, centerTitle: true,
        title: const Text('ĐEN ĐÁ SIGNATURE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: "Đăng xuất", onPressed: _logout,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.logout_rounded, size: 20),
              ),
            ),
          )
        ],
      ),
      body: adminData.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A2F)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E3A2F), Color(0xFF2C5545)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tổng quan kinh doanh", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 22),
                        Row(children: [
                          Expanded(child: _buildStatCard("Doanh thu", "${stats['TotalRevenue'] ?? 0}đ", Icons.payments_rounded, Colors.green)),
                          const SizedBox(width: 14),
                          Expanded(child: _buildStatCard("Đơn hàng", "${stats['TotalOrders'] ?? 0}", Icons.shopping_bag_rounded, Colors.orange)),
                        ])
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text("Phân hệ quản trị", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1,
                    children: [
                      _buildMenuCard("Quản lý\nThực đơn", Icons.coffee_rounded, const Color(0xFF8B5E3C), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
                      }),
                      _buildMenuCard("Quản lý\nĐơn hàng", Icons.receipt_long_rounded, Colors.blue, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()));
                      }),
                      _buildMenuCard("Voucher\nKhuyến mãi", Icons.card_giftcard_rounded, Colors.red, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherListScreen()));
                      }),
                      _buildMenuCard("Kiểm duyệt\nĐánh giá", Icons.rate_review_rounded, Colors.teal, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewListScreen()));
                      }),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 18),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(28), onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.4)),
          ],
        ),
      ),
    );
  }
}