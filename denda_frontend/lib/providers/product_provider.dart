import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _allProducts = [];
  List<ProductModel> _suggestions = [];
  Map<String, List<OptionModel>> _options = {};

  int? _selectedCategoryId;
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get suggestions => _suggestions;
  Map<String, List<OptionModel>> get options => _options;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;

  // Load menu lần đầu
  Future<void> loadMenuData() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _productService.fetchCategories();

    _products = await _productService.fetchProducts(
      categoryId: _selectedCategoryId,
    );

    // lưu danh sách gốc
    _allProducts = List.from(_products);

    _options = await _productService.fetchOptions();

    _isLoading = false;
    notifyListeners();
  }

  // Chọn category
  Future<void> selectCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;

    _isLoading = true;
    notifyListeners();

    _products = await _productService.fetchProducts(
      categoryId: _selectedCategoryId,
    );

    // cập nhật danh sách gốc
    _allProducts = List.from(_products);

    _isLoading = false;
    notifyListeners();
  }

  // SEARCH PRODUCT
  Future<void> searchProduct(String keyword) async {
    if (keyword.trim().isEmpty) {
      _products = List.from(_allProducts);
      _suggestions = [];

      notifyListeners();
      return;
    }

    final keywordLower = keyword.toLowerCase();

    // lọc danh sách chính
    _products = _allProducts.where((product) {
      return product.name
          .toLowerCase()
          .contains(keywordLower);
    }).toList();

    // gợi ý top 5 món
    _suggestions = _allProducts
        .where((product) {
          return product.name
              .toLowerCase()
              .contains(keywordLower);
        })
        .take(5)
        .toList();

    notifyListeners();
  }
}