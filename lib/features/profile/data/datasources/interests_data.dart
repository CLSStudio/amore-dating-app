import '../../domain/entities/profile.dart';

/// 興趣數據源
class InterestsData {
  static List<Interest> getAllInterests() {
    return [
      // 運動健身
      const Interest(
        id: 'fitness_gym',
        name: '健身房',
        category: '運動健身',
        icon: '💪',
      ),
      const Interest(
        id: 'fitness_running',
        name: '跑步',
        category: '運動健身',
        icon: '🏃',
      ),
      const Interest(
        id: 'fitness_yoga',
        name: '瑜伽',
        category: '運動健身',
        icon: '🧘',
      ),
      const Interest(
        id: 'fitness_swimming',
        name: '游泳',
        category: '運動健身',
        icon: '🏊',
      ),
      const Interest(
        id: 'fitness_hiking',
        name: '行山',
        category: '運動健身',
        icon: '🥾',
      ),
      const Interest(
        id: 'fitness_cycling',
        name: '單車',
        category: '運動健身',
        icon: '🚴',
      ),
      const Interest(
        id: 'fitness_tennis',
        name: '網球',
        category: '運動健身',
        icon: '🎾',
      ),
      const Interest(
        id: 'fitness_basketball',
        name: '籃球',
        category: '運動健身',
        icon: '🏀',
      ),

      // 藝術文化
      const Interest(
        id: 'art_painting',
        name: '繪畫',
        category: '藝術文化',
        icon: '🎨',
      ),
      const Interest(
        id: 'art_photography',
        name: '攝影',
        category: '藝術文化',
        icon: '📸',
      ),
      const Interest(
        id: 'art_music',
        name: '音樂',
        category: '藝術文化',
        icon: '🎵',
      ),
      const Interest(
        id: 'art_dancing',
        name: '舞蹈',
        category: '藝術文化',
        icon: '💃',
      ),
      const Interest(
        id: 'art_theater',
        name: '戲劇',
        category: '藝術文化',
        icon: '🎭',
      ),
      const Interest(
        id: 'art_museum',
        name: '博物館',
        category: '藝術文化',
        icon: '🏛️',
      ),
      const Interest(
        id: 'art_concert',
        name: '音樂會',
        category: '藝術文化',
        icon: '🎼',
      ),
      const Interest(
        id: 'art_opera',
        name: '歌劇',
        category: '藝術文化',
        icon: '🎭',
      ),

      // 美食料理
      const Interest(
        id: 'food_cooking',
        name: '烹飪',
        category: '美食料理',
        icon: '👨‍🍳',
      ),
      const Interest(
        id: 'food_baking',
        name: '烘焙',
        category: '美食料理',
        icon: '🧁',
      ),
      const Interest(
        id: 'food_wine',
        name: '品酒',
        category: '美食料理',
        icon: '🍷',
      ),
      const Interest(
        id: 'food_coffee',
        name: '咖啡',
        category: '美食料理',
        icon: '☕',
      ),
      const Interest(
        id: 'food_tea',
        name: '茶藝',
        category: '美食料理',
        icon: '🍵',
      ),
      const Interest(
        id: 'food_restaurant',
        name: '餐廳探索',
        category: '美食料理',
        icon: '🍽️',
      ),
      const Interest(
        id: 'food_street',
        name: '街頭小食',
        category: '美食料理',
        icon: '🌮',
      ),
      const Interest(
        id: 'food_dessert',
        name: '甜品',
        category: '美食料理',
        icon: '🍰',
      ),

      // 旅遊探險
      const Interest(
        id: 'travel_backpacking',
        name: '背包旅行',
        category: '旅遊探險',
        icon: '🎒',
      ),
      const Interest(
        id: 'travel_luxury',
        name: '豪華旅遊',
        category: '旅遊探險',
        icon: '✈️',
      ),
      const Interest(
        id: 'travel_camping',
        name: '露營',
        category: '旅遊探險',
        icon: '⛺',
      ),
      const Interest(
        id: 'travel_beach',
        name: '海灘度假',
        category: '旅遊探險',
        icon: '🏖️',
      ),
      const Interest(
        id: 'travel_mountain',
        name: '山區探險',
        category: '旅遊探險',
        icon: '🏔️',
      ),
      const Interest(
        id: 'travel_city',
        name: '城市探索',
        category: '旅遊探險',
        icon: '🏙️',
      ),
      const Interest(
        id: 'travel_culture',
        name: '文化之旅',
        category: '旅遊探險',
        icon: '🗿',
      ),
      const Interest(
        id: 'travel_road_trip',
        name: '公路旅行',
        category: '旅遊探險',
        icon: '🚗',
      ),

      // 科技數碼
      const Interest(
        id: 'tech_programming',
        name: '程式設計',
        category: '科技數碼',
        icon: '💻',
      ),
      const Interest(
        id: 'tech_gaming',
        name: '電子遊戲',
        category: '科技數碼',
        icon: '🎮',
      ),
      const Interest(
        id: 'tech_ai',
        name: '人工智能',
        category: '科技數碼',
        icon: '🤖',
      ),
      const Interest(
        id: 'tech_crypto',
        name: '加密貨幣',
        category: '科技數碼',
        icon: '₿',
      ),
      const Interest(
        id: 'tech_gadgets',
        name: '數碼產品',
        category: '科技數碼',
        icon: '📱',
      ),
      const Interest(
        id: 'tech_vr',
        name: '虛擬實境',
        category: '科技數碼',
        icon: '🥽',
      ),
      const Interest(
        id: 'tech_drone',
        name: '無人機',
        category: '科技數碼',
        icon: '🚁',
      ),
      const Interest(
        id: 'tech_3d_printing',
        name: '3D 打印',
        category: '科技數碼',
        icon: '🖨️',
      ),

      // 閱讀學習
      const Interest(
        id: 'reading_fiction',
        name: '小說',
        category: '閱讀學習',
        icon: '📚',
      ),
      const Interest(
        id: 'reading_non_fiction',
        name: '非小說',
        category: '閱讀學習',
        icon: '📖',
      ),
      const Interest(
        id: 'reading_biography',
        name: '傳記',
        category: '閱讀學習',
        icon: '👤',
      ),
      const Interest(
        id: 'reading_history',
        name: '歷史',
        category: '閱讀學習',
        icon: '🏛️',
      ),
      const Interest(
        id: 'reading_philosophy',
        name: '哲學',
        category: '閱讀學習',
        icon: '🤔',
      ),
      const Interest(
        id: 'reading_science',
        name: '科學',
        category: '閱讀學習',
        icon: '🔬',
      ),
      const Interest(
        id: 'reading_self_help',
        name: '自我提升',
        category: '閱讀學習',
        icon: '📈',
      ),
      const Interest(
        id: 'reading_poetry',
        name: '詩歌',
        category: '閱讀學習',
        icon: '📝',
      ),

      // 娛樂休閒
      const Interest(
        id: 'entertainment_movies',
        name: '電影',
        category: '娛樂休閒',
        icon: '🎬',
      ),
      const Interest(
        id: 'entertainment_tv',
        name: '電視劇',
        category: '娛樂休閒',
        icon: '📺',
      ),
      const Interest(
        id: 'entertainment_anime',
        name: '動漫',
        category: '娛樂休閒',
        icon: '🎌',
      ),
      const Interest(
        id: 'entertainment_podcast',
        name: '播客',
        category: '娛樂休閒',
        icon: '🎧',
      ),
      const Interest(
        id: 'entertainment_board_games',
        name: '桌遊',
        category: '娛樂休閒',
        icon: '🎲',
      ),
      const Interest(
        id: 'entertainment_karaoke',
        name: 'K歌',
        category: '娛樂休閒',
        icon: '🎤',
      ),
      const Interest(
        id: 'entertainment_comedy',
        name: '喜劇',
        category: '娛樂休閒',
        icon: '😂',
      ),
      const Interest(
        id: 'entertainment_magic',
        name: '魔術',
        category: '娛樂休閒',
        icon: '🎩',
      ),

      // 社交活動
      const Interest(
        id: 'social_party',
        name: '派對',
        category: '社交活動',
        icon: '🎉',
      ),
      const Interest(
        id: 'social_networking',
        name: '人脈建立',
        category: '社交活動',
        icon: '🤝',
      ),
      const Interest(
        id: 'social_volunteer',
        name: '義工服務',
        category: '社交活動',
        icon: '❤️',
      ),
      const Interest(
        id: 'social_club',
        name: '俱樂部',
        category: '社交活動',
        icon: '🏛️',
      ),
      const Interest(
        id: 'social_meetup',
        name: '聚會',
        category: '社交活動',
        icon: '👥',
      ),
      const Interest(
        id: 'social_dating',
        name: '約會',
        category: '社交活動',
        icon: '💕',
      ),
      const Interest(
        id: 'social_nightlife',
        name: '夜生活',
        category: '社交活動',
        icon: '🌃',
      ),
      const Interest(
        id: 'social_events',
        name: '活動參與',
        category: '社交活動',
        icon: '🎪',
      ),
    ];
  }

