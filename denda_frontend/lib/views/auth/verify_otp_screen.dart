import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen
    extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() =>
      _VerifyOtpScreenState();
}

class _VerifyOtpScreenState
    extends State<VerifyOtpScreen> {
  final otpController =
      TextEditingController();

  bool isLoading = false;

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    final success =
        await AuthService().verifyOtp(
      widget.email,
      otpController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResetPasswordScreen(
            email: widget.email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('OTP không đúng'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Xác nhận OTP'),
        backgroundColor:
            AppColors.primary,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Text(
              'OTP đã gửi tới:\n${widget.email}',
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
                  otpController,
              keyboardType:
                  TextInputType
                      .number,
              decoration:
                  InputDecoration(
                hintText:
                    'Nhập OTP',
                prefixIcon:
                    const Icon(
                  Icons.password,
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
                        : verifyOtp,
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      AppColors
                          .primary,
                ),
                child: const Text(
                  'XÁC NHẬN OTP',
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