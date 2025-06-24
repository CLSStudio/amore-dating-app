import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/feed_models.dart';
import '../services/feed_service.dart';
import '../widgets/feed_post_widget.dart';
import '../widgets/create_post_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_border_radius.dart';

// ================== 社交動態主頁面 ==================

class SocialFeedPage extends ConsumerStatefulWidget {
  const SocialFeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends ConsumerState<SocialFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowingFeed(),
                _buildTrendingFeed(),
                _buildMyFeed(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCreatePostFAB(),
    );
  }

  // ================== UI 組件 ==================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '動態',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: _showNotifications,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.people),
            text: '關注',
          ),
          Tab(
            icon: Icon(Icons.trending_up),
            text: '熱門',
          ),
          Tab(
            icon: Icon(Icons.person),
            text: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingFeed() {
    if (_currentUserId == null) {
      return const Center(child: Text('請先登入'));
    }

    return StreamBuilder<List<FeedPost>>(
      stream: ref.read(feedServiceProvider).getFollowingFeed(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '載入失敗: ${snapshot.error}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('重試'),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data ?? [];
        
        if (posts.isEmpty) {
          return _buildEmptyFollowingFeed();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.pagePadding,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FeedPostWidget(
                  post: posts[index],
                  currentUserId: _currentUserId!,
                  onLike: _handleLike,
                  onView: _handleView,
                  onUserTap: _handleUserTap,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendingFeed() {
    return StreamBuilder<List<FeedPost>>(
      stream: ref.read(feedServiceProvider).getTrendingFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('載入失敗: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];
        
        if (posts.isEmpty) {
          return _buildEmptyTrendingFeed();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.pagePadding,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FeedPostWidget(
                  post: posts[index],
                  currentUserId: _currentUserId!,
                  onLike: _handleLike,
                  onView: _handleView,
                  onUserTap: _handleUserTap,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyFeed() {
    if (_currentUserId == null) {
      return const Center(child: Text('請先登入'));
    }

    return StreamBuilder<List<FeedPost>>(
      stream: ref.read(feedServiceProvider).getUserFeed(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('載入失敗: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];
        
        if (posts.isEmpty) {
          return _buildEmptyMyFeed();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: AppSpacing.pagePadding,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FeedPostWidget(
                  post: posts[index],
                  currentUserId: _currentUserId!,
                  onLike: _handleLike,
                  onView: _handleView,
                  onUserTap: _handleUserTap,
                  showDeleteOption: true,
                  onDelete: _handleDelete,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyFollowingFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '還沒有關注任何人',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去發現頁面關注一些有趣的人吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // 導航到發現頁面
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
            ),
            child: const Text('去發現'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrendingFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暫無熱門動態',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '成為第一個發布動態的人！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMyFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '還沒有發布任何動態',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '分享你的精彩時刻吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showCreatePostDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
            ),
            child: const Text('發布動態'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostFAB() {
    return FloatingActionButton(
      onPressed: _showCreatePostDialog,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // ================== 事件處理 ==================

  void _handleLike(String postId) async {
    if (_currentUserId == null) return;
    
    try {
      await ref.read(feedServiceProvider).toggleLike(postId, _currentUserId!);
    } catch (e) {
      _showErrorSnackBar('點讚失敗: $e');
    }
  }

  void _handleView(String postId) async {
    if (_currentUserId == null) return;
    
    try {
      await ref.read(feedServiceProvider).recordView(postId, _currentUserId!);
    } catch (e) {
      // 靜默處理瀏覽記錄錯誤
    }
  }

  void _handleUserTap(String userId) {
    // 導航到用戶個人檔案頁面
    Navigator.pushNamed(context, '/user_profile', arguments: userId);
  }

  void _handleDelete(String postId) async {
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) return;
    
    try {
      await ref.read(feedServiceProvider).deletePost(postId);
      _showSuccessSnackBar('動態已刪除');
    } catch (e) {
      _showErrorSnackBar('刪除失敗: $e');
    }
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostWidget(
        onPostCreated: _handlePostCreated,
      ),
    );
  }

  void _handlePostCreated() {
    setState(() {}); // 刷新動態列表
    _showSuccessSnackBar('動態發布成功！');
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索動態'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '輸入關鍵字...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 實現搜索功能
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // 導航到通知頁面
    Navigator.pushNamed(context, '/notifications');
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除這條動態嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: AppSpacing.pagePadding,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: AppSpacing.pagePadding,
      ),
    );
  }
} 