  /// 根據類別獲取興趣
  static List<Interest> getInterestsByCategory(String category) {
    return getAllInterests().where((interest) => interest.category == category).toList();
  }

  /// 獲取所有類別
  static List<String> getAllCategories() {
    return getAllInterests()
        .map((interest) => interest.category)
        .toSet()
        .toList();
  }

  /// 搜索興趣
  static List<Interest> searchInterests(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllInterests()
        .where((interest) => 
            interest.name.toLowerCase().contains(lowercaseQuery) ||
            interest.category.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// 獲取推薦興趣（基於 MBTI 類型）
  static List<Interest> getRecommendedInterests(String? mbtiType) {
    if (mbtiType == null) return [];

    final allInterests = getAllInterests();
    
    // 根據 MBTI 類型推薦興趣
    switch (mbtiType) {
      case 'ENFP':
      case 'ENFJ':
        return allInterests.where((interest) => 
            interest.category == '藝術文化' || 
            interest.category == '社交活動' ||
            interest.category == '旅遊探險').toList();
            
      case 'INTJ':
      case 'INTP':
        return allInterests.where((interest) => 
            interest.category == '科技數碼' || 
            interest.category == '閱讀學習' ||
            interest.category == '藝術文化').toList();
            
      case 'ESFP':
      case 'ESFJ':
        return allInterests.where((interest) => 
            interest.category == '娛樂休閒' || 
            interest.category == '社交活動' ||
            interest.category == '美食料理').toList();
            
      case 'ISTJ':
      case 'ISFJ':
        return allInterests.where((interest) => 
            interest.category == '運動健身' || 
            interest.category == '閱讀學習' ||
            interest.category == '美食料理').toList();
            
      default:
        return allInterests.take(20).toList();
    }
  }
} 