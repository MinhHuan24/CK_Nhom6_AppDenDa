import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _search = '';
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    List<dynamic> products = adminProvider.products;

    if (_search.isNotEmpty) {
      products = products.where((p) => p['Name'].toString().toLowerCase().contains(_search.toLowerCase())).toList();
    }
    if (_selectedCategory != 'Tất cả') {
      products = products.where((p) => p['Category'] == _selectedCategory).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0, backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white,
        title: const Text("Quản lý thực đơn", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchSection(adminProvider),
                Expanded(
                  child: products.isEmpty
                      ? const Center(child: Text("Không có món ăn"))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100, top: 10),
                          itemCount: products.length,
                          itemBuilder: (ctx, index) {
                            final product = products[index];
                            final isAvailable = product['IsAvailable'] ?? true;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 6))],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: "product_${product['Id']}",
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: product['ImageUrl'] != null && product['ImageUrl'].toString().isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: product['ImageUrl'], width: 82, height: 82, fit: BoxFit.cover,
                                                fadeInDuration: const Duration(milliseconds: 250),
                                                placeholder: (_, __) => Container(
                                                  width: 82, height: 82, color: Colors.grey.shade200,
                                                  child: const Center(child: CircularProgressIndicator()),
                                                ),
                                                errorWidget: (_, __, ___) => Container(
                                                  width: 82, height: 82, color: const Color(0xFFEEE7E2),
                                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                                ),
                                              )
                                            : Container(
                                                width: 82, height: 82,
                                                decoration: BoxDecoration(color: const Color(0xFFEEE7E2), borderRadius: BorderRadius.circular(20)),
                                                child: const Icon(Icons.local_cafe, size: 34, color: Color(0xFF7B4B32)),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['Name'], maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 6),
                                          Text("${product['BasePrice']}đ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              isAvailable ? "Đang bán" : "Hết hàng",
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAvailable ? Colors.green.shade700 : Colors.red.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Switch(
                                          value: isAvailable,
                                          activeThumbColor: const Color(0xFF1E3A2F),
                                          activeTrackColor: const Color(0xFF1E3A2F).withValues(alpha: 0.35),
                                          onChanged: (value) async {
                                            await adminProvider.toggleAvailability(product['Id']);
                                          },
                                        ),
                                        Container(
                                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14)),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: product)));
                                            },
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              );
                          },
                        ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white, elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text("Thêm món", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProductScreen()));
        },
      ),
    );
  }

  Widget _buildSearchSection(AdminProvider adminProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Tìm món...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
            items: ['Tất cả', ...adminProvider.categories.map((c) => c['Name'].toString())].map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
        ],
      ),
    );
  }
}