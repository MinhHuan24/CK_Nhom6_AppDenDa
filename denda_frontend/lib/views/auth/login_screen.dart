import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../user/home/home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(_usernameController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    if (success) {
      debugPrint("--- ĐĂNG NHẬP THÀNH CÔNG ---");
      debugPrint("Quyền hạn bóc tách từ Token: ${authProvider.role}");
      if (authProvider.role == 'Admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tài khoản hoặc mật khẩu không chính xác!'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/logo_denda.png', fit: BoxFit.cover, alignment: Alignment.topCenter)),
          Positioned.fill(child: Container(color: Colors.white.withValues(alpha: 0.85))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          height: 160, width: 160,
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))]),
                          child: ClipRRect(borderRadius: BorderRadius.circular(80), child: Image.asset('assets/logo_denda.png', fit: BoxFit.cover)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('ĐEN ĐÁ SIGNATURE', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.2)),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Tài khoản (Username)', prefixIcon: const Icon(Icons.person, color: AppColors.primary), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        validator: (val) => val!.trim().isEmpty ? 'Vui lòng nhập tài khoản' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController, obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock, color: AppColors.primary), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primary), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                        ),
                        validator: (val) => val!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.black87)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                            child: const Text('Đăng ký ngay', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          ),
                        ],
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