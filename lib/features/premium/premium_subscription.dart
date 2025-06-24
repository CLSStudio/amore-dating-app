import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// 訂閱計劃類型
enum SubscriptionPlan {
  free,
  basic,
  premium,
  platinum,
}

// 訂閱狀態
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
  trial,
}

// 訂閱模型
class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final bool isAutoRenew;
  final Map<String, bool> features;
  final int remainingDays;

  Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.price,
    this.currency = 'HKD',
    this.isAutoRenew = true,
    this.features = const {},
    required this.remainingDays,
  });

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    String? currency,
    bool? isAutoRenew,
    Map<String, bool>? features,
    int? remainingDays,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isAutoRenew: isAutoRenew ?? this.isAutoRenew,
      features: features ?? this.features,
      remainingDays: remainingDays ?? this.remainingDays,
    );
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPremium => plan != SubscriptionPlan.free;
  bool get isExpiringSoon => remainingDays <= 7;
}

// 訂閱計劃詳情
class SubscriptionPlanDetails {
  final SubscriptionPlan plan;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final List<String> premiumFeatures;
  final Color color;
  final String badge;
  final bool isPopular;

  SubscriptionPlanDetails({
    required this.plan,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.premiumFeatures,
    required this.color,
    this.badge = '',
    this.isPopular = false,
  });

  double get yearlyDiscount => (monthlyPrice * 12 - yearlyPrice) / (monthlyPrice * 12);
}

// 訂閱狀態管理
final currentSubscriptionProvider = StateProvider<Subscription?>((ref) {
  // 模擬當前用戶的免費訂閱
  return Subscription(
    id: 'free_sub',
    userId: 'current_user',
    plan: SubscriptionPlan.free,
    status: SubscriptionStatus.active,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 365)),
    price: 0.0,
    remainingDays: 365,
    features: {
      'basic_matching': true,
      'unlimited_likes': false,
      'super_likes': false,
      'boost': false,
      'read_receipts': false,
      'advanced_filters': false,
      'ai_insights': false,
      'priority_support': false,
    },
  );
});

final subscriptionPlansProvider = Provider<List<SubscriptionPlanDetails>>((ref) {
  return [
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.free,
      name: '免費版',
      description: '基本功能，開始你的約會之旅',
      monthlyPrice: 0.0,
      yearlyPrice: 0.0,
      color: Colors.grey,
      features: [
        '基本配對功能',
        '每日 10 個喜歡',
        '基本聊天功能',
        '查看配對資料',
      ],
      premiumFeatures: [],
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.basic,
      name: 'Basic',
      description: '解鎖更多配對機會',
      monthlyPrice: 88.0,
      yearlyPrice: 888.0,
      color: Colors.blue,
      features: [
        '無限喜歡',
        '每日 5 個超級喜歡',
        '查看誰喜歡你',
        '撤銷滑動',
        '無廣告體驗',
      ],
      premiumFeatures: [
        'unlimited_likes',
        'super_likes',
        'see_who_likes',
        'rewind',
        'ad_free',
      ],
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.premium,
      name: 'Premium',
      description: '智能配對，提升成功率',
      monthlyPrice: 168.0,
      yearlyPrice: 1688.0,
      color: Colors.pink,
      badge: '最受歡迎',
      isPopular: true,
      features: [
        '包含 Basic 所有功能',
        '每月 1 次 Boost',
        '已讀回執',
        '高級篩選器',
        'AI 配對洞察',
        '優先客服支援',
      ],
      premiumFeatures: [
        'unlimited_likes',
        'super_likes',
        'see_who_likes',
        'rewind',
        'ad_free',
        'boost',
        'read_receipts',
        'advanced_filters',
        'ai_insights',
        'priority_support',
      ],
    ),
    SubscriptionPlanDetails(
      plan: SubscriptionPlan.platinum,
      name: 'Platinum',
      description: '頂級體驗，專屬服務',
      monthlyPrice: 288.0,
      yearlyPrice: 2888.0,
      color: Colors.amber,
      badge: 'VIP',
      features: [
        '包含 Premium 所有功能',
        '每週 2 次 Boost',
        '無限超級喜歡',
        '專屬 AI 愛情顧問',
        '優先配對',
        '專屬客服經理',
        '線下活動邀請',
      ],
      premiumFeatures: [
        'unlimited_likes',
        'unlimited_super_likes',
        'see_who_likes',
        'rewind',
        'ad_free',
        'unlimited_boost',
        'read_receipts',
        'advanced_filters',
        'ai_insights',
        'priority_support',
        'ai_consultant',
        'priority_matching',
        'vip_support',
        'exclusive_events',
      ],
    ),
  ];
});

// Premium 功能檢查服務
class PremiumFeatureService {
  static bool hasFeature(Subscription? subscription, String feature) {
    if (subscription == null) return false;
    return subscription.features[feature] ?? false;
  }

  static bool canUseSuperLike(Subscription? subscription) {
    return hasFeature(subscription, 'super_likes') || 
           hasFeature(subscription, 'unlimited_super_likes');
  }

