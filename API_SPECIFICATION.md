# 📡 Amore 三大交友模式 API 規格文檔

## 🚀 API 概述

Amore 三大交友模式 API 為認真交往、輕鬆交友、探索世界三種不同的交友體驗提供後端支援。

### Base URL
```
Production: https://api.amore.hk/v1
Staging: https://staging-api.amore.hk/v1
Development: http://localhost:8080/v1
```

### 認證
所有 API 請求都需要在 Header 中包含有效的 JWT Token：
```
Authorization: Bearer <access_token>
```

## 🔄 模式管理 API

### 切換交友模式
```http
POST /dating-modes/switch
Content-Type: application/json
Authorization: Bearer <token>

{
  "newMode": "serious|casual|explorer",
  "reason": "string (optional)"
}
```

**回應**:
```json
{
  "success": true,
  "data": {
    "userId": "string",
    "previousMode": "serious|casual|explorer",
    "currentMode": "serious|casual|explorer",
    "switchedAt": "2024-12-01T10:00:00Z",
    "reason": "string"
  },
  "message": "模式切換成功"
}
```

### 獲取當前模式
```http
GET /dating-modes/current
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "currentMode": "serious|casual|explorer",
    "activeSince": "2024-12-01T10:00:00Z",
    "modeConfig": {
      "name": "認真交往",
      "primaryColor": "#1565C0",
      "features": ["value_matching", "mbti_compatibility", "goal_alignment"]
    }
  }
}
```

### 獲取模式歷史
```http
GET /dating-modes/history?limit=20&offset=0
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "history": [
      {
        "mode": "serious",
        "joinedAt": "2024-11-15T08:00:00Z",
        "leftAt": "2024-12-01T10:00:00Z",
        "duration": "16 days",
        "reason": "User switched"
      }
    ],
    "total": 5,
    "currentPage": 1
  }
}
```

## 👥 用戶池管理 API

### 加入模式用戶池
```http
POST /user-pools/{mode}/join
Content-Type: application/json
Authorization: Bearer <token>

{
  "profileData": {
    // 模式專屬檔案數據
  },
  "privacySettings": {
    "discoverable": true,
    "showLastSeen": false
  }
}
```

**回應**:
```json
{
  "success": true,
  "data": {
    "poolId": "string",
    "mode": "serious|casual|explorer",
    "joinedAt": "2024-12-01T10:00:00Z",
    "poolSize": 1250
  },
  "message": "成功加入認真交往用戶池"
}
```

### 離開模式用戶池
```http
DELETE /user-pools/{mode}/leave
Authorization: Bearer <token>
```

### 獲取用戶池統計
```http
GET /user-pools/{mode}/stats
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "mode": "serious",
    "totalUsers": 1250,
    "activeUsers": 890,
    "nearbyUsers": 45,
    "avgCompatibilityScore": 0.75,
    "lastUpdated": "2024-12-01T10:00:00Z"
  }
}
```

## 💕 配對演算法 API

### 獲取匹配候選人
```http
GET /matching/{mode}/candidates?limit=20&filters={filters}
Authorization: Bearer <token>
```

**Query Parameters**:
- `limit`: 返回數量 (預設 20, 最大 50)
- `filters`: JSON 字串，包含篩選條件

**認真交往模式篩選**:
```json
{
  "ageRange": [25, 35],
  "education": ["bachelor", "master", "phd"],
  "relationshipGoals": ["marriage", "long_term"],
  "coreValues": ["family", "honesty", "career"]
}
```

**輕鬆交友模式篩選**:
```json
{
  "interests": ["music", "travel", "fitness"],
  "socialStyle": ["extrovert", "ambivert"],
  "activityPreference": ["outdoor", "cultural", "nightlife"]
}
```

**探索世界模式篩選**:
```json
{
  "location": {
    "lat": 22.3193,
    "lng": 114.1694
  },
  "radius": 5000,
  "currentActivity": ["coffee", "shopping", "sightseeing"],
  "availableUntil": "2024-12-01T18:00:00Z"
}
```

**回應**:
```json
{
  "success": true,
  "data": {
    "candidates": [
      {
        "userId": "string",
        "profile": {
          "name": "Alice",
          "age": 28,
          "photos": ["url1", "url2"],
          "location": "Hong Kong",
          "modeSpecificData": {
            // 根據模式不同而變化
          }
        },
        "compatibilityScore": 0.85,
        "matchReasons": [
          "共同價值觀: 家庭, 誠實",
          "MBTI 相容性: 85%",
          "生活目標一致"
        ],
        "distance": 2.5
      }
    ],
    "total": 45,
    "hasMore": true
  }
}
```

### 計算相容性分數
```http
POST /matching/{mode}/compatibility
Content-Type: application/json
Authorization: Bearer <token>

{
  "targetUserId": "string"
}
```

