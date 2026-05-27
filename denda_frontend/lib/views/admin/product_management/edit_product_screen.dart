import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  const EditProductScreen({super.key, this.product});
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController, _priceController, _descController;
  final TextEditingController _toppingInputController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  int? _selectedCategoryId;
  bool _isAvailable = true, _isSaving = false, _isUploading = false;
  File? _selectedImage;
  String _imageUrl = '';
  List<String> _toppings = [];
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?['Name'] ?? '');
    _priceController = TextEditingController(text: p?['BasePrice']?.toString() ?? '');
    _descController = TextEditingController(text: p?['Description'] ?? '');
    _selectedCategoryId = p?['CategoryId'] ?? 1;
    _isAvailable = p?['IsAvailable'] ?? true;
    _imageUrl = p?['ImageUrl'] ?? '';
    if (p != null && p['ToppingsConfig'] != null && p['ToppingsConfig'].toString().isNotEmpty) {
      _toppings = p['ToppingsConfig'].toString().split(',');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _toppingInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _imageUrl;
    try {
      setState(() { _isUploading = true; _uploadProgress = 0; });
      final dio = Dio();
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(_selectedImage!.path)});
      final response = await dio.post('http://10.0.2.2:5019/api/upload/product-image', data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) setState(() => _uploadProgress = sent / total);
        },
      );
      return response.data['imageUrl'];
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload ảnh thất bại'), backgroundColor: Colors.red));
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _addTopping() {
    final text = _toppingInputController.text.trim();
    if (text.isNotEmpty && !_toppings.contains(text)) {
      setState(() { _toppings.add(text); _toppingInputController.clear(); });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '').replaceAll('-', ''));
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giá bán không hợp lệ"), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSaving = true);
    final uploadedImage = await _uploadImage();
    if (uploadedImage == null) { setState(() => _isSaving = false); return; }
    _imageUrl = uploadedImage;
    final data = {
      "Name": _nameController.text.trim(),
      "BasePrice": price,
      "Description": _descController.text.trim(),
      "ImageUrl": _imageUrl,
      "CategoryId": _selectedCategoryId,
      "IsAvailable": _isAvailable,
      "ToppingsConfig": _toppings.join(','),
    };
    log(data.toString());
    final isSuccess = await context.read<AdminProvider>().saveProduct(id: widget.product?['Id'], data: data);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thực đơn thành công"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi từ máy chủ"), backgroundColor: Colors.red));
    }
  }

  Widget _buildImagePreview() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350), curve: Curves.easeInOut, width: double.infinity, height: 240,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack( fit: StackFit.expand, children: [
          if (_selectedImage != null) Image.file(_selectedImage!, fit: BoxFit.cover)
          else if (_imageUrl.isNotEmpty) CachedNetworkImage(
            imageUrl: _imageUrl, fit: BoxFit.cover, fadeInDuration: const Duration(milliseconds: 300),
            placeholder: (_, __) => Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 60, color: Colors.grey)),
          ) else Container(
            color: const Color(0xFFF1ECE8),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.image_outlined, size: 70, color: Color(0xFF7B4B32)), SizedBox(height: 10),
              Text("Chưa có ảnh món ăn", style: TextStyle(fontSize: 16, color: Color(0xFF7B4B32), fontWeight: FontWeight.w600)),
            ]),
          ),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent]))),
          Positioned(right: 14, bottom: 14, child: GestureDetector(onTap: _pickImage, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.camera_alt, color: Color(0xFF1E3A2F)))))
        ]),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, int maxLines = 1, List<TextInputFormatter>? formatters, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, maxLines: maxLines, keyboardType: keyboardType, inputFormatters: formatters, validator: validator,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(elevation: 0, backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white, title: Text(widget.product == null ? "Thêm món mới" : "Chỉnh sửa món", style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildImagePreview(),
            if (_isUploading) ...[
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: _uploadProgress, minHeight: 8, backgroundColor: Colors.grey.shade300, color: const Color(0xFF1E3A2F))),
              const SizedBox(height: 6),
              Text("Đang upload ảnh ${(100 * _uploadProgress).toInt()}%", textAlign: TextAlign.center),
            ],
            const SizedBox(height: 22),
            _buildInput(controller: _nameController, label: "Tên món", validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập tên món" : null),
            const SizedBox(height: 16),
            _buildInput(controller: _priceController, label: "Giá bán", keyboardType: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập giá" : (double.tryParse(v) == null ? "Giá không hợp lệ" : null)),
            const SizedBox(height: 16),
            _buildInput(controller: _descController, label: "Mô tả món ăn", maxLines: 3),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(labelText: "Danh mục", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
              items: const [DropdownMenuItem(value: 1, child: Text('Cà Phê')), DropdownMenuItem(value: 2, child: Text('Trà Trái Cây')), DropdownMenuItem(value: 3, child: Text('Đá Xay')), DropdownMenuItem(value: 7, child: Text('Bánh Ngọt'))],
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Đang kinh doanh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Switch(value: _isAvailable, activeThumbColor: const Color(0xFF1E3A2F), activeTrackColor: const Color(0xFF1E3A2F).withValues(alpha: 0.35), onChanged: (v) => setState(() => _isAvailable = v))
              ]),
            ),
            const SizedBox(height: 22),
            const Text("Toppings", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _toppingInputController, decoration: InputDecoration(hintText: "Nhập topping...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))),
              const SizedBox(width: 10),
              GestureDetector(onTap: _addTopping, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E3A2F), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add, color: Colors.white)))
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: _toppings.map((t) => Chip(backgroundColor: const Color(0xFFE8F5EC), label: Text(t), deleteIconColor: Colors.red, onDeleted: () => setState(() => _toppings.remove(t)))).toList()),
            const SizedBox(height: 30),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A2F), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: _isSaving ? null : _submitData,
                child: _isSaving ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : const Text("LƯU THỰC ĐƠN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}