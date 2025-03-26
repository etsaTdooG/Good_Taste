import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../config/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  
  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của bạn'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 16),
            _buildEditProfileButton(context),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            _buildProfileMenuItem(
              icon: Icons.history,
              title: 'Lịch sử đặt bàn',
              onTap: () {
                // Navigate to reservation history
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _buildProfileMenuItem(
              icon: Icons.favorite,
              title: 'Nhà hàng yêu thích',
              onTap: () {
                // Navigate to favorites
              },
            ),
            const Divider(height: 1),
            _buildProfileMenuItem(
              icon: Icons.notifications,
              title: 'Thông báo',
              onTap: () {
                // Navigate to notifications
              },
            ),
            const Divider(height: 1),
            _buildProfileMenuItem(
              icon: Icons.settings,
              title: 'Cài đặt',
              onTap: () {
                // Navigate to settings
              },
            ),
            const Divider(height: 1),
            _buildProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Trợ giúp & Hỗ trợ',
              onTap: () {
                // Navigate to help
              },
            ),
            const Divider(height: 1),
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: () {
                // Implement logout
              },
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 57,
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=${user.name ?? "User"}&background=random&size=200',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? 'Người dùng',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email ?? 'Chưa có email',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.phoneNumber ?? 'Chưa có số điện thoại',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditProfileButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(user: user),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit),
            const SizedBox(width: 8),
            const Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
} 