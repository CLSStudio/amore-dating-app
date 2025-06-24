import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ai/pages/conversation_analysis_page.dart';
import '../admin/admin_panel_page.dart';
import '../../core/services/admin_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null 
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null 
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? '用戶',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            
            // AI 對話分析入口
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                leading: const Icon(
                  Icons.analytics,
                  color: Color(0xFFE91E63),
                ),
                title: const Text(
                  'AI 對話分析',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('分析聊天對象的真心度和兼容性'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConversationAnalysisPage(),
                    ),
                  );
                },
              ),
            ),
            
            // 管理員面板入口（僅管理員可見）
            if (AdminService.isCurrentUserAdmin()) ...[
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.red,
                  ),
                  title: const Text(
                    '🔑 管理員面板',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text('系統管理和數據統計'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPanelPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            const Text(
              '更多功能即將推出',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 