**回應**:
```json
{
  "success": true,
  "data": {
    "compatibilityScore": 0.85,
    "breakdown": {
      "valueAlignment": 0.92,
      "lifestyleMatch": 0.78,
      "mbtiCompatibility": 0.85,
      "goalAlignment": 0.87
    },
    "strengths": [
      "價值觀高度一致",
      "MBTI 類型非常相容",
      "長期目標匹配"
    ],
    "considerations": [
      "生活方式略有差異"
    ]
  }
}
```

### 即時位置匹配 (探索模式)
```http
GET /matching/explorer/nearby?lat={lat}&lng={lng}&radius={radius}
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "nearbyUsers": [
      {
        "userId": "string",
        "profile": {
          "name": "Bob",
          "age": 26,
          "currentActivity": "想喝咖啡",
          "availableUntil": "2024-12-01T16:00:00Z"
        },
        "location": {
          "lat": 22.3205,
          "lng": 114.1703,
          "address": "中環置地廣場附近"
        },
        "distance": 0.8,
        "lastSeen": "2分鐘前"
      }
    ],
    "total": 8
  }
}
```

## 👤 模式專屬檔案 API

### 更新認真交往檔案
```http
PUT /profiles/serious
Content-Type: application/json
Authorization: Bearer <token>

{
  "occupation": "軟體工程師",
  "education": "computer_science_master",
  "company": "Google Hong Kong",
  "relationshipGoals": "marriage",
  "familyPlanning": "want_children",
  "coreValues": ["honesty", "family", "career", "travel"],
  "mbtiType": "ENFJ",
  "lifestyle": {
    "smokingStatus": "non_smoker",
    "drinkingHabits": "social_drinker",
    "fitnessLevel": "active",
    "dietaryPreferences": ["vegetarian"]
  },
  "futureGoals": {
    "careerAspiration": "成為技術主管",
    "travelPlans": ["日本", "歐洲"],
    "lifePhilosophy": "工作與生活平衡"
  }
}
```

### 更新輕鬆交友檔案
```http
PUT /profiles/casual
Content-Type: application/json
Authorization: Bearer <token>

{
  "hobbies": ["音樂", "攝影", "健身", "美食"],
  "musicGenres": ["indie", "jazz", "electronic"],
  "favoriteMovies": ["inception", "la_la_land", "your_name"],
  "socialActivities": ["concerts", "art_exhibitions", "hiking"],
  "currentMood": "想要探索新的餐廳",
  "weekendPreference": "戶外活動",
  "socialStyle": "ambivert",
  "funFacts": [
    "會說四種語言",
    "曾經背包旅行三個月",
    "正在學習吉他"
  ]
}
```

### 更新探索世界檔案
```http
PUT /profiles/explorer
Content-Type: application/json
Authorization: Bearer <token>

{
  "currentLocation": {
    "lat": 22.3193,
    "lng": 114.1694,
    "address": "中環"
  },
  "currentActivity": "想找人一起喝咖啡",
  "availableUntil": "2024-12-01T18:00:00Z",
  "lookingFor": "coffee_companion",
  "mood": "探索新地方",
  "transportPreference": "walking",
  "budgetRange": "100-300",
  "activityType": "spontaneous"
}
```

### 獲取模式檔案
```http
GET /profiles/{mode}
Authorization: Bearer <token>
```

## 📱 Story 內容 API

### 發布模式專屬 Story
```http
POST /stories
Content-Type: multipart/form-data
Authorization: Bearer <token>

{
  "mode": "serious|casual|explorer",
  "content": "今天的深度思考...",
  "mediaType": "text|image|video",
  "media": file,
  "tags": ["reflection", "values"],
  "visibility": "mode_only|public",
  "expiresIn": 86400
}
```

### 獲取模式 Story Feed
```http
GET /stories/feed/{mode}?limit=20&lastStoryId={id}
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "stories": [
      {
        "storyId": "string",
        "userId": "string",
        "author": {
          "name": "Alice",
          "profilePhoto": "url"
        },
        "mode": "serious",
        "content": "今天反思了人生目標...",
        "mediaUrl": "url",
        "tags": ["reflection"],
        "createdAt": "2024-12-01T10:00:00Z",
        "expiresAt": "2024-12-02T10:00:00Z",
        "reactions": {
          "likes": 15,
          "comments": 3,
          "userReacted": true
        }
      }
    ],
    "hasMore": true
  }
}
```

## 🎯 探索功能 API

### 認真交往探索
```http
GET /explore/serious?category=values|articles|questions
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "category": "values",
    "content": [
      {
        "id": "string",
        "title": "如何建立健康的關係邊界",
        "type": "article",
        "author": "關係專家 Dr. Chen",
        "readTime": "5 分鐘",
        "tags": ["boundaries", "communication"],
        "url": "https://api.amore.hk/articles/healthy-boundaries"
      }
    ]
  }
}
```

### 輕鬆交友探索
```http
GET /explore/casual?category=activities|events|groups
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "category": "activities",
    "content": [
      {
        "id": "string",
        "title": "週末攝影漫步",
        "type": "group_activity",
        "organizer": "Hong Kong Photography Club",
        "date": "2024-12-07T14:00:00Z",
        "location": "中環海濱",
        "participants": 12,
        "maxParticipants": 20,
        "tags": ["photography", "outdoor"]
      }
    ]
  }
}
```

