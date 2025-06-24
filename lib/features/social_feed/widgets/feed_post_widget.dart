import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/feed_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_border_radius.dart';

class FeedPostWidget extends StatelessWidget {
  final FeedPost post;
  final String currentUserId;
  final Function(String) onLike;
  final Function(String) onView;
  final Function(String) onUserTap;
  final bool showDeleteOption;
  final Function(String)? onDelete;

  const FeedPostWidget({
    Key? key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onView,
    required this.onUserTap,
    this.showDeleteOption = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 記錄瀏覽
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!post.isViewedBy(currentUserId)) {
        onView(post.id);
      }
    });

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (post.textContent != null) _buildTextContent(),
          if (post.mediaContent.isNotEmpty) _buildMediaContent(),
          if (post.tags.isNotEmpty) _buildTags(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onUserTap(post.userId),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: post.userAvatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(post.userAvatarUrl)
                  : null,
              child: post.userAvatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onUserTap(post.userId),
                  child: Text(
                    post.userDisplayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (post.location != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        post.location!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (showDeleteOption && post.userId == currentUserId)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete' && onDelete != null) {
                  onDelete!(post.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('刪除'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        post.textContent!,
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (post.mediaContent.length == 1) {
      return _buildSingleMedia(post.mediaContent.first);
    } else {
      return _buildMultipleMedia();
    }
  }

  Widget _buildSingleMedia(MediaContent media) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: AspectRatio(
          aspectRatio: media.aspectRatio ?? 1.0,
          child: media.type == MediaType.photo
              ? CachedNetworkImage(
                  imageUrl: media.url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error),
                  ),
                )
              : Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: media.thumbnailUrl ?? media.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMultipleMedia() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.mediaContent.length,
        itemBuilder: (context, index) {
          final media = post.mediaContent[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              child: media.type == MediaType.photo
                  ? CachedNetworkImage(
                      imageUrl: media.url,
                      fit: BoxFit.cover,
                    )
                  : Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: media.thumbnailUrl ?? media.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: post.tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              '#$tag',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    final isLiked = post.isLikedBy(currentUserId);
    
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onLike(post.id),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              Icon(
                Icons.visibility,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.viewCount}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPostTypeColor(post.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.type.icon,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  post.type.displayName,
                  style: TextStyle(
                    color: _getPostTypeColor(post.type),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分鐘前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小時前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.photo:
        return Colors.blue;
      case PostType.video:
        return Colors.purple;
      case PostType.text:
        return Colors.green;
      case PostType.mixed:
        return Colors.orange;
    }
  }
} 