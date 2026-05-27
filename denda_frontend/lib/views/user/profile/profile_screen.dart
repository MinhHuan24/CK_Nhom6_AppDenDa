import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileProvider>().loadUserData();
    });
  }

  Future<void> _changeAvatar() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
      if (picked == null) return;
      setState(() => _isUploadingAvatar = true);
      final result = await context.read<ProfileProvider>().uploadAvatar(File(picked.path));
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? AppColors.primary : Colors.red,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi upload avatar: $e'), backgroundColor: Colors.red));
    }
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentPhone) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final profileProvider = context.read<ProfileProvider>();

    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Chỉnh sửa thông tin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Họ và tên", prefixIcon: Icon(Icons.person, color: Colors.grey))),
            const SizedBox(height: 12),
            TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone, color: Colors.grey))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final dialogNavigator = Navigator.of(ctx);
              final result = await profileProvider.updateProfile(newName: nameController.text.trim(), newPhone: phoneController.text.trim());
              dialogNavigator.pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result['message'] ?? 'Cập nhật thành công!'),
                backgroundColor: result['success'] == true ? AppColors.primary : Colors.red,
              ));
            },
            child: const Text("Lưu lại", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, ProfileProvider profile) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.logout_rounded, color: Colors.redAccent), SizedBox(width: 8), Text('Đăng xuất?')]),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi tài khoản Đen Đá Coffee không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(ctx);
              cartProvider.clearCart();
              await profile.logout();
              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil('/LoginScreen', (route) => false);
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(String avatarUrl) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 110, height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatarUrl, fit: BoxFit.cover, fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => Container(color: Colors.white, child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
                errorWidget: (_, __, ___) => _buildDefaultAvatarPlaceholder(),
              )
            : _buildDefaultAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildDefaultAvatarPlaceholder() {
    return Container(color: Colors.grey[200], child: const Icon(Icons.account_circle, size: 70, color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Tài khoản của tôi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: AppColors.primary, centerTitle: true, elevation: 0),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
                      padding: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              _buildAvatarWidget(profile.avatarUrl),
                              if (_isUploadingAvatar) const Positioned.fill(child: CircleAvatar(backgroundColor: Colors.black45, child: CircularProgressIndicator(color: Colors.white))),
                              Positioned(
                                bottom: 0, right: 0,
                                child: CircleAvatar(
                                  radius: 16, backgroundColor: Colors.white,
                                  child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.camera_alt, size: 18, color: AppColors.primary), onPressed: _isUploadingAvatar ? null : _changeAvatar),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(profile.email, style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(215))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Thông tin cá nhân", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  _buildInfoTile(Icons.person_outline, "Họ và tên", profile.name),
                                  const Divider(height: 1, indent: 45),
                                  _buildInfoTile(Icons.phone_android, "Số điện thoại", profile.phone),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("Cài đặt ứng dụng", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  _buildMenuTile(icon: Icons.edit_note_rounded, title: "Chỉnh sửa hồ sơ", iconColor: Colors.blue, onTap: () => _showEditProfileDialog(context, profile.name, profile.phone)),
                                  const Divider(height: 1, indent: 45),
                                  _buildMenuTile(icon: Icons.history_toggle_off_rounded, title: "Lịch sử mua hàng", iconColor: Colors.orange, onTap: () => Navigator.pop(context)),
                                  const Divider(height: 1, indent: 45),
                                  _buildMenuTile(icon: Icons.lock_outline_rounded, title: "Đổi mật khẩu", iconColor: Colors.teal, onTap: () {}),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity, height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: Colors.redAccent),
                              icon: const Icon(Icons.logout_rounded), label: const Text("Đăng xuất tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => _showLogoutConfirmDialog(context, profile),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.primary, size: 20)),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required Color iconColor, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }
}