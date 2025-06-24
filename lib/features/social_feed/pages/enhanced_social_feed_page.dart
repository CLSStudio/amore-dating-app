import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/interaction_models.dart';
import '../services/safe_interaction_service.dart';
import '../widgets/chat_invitation_widgets.dart';
import '../pages/chat_invitations_page.dart';

class EnhancedSocialFeedPage extends StatefulWidget {
  const EnhancedSocialFeedPage({Key? key}) : super(key: key);

  @override
  _EnhancedSocialFeedPageState createState() => _EnhancedSocialFeedPageState();
}

class _EnhancedSocialFeedPageState extends State<EnhancedSocialFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  String? _currentUserId;
  String _currentUserName = '當前用戶';
  String _currentUserAvatar = 'https://picsum.photos/150/150?random=1';
  List<FeedPost> _posts = [];
  List<ChatInvitation> _pendingInvitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_user_id';
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 載入邀請
      final service = SafeInteractionService();
      final invitations = await service.getChatInvitations(_currentUserId!);
      
      setState(() {
        _pendingInvitations = invitations;
        _posts = _generateDemoPosts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<FeedPost> _generateDemoPosts() {
    return [
      FeedPost(
        id: '1',
        userId: 'user1',
        userName: '小美',
        userAvatar: 'https://picsum.photos/150/150?random=2',
        content: '今天去了很棒的咖啡廳，環境超讚！有沒有人想一起去喝咖啡的？ ☕️\n\n這裡的拿鐵真的是我喝過最香濃的，坐在窗邊看著街景，整個人都放鬆了～ 想找個人一起分享這種美好時光',
        imageUrls: [
          'https://picsum.photos/600/400?random=10',
        ],
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        likeCount: 24,
        commentCount: 8,
        shareCount: 3,
        isLiked: false,
        location: '台北市大安區',
        tags: ['咖啡', '約會', '放鬆'],
        isVerified: false,
      ),
      FeedPost(
        id: '2',
        userId: 'user2',
        userName: '阿明',
        userAvatar: 'https://picsum.photos/150/150?random=3',
        content: '週末爬山活動！歡迎喜歡戶外運動的朋友一起來～\n\n預計早上7點出發，下午4點回到市區。會經過幾個很棒的拍照點，記得帶相機！有興趣的朋友可以私訊我詳細資訊',
        imageUrls: [],
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        likeCount: 31,
        commentCount: 12,
        shareCount: 6,
        isLiked: true,
        location: '陽明山國家公園',
        tags: ['戶外', '運動', '健康'],
        isVerified: false,
      ),
      FeedPost(
        id: '3',
        userId: 'user3',
        userName: '小花',
        userAvatar: 'https://picsum.photos/150/150?random=4',
        content: '分享一首最近很喜歡的歌，心情瞬間變好了 🎵\n\n音樂真的有治癒人心的力量，有沒有人也喜歡這種風格的？可以互相推薦好聽的歌曲～',
        imageUrls: [],
        timestamp: DateTime.now().subtract(Duration(hours: 8)),
        likeCount: 42,
        commentCount: 15,
        shareCount: 8,
        isLiked: false,
        location: '台北小巨蛋',
        tags: ['音樂', '分享', '心情'],
        isVerified: false,
      ),
      FeedPost(
        id: '4',
        userId: 'user4',
        userName: '小王',
        userAvatar: 'https://picsum.photos/150/150?random=5',
        content: '週末畫畫時光 🎨 最近在學水彩，雖然還不太熟練，但享受這個過程～\n\n藝術真的能讓人沉靜下來，有興趣一起畫畫的朋友歡迎聊聊！',
        imageUrls: [
          'https://picsum.photos/600/400?random=13'
        ],
        timestamp: DateTime.now().subtract(Duration(hours: 12)),
        likeCount: 18,
        commentCount: 6,
        shareCount: 2,
        isLiked: false,
        location: '藝術工作室',
        tags: ['藝術', '繪畫', '創作'],
        isVerified: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink.shade50,
                        Colors.purple.shade50,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      'Amore',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Spacer(),
                    // 邀請通知圖示
                    if (_pendingInvitations.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Badge(
                          label: Text('${_pendingInvitations.length}'),
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: Icon(Icons.favorite_border, 
                                     color: Colors.pink.shade400, size: 24),
                            onPressed: _showInvitationsPage,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.favorite_border, 
                                 color: Colors.grey.shade600, size: 24),
                        onPressed: _showInvitationsPage,
                      ),
                    IconButton(
                      icon: Icon(Icons.send_outlined, 
                               color: Colors.grey.shade600, size: 24),
                      onPressed: _showDirectMessages,
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // 邀請通知橫幅
            if (_pendingInvitations.isNotEmpty) _buildInvitationBanner(),
            
            // Tab Bar (簡化)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.pink.shade400,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.pink.shade400,
                indicatorWeight: 2,
                labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: '動態'),
                  Tab(text: '探索'),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedContent(),
                  _buildExplorePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCreatePostFAB(),
    );
  }

  Widget _buildInvitationBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.favorite, color: Colors.pink.shade600, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '您有 ${_pendingInvitations.length} 個聊天邀請',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '點擊查看並回應邀請',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, 
                     color: Colors.pink.shade400, size: 16),
            onPressed: _showInvitationsPage,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.pink.shade400),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.pink.shade400,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildThreadsStylePost(_posts[index]);
        },
      ),
    );
  }

  Widget _buildExplorePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, color: Colors.grey.shade400, size: 64),
          SizedBox(height: 16),
          Text(
            '探索新朋友',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '發現有趣的人和內容',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadsStylePost(FeedPost post) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用戶資訊頭部 (Threads 風格)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showUserProfile(post.userId),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(post.userAvatar),
                  radius: 16, // 較小的頭像，符合Threads風格
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用戶名和時間
                    Row(
                      children: [
                        Text(
                          post.userName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        if (post.isVerified) ...[
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                        SizedBox(width: 8),
                        Text(
                          _formatDateTime(post.timestamp),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    if (post.location != null) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, 
                               size: 12, color: Colors.grey.shade500),
                          SizedBox(width: 2),
                          Text(
                            post.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    SizedBox(height: 8),
                    
                    // 貼文內容 (重點突出)
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),

                    // 標籤
                    if (post.tags.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: post.tags.map((tag) => GestureDetector(
                          onTap: () => _searchTag(tag),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],

                    // 圖片 (如果有)
                    if (post.imageUrls.isNotEmpty) ...[
                      SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          post.imageUrls.first,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    SizedBox(height: 12),

                    // 互動按鈕 (Threads 簡潔風格)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLike(post),
                          child: Row(
                            children: [
                              Icon(
                                post.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: post.isLiked ? Colors.red : Colors.grey.shade600,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${post.likeCount}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _showComments(post),
                          child: Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, 
                                   color: Colors.grey.shade600, size: 20),
                              SizedBox(width: 4),
                              Text(
                                '${post.commentCount}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _sharePost(post),
                          child: Icon(Icons.share_outlined, 
                               color: Colors.grey.shade600, size: 20),
                        ),
                        Spacer(),
                        // Amore 特色：聊天邀請按鈕
                        if (post.userId != _currentUserId)
                          GestureDetector(
                            onTap: () => _showInviteDialog(post),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.pink.shade400, Colors.purple.shade400],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '聊天',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // 更多選項
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: Colors.grey.shade500, size: 20),
                onSelected: (value) => _handlePostMenuAction(value, post),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report_outlined, color: Colors.grey.shade700),
                        SizedBox(width: 8),
                        Text('舉報'),
                      ],
                    ),
                  ),
                  if (post.userId == _currentUserId)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outlined, color: Colors.red),
                          SizedBox(width: 8),
                          Text('刪除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          // 分隔線
          Container(
            margin: EdgeInsets.only(top: 16),
            height: 0.5,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: FloatingActionButton(
        onPressed: _showCreatePost,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.edit, color: Colors.white, size: 24),
      ),
    );
  }

  // ================== 事件處理 ==================

  void _showInviteDialog(FeedPost post) {
    showDialog(
      context: context,
      builder: (context) => ChatInviteDialog(
        currentUserId: _currentUserId!,
        currentUserName: _currentUserName,
        currentUserAvatar: _currentUserAvatar,
        targetUserId: post.userId,
        relatedPostId: post.id,
        onInviteSent: () {
          _loadData();
        },
      ),
    );
  }

  void _showUserProfile(String userId) {
    // TODO: 實現用戶個人檔案頁面
    print('查看用戶個人檔案: $userId');
  }

  void _showInvitationsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatInvitationsPage(
          currentUserId: _currentUserId!,
        ),
      ),
    ).then((_) {
      _loadData();
    });
  }

  void _showDirectMessages() {
    // TODO: 實現私訊頁面
    print('顯示私訊');
  }

  void _handlePostMenuAction(String action, FeedPost post) {
    switch (action) {
      case 'report':
        _reportPost(post);
        break;
      case 'delete':
        _deletePost(post);
        break;
    }
  }

  void _reportPost(FeedPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('舉報貼文'),
        content: Text('確定要舉報這則貼文嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('已舉報此貼文');
            },
            child: Text('確定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePost(FeedPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('刪除貼文'),
        content: Text('確定要刪除這則貼文嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _posts.removeWhere((p) => p.id == post.id);
              });
              _showSuccessMessage('貼文已刪除');
            },
            child: Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _searchTag(String tag) {
    // TODO: 實現標籤搜尋
    print('搜尋標籤: #$tag');
  }

  Future<void> _toggleLike(FeedPost post) async {
    // 立即更新UI，提供即時反饋
    setState(() {
      post.isLiked = !post.isLiked;
      post.likeCount += post.isLiked ? 1 : -1;
    });

    try {
      final service = SafeInteractionService();
      
      if (post.isLiked) {
        await service.sendLike(
          fromUserId: _currentUserId!,
          fromUserName: _currentUserName,
          fromUserAvatar: _currentUserAvatar,
          toUserId: post.userId,
          postId: post.id,
        );
      } else {
        await service.removeLike(
          fromUserId: _currentUserId!,
          postId: post.id,
        );
      }
    } catch (e) {
      // 如果操作失敗，回復原狀態
      setState(() {
        post.isLiked = !post.isLiked;
        post.likeCount += post.isLiked ? 1 : -1;
      });
      _showErrorMessage('操作失敗，請稍後再試');
    }
  }

  void _showComments(FeedPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 頭部
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Text(
                    '留言',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 留言列表
            Expanded(
              child: Center(
                child: Text(
                  '尚無留言\n成為第一個留言的人！',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // 輸入框
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_currentUserAvatar),
                    radius: 16,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '留言...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 實現發送留言
                    },
                    child: Text(
                      '發布',
                      style: TextStyle(
                        color: Colors.pink.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(FeedPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '分享到',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.copy, '複製連結'),
                _buildShareOption(Icons.share, '系統分享'),
                _buildShareOption(Icons.bookmark, '儲存貼文'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showSuccessMessage('已$label');
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey.shade700, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消', style: TextStyle(color: Colors.grey.shade600)),
                ),
                Spacer(),
                Text(
                  '新貼文',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('貼文發布成功！');
                  },
                  child: Text(
                    '分享',
                    style: TextStyle(
                      color: Colors.pink.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(_currentUserAvatar),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '分享您的想法...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16),
                    maxLines: null,
                    autofocus: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }
}

// ================== 資料模型 ==================

class FeedPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> imageUrls;
  final DateTime timestamp;
  int likeCount;
  final int commentCount;
  final int shareCount;
  bool isLiked;
  final String? location;
  final List<String> tags;
  final bool isVerified;

  FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.imageUrls,
    required this.timestamp,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
    this.location,
    required this.tags,
    required this.isVerified,
  });
} 