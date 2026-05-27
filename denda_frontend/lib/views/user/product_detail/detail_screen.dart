// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_colors.dart';
import '../../../models/product_model.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
//import '../../../services/review_service.dart';


class DetailScreen extends StatefulWidget {
  final ProductModel product;

  const DetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  OptionModel? selectedSize;
  OptionModel? selectedSugar;
  OptionModel? selectedIce;

  List<OptionModel> selectedToppings = [];

  int quantity = 1;

  final ReviewService _reviewService = ReviewService();

  List<ReviewModel> reviews = [];

  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();

    // Gán các giá trị mặc định khi mở màn hình
    final options = Provider.of<ProductProvider>(
      context,
      listen: false,
    ).options;

    if (options['Size'] != null &&
        options['Size']!.isNotEmpty) {
      selectedSize = options['Size']![0];
    }

    if (options['Sugar'] != null &&
        options['Sugar']!.isNotEmpty) {
      selectedSugar = options['Sugar']![0];
    }

    if (options['Ice'] != null &&
        options['Ice']!.isNotEmpty) {
      selectedIce = options['Ice']![0];
    }

    loadReviews();
  }

  Future<void>
      loadReviews() async {
    final result =
        await _reviewService
            .getReviewsByProduct(
      widget.product.id
          .toString(),
    );

    if (!mounted) return;

    setState(() {
      reviews = result;
      isLoadingReviews =
          false;
    });
  }

  // Hàm tính tổng tiền
  double calculateTotalPrice() {
    double basePrice = widget.product.price;

    double sizePrice = selectedSize?.price ?? 0;

    double toppingPrice = selectedToppings.fold(
      0,
      (sum, item) => sum + item.price,
    );

    return (basePrice + sizePrice + toppingPrice) *
        quantity;
  }

  // Tính rating trung bình
  double get averageRating {
    if (reviews.isEmpty) {
      return 0;
    }

    double total =
        reviews.fold(
      0,
      (sum, review) =>
          sum + review.rating,
    );

    return total /
        reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context);

    final options = productProvider.options;

    final averageRating =
    reviews.isEmpty
        ? 0.0
        : reviews
                .map((e) => e.rating)
                .reduce((a, b) => a + b) /
            reviews.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        title: Text(
          widget.product.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // 1. Hình ảnh sản phẩm
                  widget.product.imageUrl != null &&
                          widget.product.imageUrl!
                              .isNotEmpty
                      ? Image.network(
                          widget.product.imageUrl!,
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 240,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.coffee,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),

                  Padding(
                    padding:
                        const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${widget.product.price.toStringAsFixed(0)} đ (Giá gốc)',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepOrange,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 22,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                reviews.isEmpty
                                    ? '0.0'
                                    : averageRating
                                        .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                '(${reviews.length} đánh giá)',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 30),

                        // 2. SIZE
                        if (options['Size'] != null) ...[
                          const Text(
                            'Chọn Kích Cỡ (Size)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          ...options['Size']!.map(
                            (opt) =>
                                RadioListTile<
                                    OptionModel>(
                              title: Text(
                                '${opt.name} (${opt.price > 0 ? "+${opt.price.toStringAsFixed(0)} đ" : "Miễn phí"})',
                              ),
                              value: opt,
                              groupValue:
                                  selectedSize,
                              activeColor:
                                  AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  selectedSize =
                                      val;
                                });
                              },
                            ),
                          ),

                          const Divider(),
                        ],

                        // 3. ĐƯỜNG
                        if (options['Sugar'] !=
                            null) ...[
                          const Text(
                            'Chọn Mức Đường',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          ...options['Sugar']!.map(
                            (opt) =>
                                RadioListTile<
                                    OptionModel>(
                              title:
                                  Text(opt.name),
                              value: opt,
                              groupValue:
                                  selectedSugar,
                              activeColor:
                                  AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  selectedSugar =
                                      val;
                                });
                              },
                            ),
                          ),

                          const Divider(),
                        ],

                        // 4. ĐÁ
                        if (options['Ice'] != null) ...[
                          const Text(
                            'Chọn Mức Đá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          ...options['Ice']!.map(
                            (opt) =>
                                RadioListTile<
                                    OptionModel>(
                              title:
                                  Text(opt.name),
                              value: opt,
                              groupValue:
                                  selectedIce,
                              activeColor:
                                  AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  selectedIce =
                                      val;
                                });
                              },
                            ),
                          ),

                          const Divider(),
                        ],

                        // 5. TOPPING
                        if (options['Topping'] !=
                            null) ...[
                          const Text(
                            'Thêm Topping đi kèm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          ...options['Topping']!
                              .map(
                            (opt) =>
                                CheckboxListTile(
                              title: Text(
                                '${opt.name} (+${opt.price.toStringAsFixed(0)} đ)',
                              ),
                              value:
                                  selectedToppings
                                      .contains(
                                opt,
                              ),
                              activeColor:
                                  AppColors.primary,
                              onChanged:
                                  (bool?
                                      checked) {
                                setState(() {
                                  if (checked ==
                                      true) {
                                    selectedToppings
                                        .add(opt);
                                  } else {
                                    selectedToppings
                                        .remove(
                                            opt);
                                  }
                                });
                              },
                            ),
                          ),
                        ],

                      const SizedBox(height: 24),

                      const Divider(),

                      const SizedBox(height: 16),

                      const Text(
                        'Đánh giá khách hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (isLoadingReviews)
                        const Center(
                          child:
                              CircularProgressIndicator(),
                        )

                      else if (reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                                  20),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.grey[100],
                            borderRadius:
                                BorderRadius
                                    .circular(14),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons
                                    .reviews_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Chưa có đánh giá nào',
                                style: TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )

                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              reviews.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                                      height: 14),
                          itemBuilder:
                              (context, index) {
                            final review =
                                reviews[index];

                            return Container(
                              padding:
                                  const EdgeInsets
                                      .all(16),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withValues(
                                      alpha:
                                          0.05,
                                    ),
                                    blurRadius:
                                        8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            AppColors
                                                .primary,
                                        child: Text(
                                          review
                                              .userName[
                                                  0]
                                              .toUpperCase(),
                                          style:
                                              const TextStyle(
                                            color: Colors
                                                .white,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                          width:
                                              10),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              review
                                                  .userName,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            Text(
                                              DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(
                                                review
                                                    .createdAt,
                                              ),
                                              style:
                                                  TextStyle(
                                                color: Colors
                                                        .grey[
                                                    600],
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 10),

                                  Row(
                                    children:
                                        List.generate(
                                      5,
                                      (star) =>
                                          Icon(
                                        star <
                                                review
                                                    .rating
                                            ? Icons
                                                .star
                                            : Icons
                                                .star_border,
                                        color: Colors
                                            .amber,
                                        size:
                                            20,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 10),

                                  Text(
                                    review.comment,
                                    style:
                                        const TextStyle(
                                      height:
                                          1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. THANH ĐÁY
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),

            child: Row(
              children: [
                // Nút tăng giảm
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons
                            .remove_circle_outline,
                        size: 28,
                      ),
                      onPressed: quantity > 1
                          ? () {
                              setState(() {
                                quantity--;
                              });
                            }
                          : null,
                    ),

                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 28,
                        color:
                            AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                // Nút thêm giỏ hàng
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 14,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),

                    onPressed: () {
                      double basePrice = widget.product.price;
                      double sizePrice =
                          selectedSize?.price ?? 0;
                      double toppingPrice =
                          selectedToppings.fold(
                        0,
                        (sum, item) => sum + item.price,
                      );
                      double singleCollapsePrice =
                          basePrice +
                              sizePrice +
                              toppingPrice;
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(
                        product: widget.product,
                        size: selectedSize,
                        sugar: selectedSugar,
                        ice: selectedIce,
                        toppings: selectedToppings,
                        quantity: quantity,
                        singlePrice:
                            singleCollapsePrice,
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm $quantity x ${widget.product.name} vào giỏ hàng thành công!',
                          ),
                          backgroundColor:
                              Colors.green,
                          duration:
                              const Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },

                    child: Text(
                      'Thêm - ${calculateTotalPrice().toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}