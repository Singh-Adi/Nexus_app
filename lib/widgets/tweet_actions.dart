import 'package:flutter/material.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/models/user.dart';

class TweetActions extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onLike;
  final VoidCallback onRetweet;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final User? currentUser;
  
  const TweetActions({
    Key? key,
    required this.tweet,
    required this.onLike,
    required this.onRetweet,
    required this.onComment,
    required this.onShare,
    this.currentUser,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Comment button
        _buildActionButton(
          icon: Icons.comment_outlined,
          activeIcon: Icons.comment,
          count: tweet.replyCount,
          isActive: false,
          color: Colors.blue,
          onTap: onComment,
        ),
        
        // Retweet button
        _buildActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: tweet.retweetsCount,
          isActive: tweet.isRetweeted,
          color: Colors.green,
          onTap: onRetweet,
        ),
        
        // Like button
        _buildActionButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          count: tweet.likesCount,
          isActive: tweet.isLiked,
          color: Colors.red,
          onTap: onLike,
        ),
        
        // Share button
        _buildActionButton(
          icon: Icons.share,
          activeIcon: Icons.share,
          count: tweet.forwardsCount,
          isActive: false,
          color: Colors.blue,
          onTap: onShare,
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 16,
              color: isActive ? color : null,
            ),
            const SizedBox(width: 4),
            Text(
              count > 0 ? count.toString() : '',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}