### 探索世界地圖
```http
GET /explore/explorer/map?lat={lat}&lng={lng}&radius={radius}
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "mapData": {
      "center": {
        "lat": 22.3193,
        "lng": 114.1694
      },
      "zoom": 15,
      "markers": [
        {
          "id": "string",
          "type": "user|activity|venue",
          "position": {
            "lat": 22.3200,
            "lng": 114.1700
          },
          "data": {
            "title": "咖啡愛好者聚會",
            "participants": 3,
            "startTime": "2024-12-01T15:00:00Z"
          }
        }
      ]
    }
  }
}
```

## 📊 分析與統計 API

### 模式使用統計
```http
GET /analytics/mode-usage?period=7d|30d|90d
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "period": "30d",
    "modeUsage": {
      "serious": {
        "activeDays": 18,
        "avgSessionDuration": "25 minutes",
        "totalMatches": 12,
        "conversationRate": 0.75
      },
      "casual": {
        "activeDays": 8,
        "avgSessionDuration": "15 minutes", 
        "totalMatches": 6,
        "conversationRate": 0.83
      },
      "explorer": {
        "activeDays": 4,
        "avgSessionDuration": "10 minutes",
        "totalMatches": 3,
        "meetupRate": 0.67
      }
    }
  }
}
```

### 配對成功率
```http
GET /analytics/matching-success?mode={mode}&period=30d
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "mode": "serious",
    "period": "30d",
    "metrics": {
      "totalProfilesViewed": 45,
      "totalLikes": 12,
      "mutualLikes": 8,
      "conversations": 6,
      "dates": 2,
      "conversionRates": {
        "viewToLike": 0.27,
        "likeToMatch": 0.67,
        "matchToConversation": 0.75,
        "conversationToDate": 0.33
      }
    }
  }
}
```

## 🔔 通知 API

### 獲取模式相關通知
```http
GET /notifications?mode={mode}&limit=20
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "string",
        "type": "new_match|message|mode_suggestion",
        "mode": "serious",
        "title": "新的高相容性匹配！",
        "message": "您與 Alice 的相容性達到 92%",
        "data": {
          "userId": "string",
          "compatibilityScore": 0.92
        },
        "read": false,
        "createdAt": "2024-12-01T10:00:00Z"
      }
    ],
    "unreadCount": 3
  }
}
```

### 模式建議通知
```http
GET /notifications/mode-suggestions
Authorization: Bearer <token>
```

**回應**:
```json
{
  "success": true,
  "data": {
    "suggestions": [
      {
        "suggestedMode": "casual",
        "reason": "基於您的最近活動模式",
        "confidence": 0.78,
        "benefits": [
          "可能遇到更多活躍用戶",
          "匹配度相似的興趣愛好者"
        ]
      }
    ]
  }
}
```

## 🚨 錯誤處理

### 標準錯誤格式
```json
{
  "success": false,
  "error": {
    "code": "INVALID_MODE",
    "message": "指定的交友模式無效",
    "details": {
      "validModes": ["serious", "casual", "explorer"],
      "provided": "invalid_mode"
    }
  },
  "timestamp": "2024-12-01T10:00:00Z"
}
```

### 錯誤代碼列表
```yaml
通用錯誤:
  - UNAUTHORIZED: 未授權訪問
  - FORBIDDEN: 權限不足
  - NOT_FOUND: 資源不存在
  - VALIDATION_ERROR: 輸入驗證失敗
  - RATE_LIMIT_EXCEEDED: 超出速率限制

模式相關錯誤:
  - INVALID_MODE: 無效的交友模式
  - MODE_SWITCH_COOLDOWN: 模式切換冷卻期間
  - INCOMPLETE_PROFILE: 檔案資訊不完整
  - POOL_NOT_ACTIVE: 用戶池未啟用

配對相關錯誤:
  - NO_CANDIDATES: 沒有可用的匹配候選人
  - COMPATIBILITY_CALCULATION_FAILED: 相容性計算失敗
  - LOCATION_REQUIRED: 探索模式需要位置資訊
```

## 📋 速率限制

```yaml
API 端點速率限制:
  一般 API: 100 requests/minute
  配對 API: 50 requests/minute  
  即時位置: 20 requests/minute
  分析 API: 10 requests/minute
  上傳 API: 5 requests/minute
```

## 🔐 安全性

### 資料加密
- 所有敏感資料使用 AES-256 加密
- 位置資訊使用地理哈希模糊化
- 個人資料遵循 GDPR 合規

### API 安全
- JWT Token 有效期: 24小時
- Refresh Token 有效期: 30天
- HTTPS 強制要求
- API Key 輪換機制

---

**API 版本**: v1.0  
**文檔更新**: 2024年12月  
**維護團隊**: Amore Backend Team 