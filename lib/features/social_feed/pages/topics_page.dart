import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feed_models.dart';
import '../services/topic_service.dart';
import '../widgets/topic_card_widget.dart';
import '../widgets/create_topic_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_border_radius.dart';

// ================== 話題討論主頁面 ==================

class TopicsPage extends ConsumerStatefulWidget {
  const TopicsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends ConsumerState<TopicsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String? _currentUserId;
  TopicCategory _selectedCategory = TopicCategory.general;
  List<Topic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (!_isSearching) _buildTabBar(),
          Expanded(
            child: _isSearching 
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrendingTopics(),
                      _buildLatestTopics(),
                      _buildCategoryTopics(),
                      _buildMyTopics(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildCreateTopicFAB(),
    );
  }

  // ================== UI 組件 ==================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '話題討論',
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
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showCategoryFilter,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: AppSpacing.pagePadding,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索話題...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: _performSearch,
      ),
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
            icon: Icon(Icons.trending_up),
            text: '熱門',
          ),
          Tab(
            icon: Icon(Icons.new_releases),
            text: '最新',
          ),
          Tab(
            icon: Icon(Icons.category),
            text: '分類',
          ),
          Tab(
            icon: Icon(Icons.person),
            text: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopics() {
    return StreamBuilder<List<Topic>>(
      stream: ref.read(topicServiceProvider).getTrendingTopics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('載入失敗: ${snapshot.error}');
        }

        final topics = snapshot.data ?? [];
        
        if (topics.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.trending_up,
            title: '暫無熱門話題',
            subtitle: '成為第一個創建話題的人！',
          );
        }

        return _buildTopicsList(topics);
      },
    );
  }

  Widget _buildLatestTopics() {
    return StreamBuilder<List<Topic>>(
      stream: ref.read(topicServiceProvider).getLatestTopics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('載入失敗: ${snapshot.error}');
        }

        final topics = snapshot.data ?? [];
        
        if (topics.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.new_releases,
            title: '暫無最新話題',
            subtitle: '創建一個新話題開始討論吧！',
          );
        }

        return _buildTopicsList(topics);
      },
    );
  }

  Widget _buildCategoryTopics() {
    return Column(
      children: [
        _buildCategorySelector(),
        Expanded(
          child: StreamBuilder<List<Topic>>(
            stream: ref.read(topicServiceProvider).getTopicsByCategory(_selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorWidget('載入失敗: ${snapshot.error}');
              }

              final topics = snapshot.data ?? [];
              
              if (topics.isEmpty) {
                return _buildEmptyWidget(
                  icon: Icons.category,
                  title: '該分類暫無話題',
                  subtitle: '在這個分類中創建第一個話題！',
                );
              }

              return _buildTopicsList(topics);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyTopics() {
    if (_currentUserId == null) {
      return const Center(child: Text('請先登入'));
    }

    return StreamBuilder<List<Topic>>(
      stream: ref.read(topicServiceProvider).getUserCreatedTopics(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('載入失敗: ${snapshot.error}');
        }

        final topics = snapshot.data ?? [];
        
        if (topics.isEmpty) {
          return _buildEmptyWidget(
            icon: Icons.person,
            title: '你還沒有創建任何話題',
            subtitle: '創建你的第一個話題吧！',
            showCreateButton: true,
          );
        }

        return _buildTopicsList(topics);
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptyWidget(
        icon: Icons.search_off,
        title: '沒有找到相關話題',
        subtitle: '嘗試使用其他關鍵字搜索',
      );
    }

    return _buildTopicsList(_searchResults);
  }

  Widget _buildCategorySelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TopicCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopicsList(List<Topic> topics) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.pagePadding,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TopicCardWidget(
              topic: topics[index],
              onTap: _navigateToTopicDetail,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWidget({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showCreateButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (showCreateButton) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showCreateTopicDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
              ),
              child: const Text('創建話題'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
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

  Widget _buildCreateTopicFAB() {
    return FloatingActionButton(
      onPressed: _showCreateTopicDialog,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // ================== 事件處理 ==================

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
    } else {
      setState(() {
        _isSearching = true;
      });
    }
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final results = await ref.read(topicServiceProvider).searchTopics(query.trim());
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      _showErrorSnackBar('搜索失敗: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults.clear();
    });
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '選擇分類',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TopicCategory.values.map((category) {
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 4),
                      Text(category.displayName),
                    ],
                  ),
                  selected: category == _selectedCategory,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTopicDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTopicWidget(
        onTopicCreated: _handleTopicCreated,
      ),
    );
  }

  void _handleTopicCreated() {
    setState(() {}); // 刷新話題列表
    _showSuccessSnackBar('話題創建成功！');
  }

  void _navigateToTopicDetail(Topic topic) {
    Navigator.pushNamed(
      context,
      '/topic_detail',
      arguments: topic.id,
    );
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