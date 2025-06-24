import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FAQ 項目模型
class FAQItem {
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.tags,
  });
}

// 幫助類別
enum HelpCategory {
  account,
  matching,
  messaging,
  safety,
  premium,
  technical,
}

// 幫助中心狀態管理
final helpCenterProvider = StateNotifierProvider<HelpCenterNotifier, HelpCenterState>((ref) {
  return HelpCenterNotifier();
});

class HelpCenterState {
  final List<FAQItem> faqItems;
  final String searchQuery;
  final HelpCategory? selectedCategory;
  final bool isLoading;

  HelpCenterState({
    required this.faqItems,
    this.searchQuery = '',
    this.selectedCategory,
    this.isLoading = false,
  });

  HelpCenterState copyWith({
    List<FAQItem>? faqItems,
    String? searchQuery,
    HelpCategory? selectedCategory,
    bool? isLoading,
  }) {
    return HelpCenterState(
      faqItems: faqItems ?? this.faqItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<FAQItem> get filteredFAQs {
    var filtered = faqItems;

    // 按類別篩選
    if (selectedCategory != null) {
      final categoryName = _getCategoryName(selectedCategory!);
      filtered = filtered.where((faq) => faq.category == categoryName).toList();
    }

    // 按搜索查詢篩選
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((faq) =>
          faq.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(searchQuery.toLowerCase()) ||
          faq.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }

    return filtered;
  }

  String _getCategoryName(HelpCategory category) {
    switch (category) {
      case HelpCategory.account:
        return '帳戶管理';
      case HelpCategory.matching:
        return '配對功能';
      case HelpCategory.messaging:
        return '聊天消息';
      case HelpCategory.safety:
        return '安全隱私';
      case HelpCategory.premium:
        return 'Premium';
      case HelpCategory.technical:
        return '技術問題';
    }
  }
}

class HelpCenterNotifier extends StateNotifier<HelpCenterState> {
  HelpCenterNotifier() : super(HelpCenterState(faqItems: [])) {
    _loadFAQs();
  }

  void _loadFAQs() {
    final faqs = [
      // 帳戶管理
      FAQItem(
        question: '如何刪除我的帳戶？',
        answer: '你可以在設置 > 帳戶設置 > 刪除帳戶中永久刪除你的帳戶。請注意，此操作無法撤銷，所有數據將被永久刪除。',
        category: '帳戶管理',
        tags: ['刪除', '帳戶', '設置'],
      ),
      FAQItem(
        question: '如何更改我的電子郵件地址？',
        answer: '前往設置 > 帳戶設置 > 電子郵件，輸入新的電子郵件地址並驗證。我們會發送驗證郵件到新地址。',
        category: '帳戶管理',
        tags: ['電子郵件', '更改', '驗證'],
      ),
      FAQItem(
        question: '忘記密碼怎麼辦？',
        answer: '在登入頁面點擊「忘記密碼」，輸入你的電子郵件地址，我們會發送重設密碼的連結給你。',
        category: '帳戶管理',
        tags: ['密碼', '重設', '忘記'],
      ),

      // 配對功能
      FAQItem(
        question: '為什麼我沒有收到配對？',
        answer: '配對需要雙方互相喜歡。確保你的檔案完整且有吸引力的照片。你也可以嘗試調整搜索範圍或年齡偏好。',
        category: '配對功能',
        tags: ['配對', '喜歡', '檔案'],
      ),
      FAQItem(
        question: 'MBTI 配對是如何運作的？',
        answer: '我們的 AI 算法會分析你的 MBTI 性格類型，並找到與你最兼容的性格類型。兼容性分數基於心理學研究。',
        category: '配對功能',
        tags: ['MBTI', '兼容性', 'AI'],
      ),
      FAQItem(
        question: '如何提高配對成功率？',
        answer: '完善你的檔案，添加多張高質量照片，填寫詳細的自我介紹，完成 MBTI 測試，並保持活躍。',
        category: '配對功能',
        tags: ['成功率', '檔案', '照片'],
      ),

      // 聊天消息
      FAQItem(
        question: '為什麼我無法發送消息？',
        answer: '只有在雙方配對成功後才能發送消息。確保你們已經互相喜歡，或者檢查對方是否已經取消配對。',
        category: '聊天消息',
        tags: ['消息', '配對', '發送'],
      ),
      FAQItem(
        question: '如何知道對方是否已讀我的消息？',
        answer: '已讀的消息會顯示藍色的勾號。如果只顯示灰色勾號，表示消息已送達但未讀。',
        category: '聊天消息',
        tags: ['已讀', '消息狀態', '勾號'],
      ),

      // 安全隱私
      FAQItem(
        question: '如何舉報不當行為？',
        answer: '在用戶檔案或聊天界面點擊舉報按鈕，選擇舉報原因並提供詳細描述。我們會在24小時內處理。',
        category: '安全隱私',
        tags: ['舉報', '不當行為', '安全'],
      ),
      FAQItem(
        question: '我的個人信息安全嗎？',
        answer: '我們使用端到端加密保護你的數據，並嚴格遵守隱私政策。你的個人信息不會被分享給第三方。',
        category: '安全隱私',
        tags: ['隱私', '安全', '加密'],
      ),

      // Premium
      FAQItem(
        question: 'Premium 會員有什麼特權？',
        answer: 'Premium 會員可以看到誰喜歡了你、無限次喜歡、超級喜歡、回溯功能、AI 愛情顧問等特殊功能。',
        category: 'Premium',
        tags: ['Premium', '特權', '功能'],
      ),
      FAQItem(
        question: '如何取消 Premium 訂閱？',
        answer: '前往設置 > Premium 管理 > 取消訂閱。你可以繼續使用 Premium 功能直到當前計費週期結束。',
        category: 'Premium',
        tags: ['取消', '訂閱', 'Premium'],
      ),

      // 技術問題
      FAQItem(
        question: '應用程式經常崩潰怎麼辦？',
        answer: '請嘗試重新啟動應用程式，確保你使用的是最新版本。如果問題持續，請聯繫客服並提供設備信息。',
        category: '技術問題',
        tags: ['崩潰', '技術', '更新'],
      ),
      FAQItem(
        question: '照片上傳失敗怎麼辦？',
        answer: '檢查網路連接，確保照片大小不超過10MB，格式為JPG或PNG。如果問題持續，請嘗試重新啟動應用程式。',
        category: '技術問題',
        tags: ['照片', '上傳', '失敗'],
      ),
    ];

    state = state.copyWith(faqItems: faqs);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(HelpCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
    );
  }
}

class HelpCenterPage extends ConsumerStatefulWidget {
  const HelpCenterPage({super.key});

  @override
  ConsumerState<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends ConsumerState<HelpCenterPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helpState = ref.watch(helpCenterProvider);
    final notifier = ref.read(helpCenterProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('幫助中心'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showContactSupport(),
            icon: const Icon(Icons.support_agent),
            tooltip: '聯繫客服',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索欄
          _buildSearchBar(notifier),
          
          // 快速操作
          _buildQuickActions(),
          
          // 類別篩選
          _buildCategoryFilter(helpState, notifier),
          
          // FAQ 列表
          Expanded(
            child: _buildFAQList(helpState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(HelpCenterNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索常見問題...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    notifier.updateSearchQuery('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE91E63)),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: notifier.updateSearchQuery,
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': '聯繫客服',
        'subtitle': '即時聊天支援',
        'icon': Icons.chat_bubble_outline,
        'color': Colors.blue,
        'onTap': () => _showContactSupport(),
      },
      {
        'title': '使用教程',
        'subtitle': '學習如何使用',
        'icon': Icons.play_circle_outline,
        'color': Colors.green,
        'onTap': () => _showTutorials(),
      },
      {
        'title': '意見反饋',
        'subtitle': '幫助我們改進',
        'icon': Icons.feedback_outlined,
        'color': Colors.orange,
        'onTap': () => _showFeedback(),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速幫助',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.map((action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildQuickActionCard(action),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return InkWell(
      onTap: action['onTap'],
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (action['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (action['color'] as Color).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              action['icon'],
              color: action['color'],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              action['title'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: action['color'],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              action['subtitle'],
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(HelpCenterState state, HelpCenterNotifier notifier) {
    final categories = [
      {'category': null, 'name': '全部', 'icon': Icons.all_inclusive},
      {'category': HelpCategory.account, 'name': '帳戶', 'icon': Icons.person},
      {'category': HelpCategory.matching, 'name': '配對', 'icon': Icons.favorite},
      {'category': HelpCategory.messaging, 'name': '聊天', 'icon': Icons.chat},
      {'category': HelpCategory.safety, 'name': '安全', 'icon': Icons.security},
      {'category': HelpCategory.premium, 'name': 'Premium', 'icon': Icons.star},
      {'category': HelpCategory.technical, 'name': '技術', 'icon': Icons.build},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = state.selectedCategory == category['category'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFFE91E63),
                  ),
                  const SizedBox(width: 6),
                  Text(category['name'] as String),
                ],
              ),
              onSelected: (selected) {
                notifier.selectCategory(
                  selected ? category['category'] as HelpCategory? : null
                );
              },
              selectedColor: const Color(0xFFE91E63),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQList(HelpCenterState state) {
    final filteredFAQs = state.filteredFAQs;

    if (filteredFAQs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFAQs.length,
      itemBuilder: (context, index) {
        final faq = filteredFAQs[index];
        return _buildFAQCard(faq);
      },
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            faq.category,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: faq.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _markHelpful(faq),
                      icon: const Icon(Icons.thumb_up_outlined, size: 16),
                      label: const Text('有幫助'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _markNotHelpful(faq),
                      icon: const Icon(Icons.thumb_down_outlined, size: 16),
                      label: const Text('沒幫助'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '找不到相關問題',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '嘗試使用不同的關鍵字搜索\n或聯繫客服獲得幫助',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showContactSupport(),
            icon: const Icon(Icons.support_agent),
            label: const Text('聯繫客服'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '聯繫客服',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildContactOption(
                      title: '即時聊天',
                      subtitle: '平均回覆時間：2分鐘',
                      icon: Icons.chat_bubble,
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, '/customer_chat'),
                    ),
                    const SizedBox(height: 12),
                    _buildContactOption(
                      title: '電子郵件',
                      subtitle: 'support@amore.app',
                      icon: Icons.email,
                      color: Colors.green,
                      onTap: () => _sendEmail(),
                    ),
                    const SizedBox(height: 12),
                    _buildContactOption(
                      title: '電話支援',
                      subtitle: '+852 1234 5678',
                      icon: Icons.phone,
                      color: Colors.orange,
                      onTap: () => _makePhoneCall(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '客服時間',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '週一至週五：09:00 - 18:00\n週六至週日：10:00 - 16:00',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorials() {
    Navigator.pushNamed(context, '/tutorials');
  }

  void _showFeedback() {
    Navigator.pushNamed(context, '/feedback');
  }

  void _markHelpful(FAQItem faq) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('感謝你的反饋！'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markNotHelpful(FAQItem faq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要更多幫助？'),
        content: const Text('這個答案沒有幫助到你嗎？我們可以為你聯繫客服獲得更詳細的協助。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactSupport();
            },
            child: const Text('聯繫客服'),
          ),
        ],
      ),
    );
  }

  void _sendEmail() {
    // 實際應用中會打開郵件應用
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在打開郵件應用...')),
    );
  }

  void _makePhoneCall() {
    // 實際應用中會撥打電話
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在撥打電話...')),
    );
  }
} 