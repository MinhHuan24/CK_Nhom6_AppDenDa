import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final int productId;
  final int orderId;
  final String productName;
  final String? imageUrl;

  const ReviewScreen({
    super.key,
    required this.productId,
    required this.orderId,
    required this.productName,
    this.imageUrl,
  });

  @override
  State<ReviewScreen> createState() =>
      _ReviewScreenState();
}

class _ReviewScreenState
    extends State<ReviewScreen> {
  final _commentController =
      TextEditingController();

  final ReviewService _reviewService =
      ReviewService();

  int _rating = 0;
  bool _isLoading = false;

  final List<String> _quickReviews = [
    'Ngon tuyệt!',
    'Đậm vị, sẽ mua lại',
    'Giao nhanh',
    'Rất đáng tiền',
    'Món yêu thích',
    'Đóng gói đẹp',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Vui lòng chọn số sao'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final success =
          await _reviewService.createReview(
        token: authProvider.token!,
        productId: widget.productId,
        orderId: widget.orderId,
        rating: _rating,
        comment:
            _commentController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            backgroundColor:
                Colors.green,
            content: Text(
              'Đánh giá thành công 🎉',
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            backgroundColor:
                Colors.red,
            content: Text(
              'Gửi đánh giá thất bại',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              'Có lỗi xảy ra: $e'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _ratingText() {
    switch (_rating) {
      case 1:
        return 'Rất tệ 😞';
      case 2:
        return 'Chưa hài lòng 😕';
      case 3:
        return 'Tạm ổn 🙂';
      case 4:
        return 'Khá tốt 😍';
      case 5:
        return 'Tuyệt vời 🤎';
      default:
        return 'Bạn thấy món này thế nào?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Đánh giá sản phẩm',
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            // PRODUCT CARD
            Container(
              padding:
                  const EdgeInsets.all(
                      16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                            alpha:
                                0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                                14),
                    child: widget
                                .imageUrl !=
                            null
                        ? Image.network(
                            widget
                                .imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit
                                .cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors
                                .grey[300],
                            child:
                                const Icon(
                              Icons
                                  .coffee,
                              size: 40,
                            ),
                          ),
                  ),
                  const SizedBox(
                      width: 14),
                  Expanded(
                    child: Text(
                      widget
                          .productName,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
                height: 30),

            const Text(
              'Chất lượng món',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 16),

            // STAR RATING
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: List.generate(
                5,
                (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating =
                            index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating
                          ? Icons.star
                          : Icons
                              .star_border,
                      color: Colors
                          .amber,
                      size: 40,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _ratingText(),
              style: TextStyle(
                fontSize: 16,
                color:
                    Colors.grey[700],
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
                height: 28),

            // QUICK REVIEW
            Align(
              alignment:
                  Alignment
                      .centerLeft,
              child: Text(
                'Gợi ý đánh giá',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(
                height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _quickReviews.map(
                (text) {
                  return InkWell(
                    onTap: () {
                      _commentController
                              .text =
                          text;
                    },
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            16,
                        vertical: 10,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    30),
                        border:
                            Border.all(
                          color:
                              AppColors
                                  .primary,
                        ),
                      ),
                      child: Text(
                        text,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),

            const SizedBox(
                height: 22),

            // COMMENT
            TextField(
              controller:
                  _commentController,
              maxLines: 5,
              decoration:
                  InputDecoration(
                hintText:
                    'Chia sẻ trải nghiệm của bạn...',
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
                height: 30),

            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _submitReview,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors
                          .primary,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                18),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white,
                      )
                    : const Text(
                        'GỬI ĐÁNH GIÁ',
                        style:
                            TextStyle(
                          color: Colors
                              .white,
                          fontWeight:
                              FontWeight
                                  .bold,
                          fontSize:
                              16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}