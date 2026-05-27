import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Kiểm duyệt Đánh giá"), backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: adminProvider.reviews.length,
              itemBuilder: (ctx, index) {
                final review = adminProvider.reviews[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("${review['CustomerName']} -> ${review['ProductName']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: List.generate(review['Rating'], (i) => const Icon(Icons.star, color: Colors.amber, size: 16))),
                      Text(review['Comment'] ?? '', style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      // 1. Lưu sẵn trình thông báo trước khi chạy tác vụ bất đồng bộ
                      final messenger = ScaffoldMessenger.of(context);
                      
                      bool isSuccess = await adminProvider.deleteReview(review['Id']);
                      
                      // 2. Kiểm tra điều kiện mounted an toàn của hệ thống
                      if (isSuccess && context.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Đã xóa ẩn bình luận tiêu cực thành công!")),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}