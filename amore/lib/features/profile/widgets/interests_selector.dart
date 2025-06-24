import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class InterestsSelector extends StatefulWidget {
  final List<String> selectedInterests;
  final Function(List<String>) onInterestsChanged;
  final int maxSelections;
  final int minSelections;

  const InterestsSelector({
    super.key,
    required this.selectedInterests,
    required this.onInterestsChanged,
    this.maxSelections = 10,
    this.minSelections = 3,
  });

  @override
  State<InterestsSelector> createState() => _InterestsSelectorState();
}

class _InterestsSelectorState extends State<InterestsSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  String _selectedCategory = '全部';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, List<String>> _interestCategories = {
    '全部': [],
    '運動健身': [
      '健身', '跑步', '瑜伽', '游泳', '籃球', '足球', '網球', '羽毛球',
      '乒乓球', '攀岩', '滑雪', '衝浪', '騎行', '徒步', '舞蹈', '武術'
    ],
    '藝術文化': [
      '繪畫', '攝影', '音樂', '唱歌', '樂器', '書法', '雕塑', '陶藝',
      '設計', '寫作', '詩歌', '戲劇', '電影', '動漫', '收藏', '手工藝'
    ],
    '美食料理': [
      '烹飪', '烘焙', '品酒', '咖啡', '茶藝', '甜點', '素食', '日料',
      '韓料', '西餐', '中餐', '泰料', '意料', '法料', '美食探店', '調酒'
    ],
    '旅行探索': [
      '旅行', '背包客', '自駕遊', '露營', '登山', '探險', '文化體驗',
      '美食之旅', '攝影旅行', '歷史古蹟', '自然風光', '城市探索',
      '海島度假', '溫泉', '民宿', '郵輪'
    ],
    '科技數碼': [
      '程式設計', '人工智能', '區塊鏈', '遊戲開發', '網頁設計',
      '數據分析', '機器人', '無人機', '3D列印', 'VR/AR', '科技新聞',
      '數碼產品', '智能家居', '網絡安全', '雲計算', '開源項目'
    ],
    '學習成長': [
      '閱讀', '語言學習', '在線課程', '技能培訓', '投資理財',
      '心理學', '哲學', '歷史', '科學', '數學', '演講', '辯論',
      '冥想', '正念', '個人發展', '職業規劃'
    ],
    '娛樂休閒': [
      '電影', '電視劇', '綜藝', '音樂會', '演唱會', '話劇', '相聲',
      '桌遊', '電子遊戲', '手機遊戲', 'KTV', '酒吧', '夜市',
      '購物', '美容', '時尚'
    ],
    '社交公益': [
      '志願服務', '慈善', '環保', '動物保護', '社區活動', '讀書會',
      '興趣小組', '聚會', '派對', '交友', '網絡社交', '公益活動',
      '義工', '捐血', '關愛長者', '兒童教育'
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 初始化全部興趣列表
    _interestCategories['全部'] = _interestCategories.values
        .expand((interests) => interests)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredInterests {
    final categoryInterests = _interestCategories[_selectedCategory] ?? [];
    
    if (_searchQuery.isEmpty) {
      return categoryInterests;
    }
    
    return categoryInterests
        .where((interest) => 
            interest.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleInterest(String interest) {
    final newInterests = List<String>.from(widget.selectedInterests);
    
    if (newInterests.contains(interest)) {
      newInterests.remove(interest);
    } else {
      if (newInterests.length < widget.maxSelections) {
        newInterests.add(interest);
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      } else {
        _showMaxSelectionsDialog();
        return;
      }
    }
    
    widget.onInterestsChanged(newInterests);
  }

  void _showMaxSelectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '選擇數量限制',
          style: AppTextStyles.heading4,
        ),
        content: Text(
          '最多只能選擇 ${widget.maxSelections} 個興趣',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '確定',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            style: AppTextStyles.input,
            decoration: InputDecoration(
              hintText: '搜索興趣...',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 類別選擇器
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _interestCategories.keys.length,
            itemBuilder: (context, index) {
              final category = _interestCategories.keys.elementAt(index);
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: EdgeInsets.only(right: index < _interestCategories.keys.length - 1 ? 12 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.button.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 選擇計數器
        Row(
          children: [
            Text(
              '已選擇: ${widget.selectedInterests.length}/${widget.maxSelections}',
              style: AppTextStyles.body2.copyWith(
                color: widget.selectedInterests.length >= widget.minSelections
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (widget.selectedInterests.length < widget.minSelections)
              Text(
                '至少選擇 ${widget.minSelections} 個',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 興趣標籤網格
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildInterestsGrid(),
            );
          },
        ),
        
        // 已選興趣預覽
        if (widget.selectedInterests.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            '已選興趣',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedInterests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      interest,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _toggleInterest(interest),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInterestsGrid() {
    final interests = _filteredInterests;
    
    if (interests.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isNotEmpty ? '沒有找到相關興趣' : '此類別暫無興趣選項',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: interests.map((interest) {
        final isSelected = widget.selectedInterests.contains(interest);
        
        return GestureDetector(
          onTap: () => _toggleInterest(interest),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.border,
                width: 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  interest,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
} 