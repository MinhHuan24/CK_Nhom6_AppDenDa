import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart'; 
import '../cart/cart_screen.dart';              
import '../product_detail/detail_screen.dart';
import '../orders/order_history_screen.dart';
import '../profile/profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomIndex = 0; // Quản lý tab đang chọn ở BottomNavigationBar

  final TextEditingController _searchController = TextEditingController();

  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).loadMenuData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm xử lý logic Đăng xuất tài khoản 
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Đăng xuất?'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi tài khoản Đen Đá Coffee không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.of(context).pushNamedAndRemoveUntil('/LoginScreen', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // 1. THANH APP BAR CHUYÊN NGHIỆP CÓ TÌM KIẾM
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              Provider.of<ProductProvider>(
                context,
                listen: false,
              ).searchProduct(value);

              setState(() {
                _showSuggestions =
                    value.trim().isNotEmpty;
              });
            },
            decoration: InputDecoration(
              hintText:
                  'Tìm món tại Đen Đá Signature...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();

                            Provider.of<
                                ProductProvider>(
                              context,
                              listen: false,
                            ).searchProduct('');

                            setState(() {
                              _showSuggestions =
                                  false;
                            });
                          },
                        )
                      : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 10,
              ),
            ),
          ),
        ),
        actions: [
          // ICON GIỎ HÀNG CÓ BADGE
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.amber[700], 
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${Provider.of<CartProvider>(context).itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 24),
            tooltip: 'Đăng xuất tài khoản',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      
      // BODY ĐƯỢC CHIA THÀNH CÁC PHÂN VÙNG THEO STYLE CỦA GRAB
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadMenuData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showSuggestions &&
                  productProvider.suggestions
                      .isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(
                          alpha: 0.06,
                        ),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        productProvider
                            .suggestions.length,
                    separatorBuilder:
                        (_, __) => Divider(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                    itemBuilder: (context, index) {
                      final product =
                          productProvider
                              .suggestions[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.grey[100],
                          backgroundImage:
                              product.imageUrl !=
                                          null &&
                                      product.imageUrl!
                                          .isNotEmpty
                                  ? NetworkImage(
                                      product.imageUrl!,
                                    )
                                  : null,
                          child: product.imageUrl ==
                                  null
                              ? const Icon(
                                  Icons.coffee,
                                )
                              : null,
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.price.toStringAsFixed(0)} đ',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                        onTap: () {
                          setState(() {
                            _showSuggestions =
                                false;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(
                                product: product,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              // PHẦN 1: BANNER HOẶC THÀNH VIÊN QUICK CARD (Giống khu vực Ví điện tử của Grab)
              _buildLoyaltyCard(),

              // PHẦN 2: LƯỚI TIỆN ÍCH DỊCH VỤ NHANH (Giống lưới dịch vụ "Xe máy, Ô tô, Đồ ăn" của Grab)
              _buildServiceGrid(),

              // PHẦN 3: BANNER KHUYẾN MÃI CUỘN NGANG
              _buildPromoBanners(),

              // PHẦN 4: TIÊU ĐỀ THỰC ĐƠN & THANH CHỌN DANH MỤC (CATEGORIES CHIP)
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  'Khám phá thực đơn Đen Đá',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              
              // THANH CUỘN CATEGORIES CHIPS
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: productProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = productProvider.selectedCategoryId == null;
                      return _buildCategoryChip("Tất cả", null, isSelected);
                    }

                    final category = productProvider.categories[index - 1];
                    final isSelected = productProvider.selectedCategoryId == category.id;
                    return _buildCategoryChip(category.name, category.id, isSelected);
                  },
                ),
              ),

              // PHẦN 5: GRID DANH SÁCH MÓN ĂN
              productProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  : productProvider.products.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(child: Text('Hiện tại danh mục này chưa có món.')),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: productProvider.products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(productProvider.products[index]);
                          },
                        ),
            ],
          ),
        ),
      ),

      // 2. THANH BOTTOM NAVIGATION BAR CHUYÊN NGHIỆP ĐỂ CHUẨN BỊ CHO BƯỚC 1 (Lịch sử, Ưu đãi,...)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
          });
          
          // NẾU USER BẤM VÀO TAB HOẠT ĐỘNG (INDEX = 2)
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
            ).then((_) {
              // Khối lệnh này chạy khi user BACK từ màn hình Hoạt động về Trang chủ
              if (mounted) {
                setState(() {
                  _currentBottomIndex = 0; // Reset thanh điều hướng về lại Trang chủ
                });
              }
            });
          }
          
          // NẾU USER BẤM VÀO TAB TÀI KHOẢN (INDEX = 3)
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ).then((_) {
              // Khối lệnh này chạy khi user BACK từ màn hình Tài khoản về Trang chủ
              if (mounted) {
                setState(() {
                  _currentBottomIndex = 0; // Reset thanh điều hướng về lại Trang chủ
                });
              }
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num_outlined), label: 'Ưu đãi'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Hoạt động'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Tài khoản'),
        ],
      ),
    );
  }

  // 1. Widget Thẻ Thành Viên & Điểm thưởng nhanh (Giống GrabRewards/ GrabPayment)
  Widget _buildLoyaltyCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLoyaltyItem(Icons.stars_rounded, 'ĐenĐa Xu', '250 xu', Colors.amber[700]!),
          Container(height: 30, width: 1, color: Colors.grey[200]),
          _buildLoyaltyItem(Icons.card_membership_rounded, 'Hạng thẻ', 'Thành viên Bạc', Colors.blueGrey),
          Container(height: 30, width: 1, color: Colors.grey[200]),
          _buildLoyaltyItem(Icons.wallet_giftcard_rounded, 'Voucher ví', '3 Mã giảm giá', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildLoyaltyItem(IconData icon, String title, String subtitle, Color color) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // 2. Widget Lưới Tiện Ích Dịch Vụ Nhanh (Giao tận nơi, Đến quán lấy, Quà tặng, Đặt bàn)
  Widget _buildServiceGrid() {
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.delivery_dining_rounded, 'title': 'Giao tận nơi', 'color': Colors.orange[100]},
      {'icon': Icons.storefront_rounded, 'title': 'Đến quán lấy', 'color': Colors.green[100]},
      {'icon': Icons.card_giftcard_rounded, 'title': 'Tặng quà bè', 'color': Colors.pink[100]},
      {'icon': Icons.event_seat_rounded, 'title': 'Đặt bàn trước', 'color': Colors.blue[100]},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final item = services[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: item['color'],
                child: Icon(item['icon'], color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                item['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              )
            ],
          );
        },
      ),
    );
  }

  // 3. Widget Các Banner Khuyến Mãi Ngang Chạy Slide mượt mà
  Widget _buildPromoBanners() {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: index == 0 
                    ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)] 
                    : [const Color(0xFFD4145A), const Color(0xFFFBB03B)],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  index == 0 ? 'ƯU ĐÃI ĐEN ĐÁ TỚI 50K' : 'MÓN MỚI SIGNATURE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  index == 0 ? 'Nhập mã DENDA50 áp dụng cho đơn từ 100K' : 'Trải nghiệm hương vị đậm đà nguyên bản',
                  style: const TextStyle(color: Colors.white70,fontSize: 12,),
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Widget Nút danh mục lựa chọn (Thay thế ChoiceChip mặc định nhìn thô bằng Custom Chip)
  Widget _buildCategoryChip(String title, int? id, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        onTap: () {
          Provider.of<ProductProvider>(context, listen: false).selectCategory(id);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 5. Widget Hiển thị Thẻ Sản phẩm (Đã bo góc mềm mại, đổ bóng nhẹ chuẩn thương mại điện tử)
  Widget _buildProductCard(dynamic product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(product: product)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh Bo Góc Phía Trên
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        width: double.infinity,
                        child: const Icon(Icons.coffee_rounded, size: 45, color: Colors.grey),
                      ),
              ),
            ),
            // Phần Thông Tin Sản Phẩm
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} đ',
                        style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      // Nút tròn dấu cộng thêm nhanh món vào giỏ hàng tăng trải nghiệm
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}