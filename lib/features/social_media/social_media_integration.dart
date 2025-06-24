import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// 社交媒體平台
enum SocialMediaPlatform {
  instagram,
  spotify,
  tiktok,
  facebook,
  twitter,
  linkedin,
  youtube,
}

// 連接狀態
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
  expired,
}

// 社交媒體帳戶
class SocialMediaAccount {
  final SocialMediaPlatform platform;
  final String accountId;
  final String username;
  final String displayName;
  final String? profileImageUrl;
  final ConnectionStatus status;
  final DateTime? connectedAt;
  final DateTime? lastSyncAt;
  final Map<String, dynamic>? metadata;
  final bool isVerified;
  final bool isPublic;

  SocialMediaAccount({
    required this.platform,
    required this.accountId,
    required this.username,
    required this.displayName,
    this.profileImageUrl,
    required this.status,
    this.connectedAt,
    this.lastSyncAt,
    this.metadata,
    this.isVerified = false,
    this.isPublic = true,
  });

  SocialMediaAccount copyWith({
    SocialMediaPlatform? platform,
    String? accountId,
    String? username,
    String? displayName,
    String? profileImageUrl,
    ConnectionStatus? status,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
    Map<String, dynamic>? metadata,
    bool? isVerified,
    bool? isPublic,
  }) {
    return SocialMediaAccount(
      platform: platform ?? this.platform,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      metadata: metadata ?? this.metadata,
      isVerified: isVerified ?? this.isVerified,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  String get platformName {
    switch (platform) {
      case SocialMediaPlatform.instagram:
        return 'Instagram';
      case SocialMediaPlatform.spotify:
        return 'Spotify';
      case SocialMediaPlatform.tiktok:
        return 'TikTok';
      case SocialMediaPlatform.facebook:
        return 'Facebook';
      case SocialMediaPlatform.twitter:
        return 'Twitter';
      case SocialMediaPlatform.linkedin:
        return 'LinkedIn';
      case SocialMediaPlatform.youtube:
        return 'YouTube';
    }
  }

  IconData get platformIcon {
    switch (platform) {
      case SocialMediaPlatform.instagram:
        return Icons.camera_alt;
      case SocialMediaPlatform.spotify:
        return Icons.music_note;
      case SocialMediaPlatform.tiktok:
        return Icons.video_library;
      case SocialMediaPlatform.facebook:
        return Icons.facebook;
      case SocialMediaPlatform.twitter:
        return Icons.alternate_email;
      case SocialMediaPlatform.linkedin:
        return Icons.business;
      case SocialMediaPlatform.youtube:
        return Icons.play_circle;
    }
  }

  Color get platformColor {
    switch (platform) {
      case SocialMediaPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialMediaPlatform.spotify:
        return const Color(0xFF1DB954);
      case SocialMediaPlatform.tiktok:
        return const Color(0xFF000000);
      case SocialMediaPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialMediaPlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SocialMediaPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialMediaPlatform.youtube:
        return const Color(0xFFFF0000);
    }
  }
}

// Instagram 內容
class InstagramContent {
  final String id;
  final String mediaUrl;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isVideo;

  InstagramContent({
    required this.id,
    required this.mediaUrl,
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isVideo = false,
  });
}

// Spotify 內容
class SpotifyContent {
  final String id;
  final String name;
  final String artist;
  final String? albumName;
  final String? albumImageUrl;
  final String? previewUrl;
  final int durationMs;
  final bool isPlaying;

  SpotifyContent({
    required this.id,
    required this.name,
    required this.artist,
    this.albumName,
    this.albumImageUrl,
    this.previewUrl,
    this.durationMs = 0,
    this.isPlaying = false,
  });
}

// TikTok 內容
class TikTokContent {
  final String id;
  final String videoUrl;
  final String? description;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int viewsCount;
  final int likesCount;
  final int sharesCount;

  TikTokContent({
    required this.id,
    required this.videoUrl,
    this.description,
    this.thumbnailUrl,
    required this.createdAt,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.sharesCount = 0,
  });
}

// 社交媒體狀態管理
final socialMediaAccountsProvider = StateNotifierProvider<SocialMediaAccountsNotifier, List<SocialMediaAccount>>((ref) {
  return SocialMediaAccountsNotifier();
});

final instagramContentProvider = StateNotifierProvider<InstagramContentNotifier, List<InstagramContent>>((ref) {
  return InstagramContentNotifier();
});

final spotifyContentProvider = StateNotifierProvider<SpotifyContentNotifier, List<SpotifyContent>>((ref) {
  return SpotifyContentNotifier();
});

final tiktokContentProvider = StateNotifierProvider<TikTokContentNotifier, List<TikTokContent>>((ref) {
  return TikTokContentNotifier();
});

class SocialMediaAccountsNotifier extends StateNotifier<List<SocialMediaAccount>> {
  SocialMediaAccountsNotifier() : super([]);

  void addAccount(SocialMediaAccount account) {
    // 移除同平台的舊帳戶
    state = state.where((a) => a.platform != account.platform).toList();
    // 添加新帳戶
    state = [...state, account];
  }

  void updateAccount(SocialMediaAccount updatedAccount) {
    state = state.map((account) {
      if (account.platform == updatedAccount.platform) {
        return updatedAccount;
      }
      return account;
    }).toList();
  }

  void removeAccount(SocialMediaPlatform platform) {
    state = state.where((account) => account.platform != platform).toList();
  }

  SocialMediaAccount? getAccount(SocialMediaPlatform platform) {
    try {
      return state.firstWhere((account) => account.platform == platform);
    } catch (e) {
      return null;
    }
  }

  bool isConnected(SocialMediaPlatform platform) {
    final account = getAccount(platform);
    return account?.status == ConnectionStatus.connected;
  }
}

class InstagramContentNotifier extends StateNotifier<List<InstagramContent>> {
  InstagramContentNotifier() : super([]);

  void loadContent(List<InstagramContent> content) {
    state = content;
  }

  void addContent(InstagramContent content) {
    state = [content, ...state];
  }
}

class SpotifyContentNotifier extends StateNotifier<List<SpotifyContent>> {
  SpotifyContentNotifier() : super([]);

  void loadContent(List<SpotifyContent> content) {
    state = content;
  }

  void updateNowPlaying(SpotifyContent? nowPlaying) {
    if (nowPlaying != null) {
      state = [nowPlaying, ...state.where((s) => s.id != nowPlaying.id)];
    }
  }
}

class TikTokContentNotifier extends StateNotifier<List<TikTokContent>> {
  TikTokContentNotifier() : super([]);

  void loadContent(List<TikTokContent> content) {
    state = content;
  }

  void addContent(TikTokContent content) {
    state = [content, ...state];
  }
}

// 社交媒體服務
class SocialMediaService {
  // Instagram 連接
  static Future<SocialMediaAccount?> connectInstagram() async {
    try {
      // 模擬 Instagram OAuth 流程
      await Future.delayed(const Duration(seconds: 2));
      
      // 模擬成功連接
      return SocialMediaAccount(
        platform: SocialMediaPlatform.instagram,
        accountId: 'ig_123456',
        username: 'user_instagram',
        displayName: '我的 Instagram',
        profileImageUrl: '📷',
        status: ConnectionStatus.connected,
        connectedAt: DateTime.now(),
        lastSyncAt: DateTime.now(),
        isVerified: true,
        metadata: {
          'followersCount': 1250,
          'followingCount': 890,
          'postsCount': 156,
        },
      );
    } catch (e) {
      return null;
    }
  }

  // Spotify 連接
  static Future<SocialMediaAccount?> connectSpotify() async {
    try {
      // 模擬 Spotify OAuth 流程
      await Future.delayed(const Duration(seconds: 2));
      
      return SocialMediaAccount(
        platform: SocialMediaPlatform.spotify,
        accountId: 'spotify_123456',
        username: 'user_spotify',
        displayName: '我的 Spotify',
        profileImageUrl: '🎵',
        status: ConnectionStatus.connected,
        connectedAt: DateTime.now(),
        lastSyncAt: DateTime.now(),
        isVerified: true,
        metadata: {
          'playlistsCount': 25,
          'followersCount': 45,
          'topGenres': ['Pop', 'Rock', 'Electronic'],
        },
      );
    } catch (e) {
      return null;
    }
  }

  // TikTok 連接
  static Future<SocialMediaAccount?> connectTikTok() async {
    try {
      // 模擬 TikTok OAuth 流程
      await Future.delayed(const Duration(seconds: 2));
      
      return SocialMediaAccount(
        platform: SocialMediaPlatform.tiktok,
        accountId: 'tiktok_123456',
        username: 'user_tiktok',
        displayName: '我的 TikTok',
        profileImageUrl: '🎬',
        status: ConnectionStatus.connected,
        connectedAt: DateTime.now(),
        lastSyncAt: DateTime.now(),
        isVerified: false,
        metadata: {
          'followersCount': 2340,
          'followingCount': 567,
          'videosCount': 89,
          'likesCount': 15600,
        },
      );
    } catch (e) {
      return null;
    }
  }

  // 斷開連接
  static Future<bool> disconnectAccount(SocialMediaPlatform platform) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // 獲取 Instagram 內容
  static Future<List<InstagramContent>> getInstagramContent() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return [
      InstagramContent(
        id: 'ig_post_1',
        mediaUrl: '📸',
        caption: '今天的咖啡拉花 ☕️ #coffee #latte',
        createdAt: now.subtract(const Duration(hours: 2)),
        likesCount: 45,
        commentsCount: 8,
      ),
      InstagramContent(
        id: 'ig_post_2',
        mediaUrl: '🌅',
        caption: '美麗的日出 🌅 #sunrise #nature',
        createdAt: now.subtract(const Duration(days: 1)),
        likesCount: 89,
        commentsCount: 12,
      ),
      InstagramContent(
        id: 'ig_post_3',
        mediaUrl: '🍕',
        caption: '週末的美食時光 🍕 #food #weekend',
        createdAt: now.subtract(const Duration(days: 2)),
        likesCount: 67,
        commentsCount: 15,
      ),
    ];
  }

  // 獲取 Spotify 內容
  static Future<List<SpotifyContent>> getSpotifyContent() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      SpotifyContent(
        id: 'spotify_track_1',
        name: 'Blinding Lights',
        artist: 'The Weeknd',
        albumName: 'After Hours',
        albumImageUrl: '🎵',
        durationMs: 200040,
        isPlaying: true,
      ),
      SpotifyContent(
        id: 'spotify_track_2',
        name: 'Watermelon Sugar',
        artist: 'Harry Styles',
        albumName: 'Fine Line',
        albumImageUrl: '🎶',
        durationMs: 174000,
      ),
      SpotifyContent(
        id: 'spotify_track_3',
        name: 'Levitating',
        artist: 'Dua Lipa',
        albumName: 'Future Nostalgia',
        albumImageUrl: '🎤',
        durationMs: 203064,
      ),
    ];
  }

  // 獲取 TikTok 內容
  static Future<List<TikTokContent>> getTikTokContent() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    return [
      TikTokContent(
        id: 'tiktok_video_1',
        videoUrl: '🎬',
        description: '今天學會的新舞蹈 💃 #dance #trending',
        thumbnailUrl: '💃',
        createdAt: now.subtract(const Duration(hours: 6)),
        viewsCount: 1250,
        likesCount: 89,
        sharesCount: 12,
      ),
      TikTokContent(
        id: 'tiktok_video_2',
        videoUrl: '🎭',
        description: '搞笑日常 😂 #funny #comedy',
        thumbnailUrl: '😂',
        createdAt: now.subtract(const Duration(days: 1)),
        viewsCount: 3400,
        likesCount: 234,
        sharesCount: 45,
      ),
    ];
  }
}

