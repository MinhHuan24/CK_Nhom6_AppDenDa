import 'package:flutter/material.dart';
import '../../../../models/order_model.dart';
import 'review_screen.dart';

class SelectReviewProductScreen extends StatelessWidget {
  final OrderModel order;

  const SelectReviewProductScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn món để đánh giá'),
      ),
      body: ListView.builder(
        itemCount: order.items.length,
        itemBuilder: (context, index) {
          final item = order.items[index];

          return ListTile(
            leading: item.imageUrl != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.local_cafe),

            title: Text(item.productName),

            subtitle: Text(
              'x${item.quantity}',
            ),

            trailing:
                const Icon(Icons.chevron_right),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(
                    productId:
                        item.productId,
                    orderId:
                        order.id,
                    productName:
                        item.productName,
                    imageUrl:
                        item.imageUrl,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}