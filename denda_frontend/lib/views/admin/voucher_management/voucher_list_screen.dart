import 'package:flutter/material.dart';

class VoucherListScreen extends StatelessWidget {
  const VoucherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phát hành Mã giảm giá"), backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white),
      body: const Center(
        child: Text(
          "Tính năng phát hành mã giảm giá tự động đang trong tiến trình đồng bộ cổng khuyến mãi.",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}