import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen
    extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen>
      createState() =>
          _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<
        ResetPasswordScreen> {
  final passwordController =
      TextEditingController();

  bool obscure = true;

  Future<void> resetPassword()
  async {
    final success =
        await AuthService()
            .resetPassword(
      widget.email,
      passwordController.text
          .trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Đổi mật khẩu thành công',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Mật khẩu mới'),
        backgroundColor:
            AppColors.primary,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller:
                  passwordController,
              obscureText: obscure,
              decoration:
                  InputDecoration(
                hintText:
                    'Nhập mật khẩu mới',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
                suffixIcon:
                    IconButton(
                  onPressed: () {
                    setState(() {
                      obscure =
                          !obscure;
                    });
                  },
                  icon: Icon(
                    obscure
                        ? Icons
                            .visibility_off
                        : Icons
                            .visibility,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    resetPassword,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors
                          .primary,
                ),
                child: const Text(
                  'ĐỔI MẬT KHẨU',
                  style: TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}