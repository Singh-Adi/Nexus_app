import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/providers/auth_provider.dart';
import 'package:nexus_mobile/providers/tweet_provider.dart';
import 'package:nexus_mobile/screens/profile/profile_screen.dart';
import 'package:nexus_mobile/screens/tweet/create_tweet_screen.dart';
import 'package:nexus_mobile/utils/date_formatter.dart';
import 'package:nexus_mobile/widgets/tweet_content.dart';
import 'package:nexus_mobile/widgets/tweet_actions.dart';
import 'package:nexus_mobile/widgets/user_avatar.dart';
import 'package:nexus_mobile/widgets/loading_indicator.dart';

class TweetDetailScreen extends StatefulWidget {
  final int tweetId;
  final bool showCommentForm;
  
  const TweetDetailScreen({
    Key? key,
    required this.tweetId,
    this.showCommentForm = false,
  }) : super(key: key);
  
  @override
  _TweetDetailScreenState createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends State<TweetDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  
  @override
  void initState() {
    super.initState();
    _loadTweetDetails();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTweetDetails() async {
    final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
    await tweetProvider.loadTweetDetails(widget.tweetId);
  }
  
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    try {
      final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
      await tweetProvider.postComment(
        widget.tweetId,
        _commentController.text.trim(),
      );
      
      // Clear the comment field and reload the tweet to show the new comment
      _commentController.clear();
      await _loadTweetDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: Consumer<TweetProvider>(
        builder: (context, tweetProvider, _) {
          if (tweetProvider.isLoading || tweetProvider.currentTweet == null) {
            return const LoadingIndicator();
          }
          
          final tweet = tweetProvider.currentTweet!;
          
          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTweetHeader(tweet),
                      const SizedBox(height: 12),
                      TweetContent(tweet: tweet),
                      const SizedBox(height: 16),
                      _buildTweetMeta(tweet),
                      const SizedBox(height: 8),
                      TweetActions(
                        tweet: tweet,
                        onLike: () async {
                          await tweetProvider.likeTweet(tweet.id);
                        },
                        onRetweet: () {
                          _showRetweetDialog(tweet.id);
                        },
                        onComment: () {
                          _showCommentSheet();
                        },
                        onShare: () async {
                          await tweetProvider.forwardTweet(tweet.id);
                        },
                        currentUser: currentUser,
                      ),
                      
                      if (tweet.replyCount > 0 || tweet.comments != null) ...[
                        const Divider(height: 32),
                        _buildCommentsList(tweet),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Comment input field at the bottom
              _buildCommentInput(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTweetHeader(Tweet tweet) {
    return GestureDetector(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: tweet.user.profile?.profileImageUrl,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tweet.user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${tweet.user.username}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Options menu (for the tweet author)
          if (tweet.user.id == Provider.of<AuthProvider>(context).user?.id)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(tweet.id);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildTweetMeta(Tweet tweet) {
    return Row(
      children: [
        Text(
          DateFormatter.getDateWithTime(tweet.createdAt),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${tweet.likesCount} Likes',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${tweet.retweetsCount} Retweets',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCommentsList(Tweet tweet) {
    // If the API returns comments embedded in the tweet object
    final comments = tweet.comments ?? [];
    
    if (comments.isEmpty) {
      return const Center(
        child: Text('No comments yet.'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${tweet.replyCount})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              leading: UserAvatar(
                imageUrl: comment.user.profile?.profileImageUrl,
                size: 36,
              ),
              title: Text(
                comment.user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(comment.content),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.getTimeAgo(comment.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TweetDetailScreen(tweetId: comment.id),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: Provider.of<AuthProvider>(context).user?.profile?.profileImageUrl,
            size: 36,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isSubmittingComment
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmittingComment ? null : _submitComment,
          ),
        ],
      ),
    );
  }
  
  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reply',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add your reply...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitComment();
                    },
                    child: const Text('Reply'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
  
  void _showRetweetDialog(int tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Retweet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Retweet'),
                onTap: () async {
                  Navigator.pop(context);
                  final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
                  await tweetProvider.retweet(tweetId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.comment),
                title: const Text('Quote Tweet'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to a quote tweet screen
                  // This would be implemented separately
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteConfirmation(int tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tweet'),
          content: const Text('Are you sure you want to delete this tweet? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
                final success = await tweetProvider.deleteTweet(tweetId);
                
                if (success && mounted) {
                  Navigator.pop(context); // Return to previous screen
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}