// 社交媒體集成頁面
class SocialMediaIntegrationPage extends ConsumerWidget {
  const SocialMediaIntegrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(socialMediaAccountsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('社交媒體'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildHeaderCard(),
          _buildConnectedAccountsSection(context, ref, accounts),
          _buildAvailablePlatformsSection(context, ref, accounts),
          _buildContentPreviewSection(context, ref, accounts),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔗',
            style: TextStyle(fontSize: 32),
          ),
          SizedBox(height: 12),
          Text(
            '連接社交媒體',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '展示你的真實生活，讓配對更加精準',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsSection(BuildContext context, WidgetRef ref, List<SocialMediaAccount> accounts) {
    final connectedAccounts = accounts.where((a) => a.status == ConnectionStatus.connected).toList();

    if (connectedAccounts.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '已連接帳戶',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ...connectedAccounts.map((account) => _buildConnectedAccountItem(context, ref, account)),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountItem(BuildContext context, WidgetRef ref, SocialMediaAccount account) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: account.platformColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: account.profileImageUrl != null
            ? Center(
                child: Text(
                  account.profileImageUrl!,
                  style: const TextStyle(fontSize: 24),
                ),
              )
            : Icon(
                account.platformIcon,
                color: account.platformColor,
                size: 24,
              ),
      ),
      title: Row(
        children: [
          Text(
            account.platformName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (account.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.verified,
              color: Colors.blue,
              size: 16,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${account.username}'),
          const SizedBox(height: 4),
          Text(
            '最後同步：${_formatLastSync(account.lastSyncAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAccountAction(context, ref, account, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'sync',
            child: Text('同步內容'),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: Text('設置'),
          ),
          const PopupMenuItem(
            value: 'disconnect',
            child: Text('斷開連接'),
          ),
        ],
      ),
      onTap: () => _showAccountDetails(context, ref, account),
    );
  }

  Widget _buildAvailablePlatformsSection(BuildContext context, WidgetRef ref, List<SocialMediaAccount> accounts) {
    final availablePlatforms = [
      SocialMediaPlatform.instagram,
      SocialMediaPlatform.spotify,
      SocialMediaPlatform.tiktok,
    ];

    final unconnectedPlatforms = availablePlatforms.where((platform) {
      return !accounts.any((account) => 
          account.platform == platform && account.status == ConnectionStatus.connected);
    }).toList();

    if (unconnectedPlatforms.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '可連接平台',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ...unconnectedPlatforms.map((platform) => _buildAvailablePlatformItem(context, ref, platform)),
        ],
      ),
    );
  }

  Widget _buildAvailablePlatformItem(BuildContext context, WidgetRef ref, SocialMediaPlatform platform) {
    final platformAccount = SocialMediaAccount(
      platform: platform,
      accountId: '',
      username: '',
      displayName: '',
      status: ConnectionStatus.disconnected,
    );

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: platformAccount.platformColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          platformAccount.platformIcon,
          color: platformAccount.platformColor,
          size: 24,
        ),
      ),
      title: Text(
        platformAccount.platformName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(_getPlatformDescription(platform)),
      trailing: ElevatedButton(
        onPressed: () => _connectPlatform(context, ref, platform),
        style: ElevatedButton.styleFrom(
          backgroundColor: platformAccount.platformColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('連接'),
      ),
    );
  }

