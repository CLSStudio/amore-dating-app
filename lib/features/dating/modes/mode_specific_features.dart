import 'package:flutter/material.dart';
import 'dating_mode_system.dart';

// ================== Amore 三大模式特定功能 ==================
  
/// 🔴 認真交往模式功能 - 深度連結與長期關係
class SeriousDatingFeatures {
  static List<Widget> getSpecialFeatures(BuildContext context) {
    return [
      _buildFeatureCard(
        context,
        '深度MBTI匹配',
        '基於16種人格類型的科學匹配算法，找到心靈契合的伴侶',
        Icons.psychology,
        Colors.red.shade400,
      ),
      _buildFeatureCard(
        context,
        '價值觀深度評估',
        '全方位分析人生價值觀，確保長期關係兼容性',
        Icons.favorite,
        Colors.pink.shade400,
      ),
      _buildFeatureCard(
        context,
        '專業愛情顧問',
        '一對一專業戀愛諮詢，關係發展指導服務',
        Icons.support_agent,
        Colors.purple.shade400,
      ),
      _buildFeatureCard(
        context,
        '關係里程碑追蹤',
        '記錄重要時刻，規劃長期關係發展路徑',
        Icons.timeline,
        Colors.indigo.shade400,
      ),
      _buildFeatureCard(
        context,
        '家庭規劃匹配',
        '評估生育、婚姻等人生規劃的一致性',
        Icons.family_restroom,
        Colors.teal.shade400,
      ),
      _buildFeatureCard(
        context,
        '財務目標對齊',
        '分析財務觀念和未來規劃的匹配度',
        Icons.savings,
        Colors.green.shade400,
      ),
    ];
  }

  static Widget buildModeSpecificUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.pink.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                '認真交往模式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '專為尋找人生伴侶而設計',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('匹配精準度', '95%', Icons.verified),
          const SizedBox(height: 8),
          _buildStatCard('長期關係成功率', '87%', Icons.trending_up),
          const SizedBox(height: 8),
          _buildStatCard('用戶滿意度', '92%', Icons.sentiment_very_satisfied),
        ],
      ),
    );
  }

  static Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade500, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔍 探索模式功能 - 發現與自我認識
class ExploreFeatures {
  static List<Widget> getSpecialFeatures(BuildContext context) {
    return [
      _buildFeatureCard(
        context,
        'AI智能推薦引擎',
        '根據行為分析智能推薦最適合的交友方式和對象',
        Icons.smart_toy,
        Colors.teal.shade400,
      ),
      _buildFeatureCard(
        context,
        '多樣化匹配體驗',
        '嘗試不同類型的配對，發現意想不到的連結',
        Icons.shuffle,
        Colors.cyan.shade400,
      ),
      _buildFeatureCard(
        context,
        '個性發現工具',
        '透過互動分析，深度了解自己的交友偏好',
        Icons.psychology,
        Colors.blue.shade400,
      ),
      _buildFeatureCard(
        context,
        '模式適應學習',
        '系統學習你的喜好，動態調整推薦策略',
        Icons.auto_awesome,
        Colors.purple.shade400,
      ),
      _buildFeatureCard(
        context,
        '探索歷程追蹤',
        '記錄你的探索之旅，visualize個人成長軌跡',
        Icons.timeline,
        Colors.green.shade400,
      ),
      _buildFeatureCard(
        context,
        '靈活模式切換',
        '隨時調整交友目標，無壓力探索不同可能性',
        Icons.swap_horiz,
        Colors.orange.shade400,
      ),
    ];
  }

  static Widget buildModeSpecificUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: Colors.teal.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                '探索模式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '發現最適合自己的交友方式',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildExploreStatCard('AI推薦準確度', '88%', Icons.psychology),
          const SizedBox(height: 8),
          _buildExploreStatCard('用戶探索滿意度', '91%', Icons.sentiment_satisfied),
          const SizedBox(height: 8),
          _buildExploreStatCard('成功發現率', '76%', Icons.lightbulb),
        ],
      ),
    );
  }

  static Widget _buildExploreStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal.shade500, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 激情模式功能 - 即時連結與安全體驗