  static bool canUseBoost(Subscription? subscription) {
    return hasFeature(subscription, 'boost') || 
           hasFeature(subscription, 'unlimited_boost');
  }

  static bool canSeeWhoLikes(Subscription? subscription) {
    return hasFeature(subscription, 'see_who_likes');
  }

  static bool canUseAdvancedFilters(Subscription? subscription) {
    return hasFeature(subscription, 'advanced_filters');
  }

  static bool hasAIInsights(Subscription? subscription) {
    return hasFeature(subscription, 'ai_insights');
  }

  static bool hasPrioritySupport(Subscription? subscription) {
    return hasFeature(subscription, 'priority_support');
  }
}

// Premium 訂閱頁面
class PremiumSubscriptionPage extends ConsumerStatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  ConsumerState<PremiumSubscriptionPage> createState() => _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState extends ConsumerState<PremiumSubscriptionPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isYearly = true;
  int _selectedPlanIndex = 1; // 默認選擇 Premium

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(subscriptionPlansProvider);
    final currentSubscription = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCurrentSubscriptionCard(currentSubscription),
                _buildBillingToggle(),
                _buildPlanCards(plans),
                _buildFeatureComparison(plans),
                _buildTestimonials(),
                _buildFAQ(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSubscribeButton(plans),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Amore Premium',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
                Color(0xFFFF6B6B),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  '💎',
                  style: TextStyle(fontSize: 60),
                ),
                SizedBox(height: 16),
                Text(
                  '解鎖完美配對',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '讓 AI 幫你找到真愛',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(Subscription? subscription) {
    if (subscription == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: subscription.isPremium ? Colors.pink : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPlanName(subscription.plan),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (subscription.isExpiringSoon)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '即將到期',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subscription.isPremium ? '感謝您的支持！' : '升級到 Premium',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subscription.isPremium 
                ? '您正在享受 Premium 功能，還有 ${subscription.remainingDays} 天到期'
                : '升級到 Premium 解鎖更多功能，提升配對成功率',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (subscription.isPremium) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: subscription.remainingDays / 365,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                subscription.isExpiringSoon ? Colors.orange : Colors.pink,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: !_isYearly ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  '月付',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !_isYearly ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: _isYearly ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '年付',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isYearly ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (_isYearly)
                      Positioned(
                        top: -4,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '省 15%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards(List<SubscriptionPlanDetails> plans) {
    final paidPlans = plans.where((p) => p.plan != SubscriptionPlan.free).toList();
    
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        onPageChanged: (index) => setState(() => _selectedPlanIndex = index),
        itemCount: paidPlans.length,
        itemBuilder: (context, index) {
          final plan = paidPlans[index];
          final isSelected = index == _selectedPlanIndex;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: isSelected ? 0 : 20,
            ),
            child: _buildPlanCard(plan, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanDetails plan, bool isSelected) {
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final monthlyPrice = _isYearly ? plan.yearlyPrice / 12 : plan.monthlyPrice;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            plan.color.withOpacity(0.8),
            plan.color,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: plan.color.withOpacity(0.3),
            blurRadius: isSelected ? 20 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.badge.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      plan.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'HK\$${monthlyPrice.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '/月',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (_isYearly && plan.yearlyDiscount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '年付省 ${(plan.yearlyDiscount * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: plan.features.take(4).map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (plan.isPopular)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  '最受歡迎',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison(List<SubscriptionPlanDetails> plans) {
    final features = [
      '基本配對功能',
      '無限喜歡',
      '超級喜歡',
      '查看誰喜歡你',
      '撤銷滑動',
      'Boost 功能',
      '已讀回執',
      '高級篩選器',
      'AI 配對洞察',
      '優先客服支援',
      'AI 愛情顧問',
      '專屬客服經理',
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '功能比較',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          // 表頭
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    '功能',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                ...plans.map((plan) => Expanded(
                  child: Text(
                    plan.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: plan.color,
                      fontSize: 12,
                    ),
                  ),
                )),
              ],
            ),
          ),
          // 功能列表
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.grey[25] : Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[100]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  ...plans.map((plan) => Expanded(
                    child: Center(
                      child: _getFeatureIcon(plan, feature),
                    ),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _getFeatureIcon(SubscriptionPlanDetails plan, String feature) {
    bool hasFeature = false;
    
    switch (feature) {
      case '基本配對功能':
        hasFeature = true;
        break;
      case '無限喜歡':
        hasFeature = plan.plan != SubscriptionPlan.free;
        break;
      case '超級喜歡':
        hasFeature = plan.plan != SubscriptionPlan.free;
        break;
      case '查看誰喜歡你':
        hasFeature = plan.plan != SubscriptionPlan.free;
        break;
      case '撤銷滑動':
        hasFeature = plan.plan != SubscriptionPlan.free;
        break;
      case 'Boost 功能':
        hasFeature = plan.plan == SubscriptionPlan.premium || plan.plan == SubscriptionPlan.platinum;
        break;
      case '已讀回執':
        hasFeature = plan.plan == SubscriptionPlan.premium || plan.plan == SubscriptionPlan.platinum;
        break;
      case '高級篩選器':
        hasFeature = plan.plan == SubscriptionPlan.premium || plan.plan == SubscriptionPlan.platinum;
        break;
      case 'AI 配對洞察':
        hasFeature = plan.plan == SubscriptionPlan.premium || plan.plan == SubscriptionPlan.platinum;
        break;
      case '優先客服支援':
        hasFeature = plan.plan == SubscriptionPlan.premium || plan.plan == SubscriptionPlan.platinum;
        break;
      case 'AI 愛情顧問':
        hasFeature = plan.plan == SubscriptionPlan.platinum;
        break;
      case '專屬客服經理':
        hasFeature = plan.plan == SubscriptionPlan.platinum;
        break;
    }

    return Icon(
      hasFeature ? Icons.check_circle : Icons.cancel,
      color: hasFeature ? Colors.green : Colors.grey[300],
      size: 20,
    );
  }

  Widget _buildTestimonials() {
    final testimonials = [
      {
        'name': '小美',
        'age': 28,
        'text': '升級 Premium 後，配對質量明顯提升！AI 洞察真的很準確。',
        'avatar': '👩‍💼',
        'rating': 5,
      },
      {
        'name': '阿明',
        'age': 32,
        'text': 'Boost 功能讓我的資料被更多人看到，一週內就找到了理想對象！',
        'avatar': '👨‍💻',
        'rating': 5,
      },
      {
        'name': '小雅',
        'age': 26,
        'text': '超級喜歡功能很實用，讓我能向心儀的人表達更強烈的興趣。',
        'avatar': '👩‍🎨',
        'rating': 4,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            child: Text(
              '用戶評價',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final testimonial = testimonials[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            testimonial['avatar'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testimonial['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${testimonial['age']} 歲',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star,
                              size: 16,
                              color: i < (testimonial['rating'] as int) 
                                  ? Colors.amber 
                                  : Colors.grey[300],
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Text(
                          testimonial['text'] as String,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    final faqs = [
      {
        'question': '如何取消訂閱？',
        'answer': '您可以隨時在設置中取消訂閱，取消後仍可使用到期末。',
      },
      {
        'question': '升級後立即生效嗎？',
        'answer': '是的，升級後所有 Premium 功能立即解鎖。',
      },
      {
        'question': '可以退款嗎？',
        'answer': '根據 App Store 政策，訂閱後 24 小時內可申請退款。',
      },
      {
        'question': 'Premium 功能包括什麼？',
        'answer': '包括無限喜歡、超級喜歡、Boost、AI 洞察等多項功能。',
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '常見問題',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ...faqs.map((faq) => ExpansionTile(
            title: Text(
              faq['question']!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq['answer']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildBottomSubscribeButton(List<SubscriptionPlanDetails> plans) {
    final paidPlans = plans.where((p) => p.plan != SubscriptionPlan.free).toList();
    final selectedPlan = paidPlans[_selectedPlanIndex];
    final price = _isYearly ? selectedPlan.yearlyPrice : selectedPlan.monthlyPrice;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [selectedPlan.color, selectedPlan.color.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: selectedPlan.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _subscribeToPlan(selectedPlan),
                  child: Center(
                    child: Text(
                      '開始 ${selectedPlan.name} - HK\$${price.toInt()}${_isYearly ? '/年' : '/月'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '7 天免費試用 • 隨時取消',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return '免費版';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.platinum:
        return 'Platinum';
    }
  }

  void _subscribeToPlan(SubscriptionPlanDetails plan) {
    showDialog(
      context: context,
      builder: (context) => SubscriptionConfirmDialog(
        plan: plan,
        isYearly: _isYearly,
      ),
    );
  }
}

// 訂閱確認對話框
class SubscriptionConfirmDialog extends ConsumerWidget {
  final SubscriptionPlanDetails plan;
  final bool isYearly;

  const SubscriptionConfirmDialog({
    super.key,
    required this.plan,
    required this.isYearly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [plan.color, plan.color.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '確認訂閱',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${plan.name} ${isYearly ? '年度' : '月度'}訂閱',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'HK\$${price.toInt()}${isYearly ? '/年' : '/月'}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: plan.color,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '7 天免費試用',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '試用期結束後將自動續費，您可以隨時取消',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmSubscription(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '確認',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSubscription(BuildContext context, WidgetRef ref) {
    // 模擬訂閱流程
    final newSubscription = Subscription(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      plan: plan.plan,
      status: SubscriptionStatus.trial,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: isYearly ? 365 : 30)),
      price: isYearly ? plan.yearlyPrice : plan.monthlyPrice,
      remainingDays: isYearly ? 365 : 30,
      features: Map.fromEntries(
        plan.premiumFeatures.map((f) => MapEntry(f, true)),
      ),
    );

    ref.read(currentSubscriptionProvider.notifier).state = newSubscription;

    Navigator.pop(context);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('恭喜！您已成功訂閱 ${plan.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 