  Widget _buildContentPreviewSection(BuildContext context, WidgetRef ref, List<SocialMediaAccount> accounts) {
    final connectedAccounts = accounts.where((a) => a.status == ConnectionStatus.connected).toList();

    if (connectedAccounts.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '內容預覽',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ...connectedAccounts.map((account) => _buildContentPreviewItem(context, ref, account)),
        ],
      ),
    );
  }

  Widget _buildContentPreviewItem(BuildContext context, WidgetRef ref, SocialMediaAccount account) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: account.platformColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          account.platformIcon,
          color: account.platformColor,
          size: 24,
        ),
      ),
      title: Text(account.platformName),
      subtitle: Text(_getContentPreviewText(account)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showContentDetails(context, ref, account),
    );
  }

  String _getPlatformDescription(SocialMediaPlatform platform) {
    switch (platform) {
      case SocialMediaPlatform.instagram:
        return '分享你的照片和生活瞬間';
      case SocialMediaPlatform.spotify:
        return '展示你的音樂品味';
      case SocialMediaPlatform.tiktok:
        return '分享你的創意視頻';
      case SocialMediaPlatform.facebook:
        return '連接你的社交網絡';
      case SocialMediaPlatform.twitter:
        return '分享你的想法和觀點';
      case SocialMediaPlatform.linkedin:
        return '展示你的專業背景';
      case SocialMediaPlatform.youtube:
        return '分享你的視頻內容';
    }
  }

  String _getContentPreviewText(SocialMediaAccount account) {
    switch (account.platform) {
      case SocialMediaPlatform.instagram:
        final postsCount = account.metadata?['postsCount'] ?? 0;
        return '$postsCount 個帖子';
      case SocialMediaPlatform.spotify:
        final playlistsCount = account.metadata?['playlistsCount'] ?? 0;
        return '$playlistsCount 個播放列表';
      case SocialMediaPlatform.tiktok:
        final videosCount = account.metadata?['videosCount'] ?? 0;
        return '$videosCount 個視頻';
      default:
        return '查看內容';
    }
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return '從未同步';
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  void _connectPlatform(BuildContext context, WidgetRef ref, SocialMediaPlatform platform) async {
    // 顯示連接中狀態
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在連接 ${_getPlatformName(platform)}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    SocialMediaAccount? account;
    
    switch (platform) {
      case SocialMediaPlatform.instagram:
        account = await SocialMediaService.connectInstagram();
        break;
      case SocialMediaPlatform.spotify:
        account = await SocialMediaService.connectSpotify();
        break;
      case SocialMediaPlatform.tiktok:
        account = await SocialMediaService.connectTikTok();
        break;
      default:
        break;
    }

    if (account != null) {
      ref.read(socialMediaAccountsProvider.notifier).addAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功連接 ${account.platformName}！'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 載入內容
      _loadPlatformContent(ref, platform);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('連接 ${_getPlatformName(platform)} 失敗'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadPlatformContent(WidgetRef ref, SocialMediaPlatform platform) async {
    switch (platform) {
      case SocialMediaPlatform.instagram:
        final content = await SocialMediaService.getInstagramContent();
        ref.read(instagramContentProvider.notifier).loadContent(content);
        break;
      case SocialMediaPlatform.spotify:
        final content = await SocialMediaService.getSpotifyContent();
        ref.read(spotifyContentProvider.notifier).loadContent(content);
        break;
      case SocialMediaPlatform.tiktok:
        final content = await SocialMediaService.getTikTokContent();
        ref.read(tiktokContentProvider.notifier).loadContent(content);
        break;
      default:
        break;
    }
  }

  void _handleAccountAction(BuildContext context, WidgetRef ref, SocialMediaAccount account, String action) async {
    switch (action) {
      case 'sync':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('正在同步 ${account.platformName} 內容...')),
        );
        _loadPlatformContent(ref, account.platform);
        break;
      case 'settings':
        _showAccountSettings(context, ref, account);
        break;
      case 'disconnect':
        _disconnectAccount(context, ref, account);
        break;
    }
  }

  void _disconnectAccount(BuildContext context, WidgetRef ref, SocialMediaAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('斷開 ${account.platformName}'),
        content: const Text('確定要斷開此帳戶的連接嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SocialMediaService.disconnectAccount(account.platform);
      if (success) {
        ref.read(socialMediaAccountsProvider.notifier).removeAccount(account.platform);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已斷開 ${account.platformName} 連接'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showAccountDetails(BuildContext context, WidgetRef ref, SocialMediaAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocialMediaAccountDetailsPage(account: account),
      ),
    );
  }

  void _showAccountSettings(BuildContext context, WidgetRef ref, SocialMediaAccount account) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SocialMediaAccountSettingsSheet(account: account),
    );
  }

  void _showContentDetails(BuildContext context, WidgetRef ref, SocialMediaAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocialMediaContentPage(account: account),
      ),
    );
  }

  String _getPlatformName(SocialMediaPlatform platform) {
    switch (platform) {
      case SocialMediaPlatform.instagram:
        return 'Instagram';
      case SocialMediaPlatform.spotify:
        return 'Spotify';
      case SocialMediaPlatform.tiktok:
        return 'TikTok';
      case SocialMediaPlatform.facebook:
        return 'Facebook';
      case SocialMediaPlatform.twitter:
        return 'Twitter';
      case SocialMediaPlatform.linkedin:
        return 'LinkedIn';
      case SocialMediaPlatform.youtube:
        return 'YouTube';
    }
  }
}

