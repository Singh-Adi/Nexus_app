import 'package:flutter/material.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/screens/profile/profile_screen.dart';
import 'package:nexus_mobile/utils/date_formatter.dart';
import 'package:nexus_mobile/widgets/tweet_content.dart';
import 'package:nexus_mobile/widgets/tweet_actions.dart';
import 'package:nexus_mobile/widgets/user_avatar.dart';

class TweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onRetweet;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final User? currentUser;
  
  const TweetCard({
    Key? key,
    required this.tweet,
    required this.onTap,
    required this.onLike,
    required this.onRetweet,
    required this.onComment,
    required this.onShare,
    this.currentUser,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tweet header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            username: tweet.user.username,
                          ),
                        ),
                      );
                    },
                    child: UserAvatar(
                      imageUrl: tweet.user.profile?.profileImageUrl,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tweet.user.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '@${tweet.user.username}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormatter.getTimeAgo(tweet.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (tweet.parentTweet != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Replying to @${tweet.parentTweet!.user.username}',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Tweet content
              TweetContent(tweet: tweet),
              
              const SizedBox(height: 8),
              
              // Tweet actions
              TweetActions(
                tweet: tweet,
                onLike: onLike,
                onRetweet: onRetweet,
                onComment: onComment,
                onShare: onShare,
                currentUser: currentUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}