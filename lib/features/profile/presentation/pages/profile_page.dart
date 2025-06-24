import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '個人檔案',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // 設置功能
            },
            icon: const Icon(
              Icons.settings,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 個人頭像和基本信息
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '用戶名稱',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'ENFP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 功能選項
            _buildMenuItem(
              icon: Icons.edit,
              title: '編輯個人檔案',
              subtitle: '更新你的照片和信息',
              onTap: () => context.go('/profile-setup'),
            ),
            
            const SizedBox(height: 12),
            
            _buildMenuItem(
              icon: Icons.psychology,
              title: 'MBTI 測試',
              subtitle: '重新進行人格測試',
              onTap: () => context.go('/mbti-test'),
            ),
            
            const SizedBox(height: 12),
            
            _buildMenuItem(
              icon: Icons.favorite,
              title: '我的喜歡',
              subtitle: '查看你喜歡的人',
              onTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            _buildMenuItem(
              icon: Icons.security,
              title: '隱私設置',
              subtitle: '管理你的隱私偏好',
              onTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            _buildMenuItem(
              icon: Icons.help,
              title: '幫助與支援',
              subtitle: '常見問題和客服',
              onTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            _buildMenuItem(
              icon: Icons.logout,
              title: '登出',
              subtitle: '退出當前帳號',
              onTap: () => context.go('/welcome'),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFFE91E63),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF2D3748),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
} 