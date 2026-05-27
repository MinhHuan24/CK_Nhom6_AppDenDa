import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // ignore: prefer_final_fields
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký tài khoản Đen Đá thành công! Vui lòng đăng nhập.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Trở về màn hình đăng nhập sau khi đăng ký thành công
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thất bại hoặc tên tài khoản đã tồn tại!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/logo_denda.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: Container(
              // ĐÃ SỬA: Thay đổi .withOpacity thành .withValues để tương thích SDK mới
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        alignment: Alignment.centerLeft,
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'TẠO TÀI KHOẢN MỚI',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 24),
                      
                      // Tên tài khoản
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập (Username)',
                          prefixIcon: const Icon(Icons.account_circle, color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val!.trim().isEmpty ? 'Vui lòng nhập tên tài khoản' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Họ và Tên
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: const Icon(Icons.badge, color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val!.trim().isEmpty ? 'Vui lòng nhập họ và tên của bạn' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val!.isEmpty) return 'Vui lòng nhập email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Mật khẩu
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val!.length < 6 ? 'Mật khẩu phải từ 6 ký tự trở lên' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Xác nhận mật khẩu
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => val != _passwordController.text ? 'Mật khẩu xác nhận không khớp' : null,
                      ),
                      const SizedBox(height: 28),
                      
                      // Nút Đăng Ký
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ĐĂNG KÝ NGAY', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}