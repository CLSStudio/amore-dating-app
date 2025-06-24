import 'package:flutter/material.dart';
import '../models/feed_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_border_radius.dart';

class TopicCardWidget extends StatelessWidget {
  final Topic topic;
  final Function(Topic) onTap;

  const TopicCardWidget({
    Key? key,
    required this.topic,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
      ),
      child: InkWell(
        onTap: () => onTap(topic),
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildDescription(),
              if (topic.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTags(),
              ],
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(topic.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topic.category.icon,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                topic.category.displayName,
                style: TextStyle(
                  color: _getCategoryColor(topic.category),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (topic.isFeatured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.white),
                SizedBox(width: 2),
                Text(
                  '精選',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      topic.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      topic.description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: topic.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppBorderRadius.xs),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            topic.creatorDisplayName.isNotEmpty 
                ? topic.creatorDisplayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.creatorDisplayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatTime(topic.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        _buildStatItem(Icons.people, '${topic.participantCount}'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.chat_bubble_outline, '${topic.postCount}'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 2),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(TopicCategory category) {
    switch (category) {
      case TopicCategory.general:
        return Colors.blue;
      case TopicCategory.dating:
        return Colors.pink;
      case TopicCategory.lifestyle:
        return Colors.green;
      case TopicCategory.hobbies:
        return Colors.orange;
      case TopicCategory.career:
        return Colors.indigo;
      case TopicCategory.travel:
        return Colors.teal;
      case TopicCategory.food:
        return Colors.amber;
      case TopicCategory.fitness:
        return Colors.red;
      case TopicCategory.entertainment:
        return Colors.purple;
      case TopicCategory.relationships:
        return Colors.pink.shade700;
      case TopicCategory.mbti:
        return Colors.cyan;
      case TopicCategory.hongkong:
        return Colors.deepOrange;
    }
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
} 