class PassionFeatures {
  static List<Widget> getSpecialFeatures(BuildContext context) {
    return [
      _buildFeatureCard(
        context,
        '地理位置智能匹配',
        '基於位置和可用性的即時配對，把握每個機會',
        Icons.location_on,
        Colors.purple.shade400,
      ),
      _buildFeatureCard(
        context,
        '化學反應快速評估',
        '透過互動分析即時化學反應和吸引力指數',
        Icons.flash_on,
        Colors.pink.shade400,
      ),
      _buildFeatureCard(
        context,
        '私密聊天加密',
        '端到端加密保護隱私，安全的親密交流環境',
        Icons.security,
        Colors.indigo.shade400,
      ),
      _buildFeatureCard(
        context,
        '即時約會安排',
        '快速安排見面，抓住當下的火花和衝動',
        Icons.schedule,
        Colors.orange.shade400,
      ),
      _buildFeatureCard(
        context,
        '隱私模式切換',
        '一鍵切換隱身狀態，完全控制個人可見度',
        Icons.visibility_off,
        Colors.grey.shade400,
      ),
      _buildFeatureCard(
        context,
        '安全約會指導',
        '提供安全約會建議和緊急聯絡機制',
        Icons.shield,
        Colors.green.shade400,
      ),
    ];
  }

  static Widget buildModeSpecificUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nightlife, color: Colors.purple.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                '激情模式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '追求直接的親密關係體驗',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildPassionStatCard('即時匹配成功率', '82%', Icons.flash_on),
          const SizedBox(height: 8),
          _buildPassionStatCard('隱私保護評級', 'A+', Icons.security),
          const SizedBox(height: 8),
          _buildPassionStatCard('用戶滿意度', '89%', Icons.sentiment_very_satisfied),
        ],
      ),
    );
  }

  static Widget _buildPassionStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
        color: Colors.white,
              borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
            ),
            child: Row(
              children: [
          Icon(icon, color: Colors.purple.shade500, size: 20),
                const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
                    style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ================== 通用功能 ==================

/// 通用功能卡片構建器
Widget _buildFeatureCard(
  BuildContext context,
  String title,
  String description,
  IconData icon,
  Color color,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
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
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 🎯 模式特定功能管理器
class ModeSpecificFeaturesManager {
  /// 獲取模式特定功能
  static List<Widget> getFeaturesForMode(BuildContext context, DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return SeriousDatingFeatures.getSpecialFeatures(context);
      case DatingMode.explore:
        return ExploreFeatures.getSpecialFeatures(context);
      case DatingMode.passion:
        return PassionFeatures.getSpecialFeatures(context);
    }
  }

  /// 獲取模式特定UI
  static Widget getModeSpecificUI(BuildContext context, DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return SeriousDatingFeatures.buildModeSpecificUI(context);
      case DatingMode.explore:
        return ExploreFeatures.buildModeSpecificUI(context);
      case DatingMode.passion:
        return PassionFeatures.buildModeSpecificUI(context);
    }
  }

  /// 獲取模式建議文本
  static String getModeAdvice(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return '在認真交往模式中，建議完善你的個人檔案，誠實表達你的價值觀和未來規劃。這裡的用戶都在尋找長期穩定的關係，投入時間深入了解對方是成功的關鍵。';
      case DatingMode.explore:
        return '探索模式讓你自由嘗試不同的交友方式。不用擔心做錯選擇，AI會根據你的互動幫你找到最適合的方向。保持開放心態，每次互動都是認識自己的機會。';
      case DatingMode.passion:
        return '激情模式注重直接溝通和即時連結。請明確表達你的需求和界限，尊重他人的選擇。記住安全和隱私永遠是第一位的，在舒適的環境中享受親密關係。';
    }
  }

  /// 獲取模式成功秘訣
  static List<String> getModeSuccessTips(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return [
          '完善個人檔案，展現真實的自己',
          '主動參與深度對話和價值觀討論',
          '保持耐心，好的關係需要時間培養',
          '利用專業愛情顧問服務',
          '設定清晰的長期關係目標',
        ];
      case DatingMode.explore:
        return [
          '保持開放心態，勇於嘗試新體驗',
          '積極回饋AI推薦，幫助系統學習',
          '記錄探索歷程，了解自己的變化',
          '不要急於定義關係，享受探索過程',
          '利用多樣化匹配發現新可能性',
        ];
      case DatingMode.passion:
        return [
          '明確表達需求和界限',
          '使用隱私模式保護個人信息',
          '選擇安全的約會地點和時間',
          '保持即時通訊，把握機會',
          '尊重他人選擇，注重相互同意',
        ];
    }
  }
} 