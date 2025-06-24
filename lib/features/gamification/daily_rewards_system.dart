import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardsSystem extends StatefulWidget {
  const DailyRewardsSystem({super.key});

  @override
  State<DailyRewardsSystem> createState() => _DailyRewardsSystemState();
}

class _DailyRewardsSystemState extends State<DailyRewardsSystem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _currentStreak = 0;
  bool _canClaimToday = false;
  List<DailyReward> _rewards = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _initializeRewards();
    _checkDailyStatus();
  }

  void _initializeRewards() {
    _rewards = [
      DailyReward(
        day: 1,
        title: '新手禮包',
        description: '3 個超級喜歡',
        icon: Icons.star,
        color: Colors.blue,
        value: 3,
      ),
      DailyReward(
        day: 2,
        title: '人氣提升',
        description: '檔案曝光率 +50%',
        icon: Icons.trending_up,
        color: Colors.green,
        value: 50,
      ),
      DailyReward(
        day: 3,
        title: '配對加速',
        description: '5 個免費 Boost',
        icon: Icons.rocket_launch,
        color: Colors.orange,
        value: 5,
      ),
      DailyReward(
        day: 4,
        title: '聊天特權',
        description: '無限制訊息',
        icon: Icons.chat_bubble,
        color: Colors.purple,
        value: 1,
      ),
      DailyReward(
        day: 5,
        title: '約會基金',
        description: 'HK\$50 約會優惠券',
        icon: Icons.local_dining,
        color: Colors.red,
        value: 50,
      ),
      DailyReward(
        day: 6,
        title: 'VIP 體驗',
        description: '3 天 Premium 試用',
        icon: Icons.diamond,
        color: Colors.amber,
        value: 3,
      ),
      DailyReward(
        day: 7,
        title: '終極獎勵',
        description: '1 個月 Premium',
        icon: Icons.workspace_premium,
        color: Colors.deepPurple,
        value: 30,
      ),
    ];
  }

  Future<void> _checkDailyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimDate = prefs.getString('last_claim_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    setState(() {
      _currentStreak = prefs.getInt('daily_streak') ?? 0;
      _canClaimToday = lastClaimDate != today;
    });
  }

  Future<void> _claimReward(DailyReward reward) async {
    if (!_canClaimToday) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // 更新連續登入天數
    final newStreak = _currentStreak + 1;
    await prefs.setInt('daily_streak', newStreak);
    await prefs.setString('last_claim_date', today);
    
    setState(() {
      _currentStreak = newStreak;
      _canClaimToday = false;
    });

    // 播放獎勵動畫
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // 顯示獎勵對話框
    _showRewardDialog(reward);
  }

  void _showRewardDialog(DailyReward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: reward.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                reward.icon,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🎉 恭喜！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: reward.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '你獲得了 ${reward.title}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: reward.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                '太棒了！',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每日獎勵'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade50,
              Colors.red.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 連續登入統計
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_currentStreak',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade400,
                        ),
                      ),
                      const Text(
                        '連續天數',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Icon(
                        _canClaimToday ? Icons.check_circle : Icons.schedule,
                        size: 32,
                        color: _canClaimToday ? Colors.green : Colors.orange,
                      ),
                      Text(
                        _canClaimToday ? '可領取' : '已領取',
                        style: TextStyle(
                          fontSize: 14,
                          color: _canClaimToday ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 獎勵列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rewards.length,
                itemBuilder: (context, index) {
                  final reward = _rewards[index];
                  final isUnlocked = _currentStreak >= reward.day;
                  final isToday = _currentStreak + 1 == reward.day;
                  
                  return AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isToday && _canClaimToday ? _scaleAnimation.value : 1.0,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isToday && _canClaimToday 
                                  ? () => _claimReward(reward)
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isUnlocked 
                                      ? Colors.white 
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isToday && _canClaimToday
                                      ? Border.all(
                                          color: reward.color,
                                          width: 2,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: isUnlocked 
                                            ? reward.color 
                                            : Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isUnlocked ? reward.icon : Icons.lock,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '第 ${reward.day} 天',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              if (isToday && _canClaimToday)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: reward.color,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Text(
                                                    '今日',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            reward.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isUnlocked 
                                                  ? Colors.black87 
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                          Text(
                                            reward.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isUnlocked 
                                                  ? Colors.grey.shade600 
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isUnlocked)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class DailyReward {
  final int day;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int value;

  DailyReward({
    required this.day,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
  });
} 