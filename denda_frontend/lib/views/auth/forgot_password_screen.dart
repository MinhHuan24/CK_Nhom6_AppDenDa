import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _emailController =
      TextEditingController();

  bool isLoading = false;

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              'Vui lòng nhập email'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final success =
        await AuthService().forgotPassword(
      _emailController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email:
                _emailController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
              'Email không tồn tại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Quên mật khẩu'),
        backgroundColor:
            AppColors.primary,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.lock_reset,
              size: 90,
              color: AppColors.primary,
            ),

            const SizedBox(height: 20),

            const Text(
              'Nhập email để nhận OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
                  _emailController,
              decoration:
                  InputDecoration(
                hintText:
                    'Nhập email',
                prefixIcon:
                    const Icon(
                  Icons.email,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
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
                    isLoading
                        ? null
                        : _sendOtp,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors
                          .primary,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color:
                            Colors
                                .white,
                      )
                    : const Text(
                        'GỬI OTP',
                        style:
                            TextStyle(
                          color: Colors
                              .white,
                          fontWeight:
                              FontWeight
                                  .bold,
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