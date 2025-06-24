import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'data/datasources/interests_data.dart';
import 'domain/entities/profile.dart';

class EnhancedInterestsWidget extends StatefulWidget {
  final List<String> interests;
  final bool isEditable;
  final String? mbtiType;
  final Function(List<String>) onInterestsChanged;

  const EnhancedInterestsWidget({
    super.key,
    required this.interests,
    required this.isEditable,
    this.mbtiType,
    required this.onInterestsChanged,
  });

  @override
  State<EnhancedInterestsWidget> createState() => _EnhancedInterestsWidgetState();
}

class _EnhancedInterestsWidgetState extends State<EnhancedInterestsWidget>
    with TickerProviderStateMixin {
  
  late List<String> _selectedInterests;
  String _selectedCategory = '全部';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _interestsAnimationController;
  late AnimationController _categoryAnimationController;
  
  late Animation<double> _interestsScaleAnimation;
  late Animation<Offset> _categorySlideAnimation;
  
  List<Interest> _allInterests = [];
  List<String> _categories = [];
  List<Interest> _recommendedInterests = [];
  
  @override
  void initState() {
    super.initState();
    _selectedInterests = List<String>.from(widget.interests);
    _loadInterestsData();
    _setupAnimations();
  }

  void _loadInterestsData() {
    _allInterests = InterestsData.getAllInterests();
    _categories = ['全部', ...InterestsData.getAllCategories()];
    if (widget.mbtiType != null) {
      _recommendedInterests = InterestsData.getRecommendedInterests(widget.mbtiType);
    }
  }

  void _setupAnimations() {
    _interestsAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _categoryAnimationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _interestsScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _interestsAnimationController, curve: Curves.elasticOut),
    );

    _categorySlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _categoryAnimationController, curve: Curves.easeOutCubic),
    );

    _interestsAnimationController.forward();
    _categoryAnimationController.forward();
  }

  @override
  void dispose() {
    _interestsAnimationController.dispose();
    _categoryAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: AppSpacing.lg),
          if (widget.isEditable) ...[
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildCategorySelector(),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildSelectedInterests(),
          const SizedBox(height: AppSpacing.lg),
          if (widget.isEditable) ...[
            _buildInterestsGrid(),
            const SizedBox(height: AppSpacing.lg),
            if (_recommendedInterests.isNotEmpty)
              _buildRecommendedSection(),
          ] else ...[
            _buildInterestsDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '興趣愛好',
                style: AppTextStyles.h4,
              ),
              Text(
                '${_selectedInterests.length} 個興趣',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.isEditable)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              '可編輯',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.medium,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: '搜索興趣...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: AppSpacing.cardPadding,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return AnimatedBuilder(
      animation: _categoryAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: _categorySlideAnimation,
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _categories.length - 1 ? AppSpacing.md : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = category);
                    },
                    child: AnimatedContainer(
                      duration: AppAnimations.fast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected 
                            ? LinearGradient(
                                colors: [AppColors.secondary, AppColors.primary],
                              )
                            : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        boxShadow: isSelected ? AppShadows.medium : null,
                      ),
                      child: Text(
                        category,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedInterests() {
    if (_selectedInterests.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.isEditable ? '選擇你的興趣' : '暫無興趣',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.isEditable) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '至少選擇3個興趣來找到更好的配對',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '已選興趣',
                style: AppTextStyles.h6,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _selectedInterests.length >= 3 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  '${_selectedInterests.length}/10',
                  style: AppTextStyles.overline.copyWith(
                    color: _selectedInterests.length >= 3 
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _selectedInterests.map((interest) {
              final interestData = _allInterests.firstWhere(
                (i) => i.name == interest,
                orElse: () => Interest(
                  id: interest,
                  name: interest,
                  category: '其他',
                  icon: '💫',
                ),
              );
              
              return _buildInterestChip(interestData, isSelected: true);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsGrid() {
    final filteredInterests = _getFilteredInterests();
    
    if (filteredInterests.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '沒有找到相關興趣',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '試試其他搜索關鍵詞或類別',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _interestsAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _interestsScaleAnimation.value,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '選擇興趣',
                  style: AppTextStyles.h6,
                ),
                const SizedBox(height: AppSpacing.md),
                
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: filteredInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest.name);
                    return _buildInterestChip(interest, isSelected: isSelected);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterestChip(Interest interest, {required bool isSelected}) {
    return GestureDetector(
      onTap: widget.isEditable ? () => _toggleInterest(interest.name) : null,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : AppColors.textTertiary.withOpacity(0.3),
          ),
          boxShadow: isSelected ? AppShadows.medium : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              interest.icon ?? '💫',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              interest.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (widget.isEditable && isSelected) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return AppCard(
      backgroundColor: AppColors.info.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'MBTI 推薦興趣',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '根據你的 ${widget.mbtiType} 性格類型推薦',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _recommendedInterests.take(6).map((interest) {
              final isSelected = _selectedInterests.contains(interest.name);
              return _buildInterestChip(interest, isSelected: isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsDisplay() {
    if (_selectedInterests.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 按類別分組顯示
        ..._getInterestsByCategory().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: entry.value.map((interest) {
                      return _buildInterestChip(interest, isSelected: true);
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<Interest> _getFilteredInterests() {
    List<Interest> interests = _allInterests;

    // 按類別篩選
    if (_selectedCategory != '全部') {
      interests = interests.where((i) => i.category == _selectedCategory).toList();
    }

    // 按搜索關鍵詞篩選
    if (_searchQuery.isNotEmpty) {
      interests = interests.where((i) {
        return i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               i.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 排除已選擇的興趣
    interests = interests.where((i) => !_selectedInterests.contains(i.name)).toList();

    return interests;
  }

  Map<String, List<Interest>> _getInterestsByCategory() {
    final Map<String, List<Interest>> categorizedInterests = {};
    
    for (final interestName in _selectedInterests) {
      final interest = _allInterests.firstWhere(
        (i) => i.name == interestName,
        orElse: () => Interest(
          id: interestName,
          name: interestName,
          category: '其他',
          icon: '💫',
        ),
      );
      
      if (!categorizedInterests.containsKey(interest.category)) {
        categorizedInterests[interest.category] = [];
      }
      categorizedInterests[interest.category]!.add(interest);
    }
    
    return categorizedInterests;
  }

  void _toggleInterest(String interestName) {
    HapticFeedback.lightImpact();
    
    setState(() {
      if (_selectedInterests.contains(interestName)) {
        _selectedInterests.remove(interestName);
      } else {
        if (_selectedInterests.length < 10) {
          _selectedInterests.add(interestName);
        } else {
          _showMaxSelectionsDialog();
          return;
        }
      }
    });
    
    widget.onInterestsChanged(_selectedInterests);
  }

  void _showMaxSelectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇上限'),
        content: const Text('最多只能選擇10個興趣。請先取消一些現有興趣再添加新的。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
} 