// 社交媒體帳戶詳情頁面
class SocialMediaAccountDetailsPage extends ConsumerWidget {
  final SocialMediaAccount account;

  const SocialMediaAccountDetailsPage({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(account.platformName),
        backgroundColor: account.platformColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildAccountHeader(),
          _buildAccountStats(),
          _buildAccountSettings(context, ref),
        ],
      ),
    );
  }

  Widget _buildAccountHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: account.platformColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: account.profileImageUrl != null
                ? Center(
                    child: Text(
                      account.profileImageUrl!,
                      style: const TextStyle(fontSize: 40),
                    ),
                  )
                : Icon(
                    account.platformIcon,
                    color: Colors.white,
                    size: 40,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            account.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${account.username}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          if (account.isVerified) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '已驗證',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountStats() {
    if (account.metadata == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '帳戶統計',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = <String, dynamic>{};
    
    switch (account.platform) {
      case SocialMediaPlatform.instagram:
        stats['粉絲'] = account.metadata?['followersCount'] ?? 0;
        stats['關注'] = account.metadata?['followingCount'] ?? 0;
        stats['帖子'] = account.metadata?['postsCount'] ?? 0;
        break;
      case SocialMediaPlatform.spotify:
        stats['播放列表'] = account.metadata?['playlistsCount'] ?? 0;
        stats['粉絲'] = account.metadata?['followersCount'] ?? 0;
        break;
      case SocialMediaPlatform.tiktok:
        stats['粉絲'] = account.metadata?['followersCount'] ?? 0;
        stats['關注'] = account.metadata?['followingCount'] ?? 0;
        stats['視頻'] = account.metadata?['videosCount'] ?? 0;
        stats['讚'] = account.metadata?['likesCount'] ?? 0;
        break;
      default:
        break;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final entry = stats.entries.elementAt(index);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: account.platformColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: account.platformColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '設置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.sync, color: account.platformColor),
            title: const Text('同步內容'),
            subtitle: Text('最後同步：${_formatLastSync(account.lastSyncAt)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _syncContent(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.visibility, color: account.platformColor),
            title: const Text('隱私設置'),
            subtitle: Text(account.isPublic ? '公開顯示' : '僅自己可見'),
            trailing: Switch(
              value: account.isPublic,
              onChanged: (value) => _togglePrivacy(context, ref, value),
              activeColor: account.platformColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.link_off, color: Colors.red),
            title: const Text('斷開連接'),
            subtitle: const Text('移除此帳戶的連接'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _disconnectAccount(context, ref),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return '從未同步';
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小時前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  void _syncContent(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在同步 ${account.platformName} 內容...')),
    );
    
    // 更新最後同步時間
    final updatedAccount = account.copyWith(lastSyncAt: DateTime.now());
    ref.read(socialMediaAccountsProvider.notifier).updateAccount(updatedAccount);
  }

  void _togglePrivacy(BuildContext context, WidgetRef ref, bool isPublic) {
    final updatedAccount = account.copyWith(isPublic: isPublic);
    ref.read(socialMediaAccountsProvider.notifier).updateAccount(updatedAccount);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPublic ? '已設為公開顯示' : '已設為僅自己可見'),
      ),
    );
  }

  void _disconnectAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('斷開 ${account.platformName}'),
        content: const Text('確定要斷開此帳戶的連接嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SocialMediaService.disconnectAccount(account.platform);
      if (success) {
        ref.read(socialMediaAccountsProvider.notifier).removeAccount(account.platform);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已斷開 ${account.platformName} 連接'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// 社交媒體內容頁面
class SocialMediaContentPage extends ConsumerWidget {
  final SocialMediaAccount account;

  const SocialMediaContentPage({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${account.platformName} 內容'),
        backgroundColor: account.platformColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildContentList(context, ref),
    );
  }

  Widget _buildContentList(BuildContext context, WidgetRef ref) {
    switch (account.platform) {
      case SocialMediaPlatform.instagram:
        return _buildInstagramContent(context, ref);
      case SocialMediaPlatform.spotify:
        return _buildSpotifyContent(context, ref);
      case SocialMediaPlatform.tiktok:
        return _buildTikTokContent(context, ref);
      default:
        return const Center(
          child: Text('暫不支持此平台的內容顯示'),
        );
    }
  }

  Widget _buildInstagramContent(BuildContext context, WidgetRef ref) {
    final content = ref.watch(instagramContentProvider);
    
    if (content.isEmpty) {
      return const Center(
        child: Text('暫無 Instagram 內容'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final post = content[index];
        return _buildInstagramPostCard(post);
      },
    );
  }

  Widget _buildInstagramPostCard(InstagramContent post) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  post.mediaUrl,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.caption != null)
                  Text(
                    post.caption!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.comment, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentsCount}',
                      style: const TextStyle(fontSize: 12),
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

  Widget _buildSpotifyContent(BuildContext context, WidgetRef ref) {
    final content = ref.watch(spotifyContentProvider);
    
    if (content.isEmpty) {
      return const Center(
        child: Text('暫無 Spotify 內容'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final track = content[index];
        return _buildSpotifyTrackCard(track);
      },
    );
  }

  Widget _buildSpotifyTrackCard(SpotifyContent track) {
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
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                track.albumImageUrl ?? '🎵',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  track.artist,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (track.albumName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    track.albumName!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (track.isPlaying)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTikTokContent(BuildContext context, WidgetRef ref) {
    final content = ref.watch(tiktokContentProvider);
    
    if (content.isEmpty) {
      return const Center(
        child: Text('暫無 TikTok 內容'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final video = content[index];
        return _buildTikTokVideoCard(video);
      },
    );
  }

  Widget _buildTikTokVideoCard(TikTokContent video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    video.thumbnailUrl ?? '🎬',
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (video.description != null)
                  Text(
                    video.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${video.viewsCount}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${video.likesCount}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.share, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${video.sharesCount}',
                      style: const TextStyle(fontSize: 12),
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
}

// 社交媒體帳戶設置表單
class SocialMediaAccountSettingsSheet extends StatelessWidget {
  final SocialMediaAccount account;

  const SocialMediaAccountSettingsSheet({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${account.platformName} 設置',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.sync, color: account.platformColor),
            title: const Text('同步內容'),
            subtitle: const Text('更新最新內容'),
            onTap: () {
              Navigator.pop(context);
              // 執行同步
            },
          ),
          ListTile(
            leading: Icon(Icons.visibility, color: account.platformColor),
            title: const Text('隱私設置'),
            subtitle: const Text('控制內容可見性'),
            onTap: () {
              Navigator.pop(context);
              // 打開隱私設置
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: account.platformColor),
            title: const Text('通知設置'),
            subtitle: const Text('管理相關通知'),
            onTap: () {
              Navigator.pop(context);
              // 打開通知設置
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
} 