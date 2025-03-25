import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/providers/auth_provider.dart';
import 'package:nexus_mobile/providers/tweet_provider.dart';
import 'package:nexus_mobile/screens/tweet/tweet_detail_screen.dart';
import 'package:nexus_mobile/widgets/tweet_card.dart';
import 'package:nexus_mobile/widgets/loading_indicator.dart';

// Provider to access the state from outside this class
class FeedScreenState extends ChangeNotifier {
  void refreshFeed() {
    _refreshFeedCallback?.call();
  }
  
  Function? _refreshFeedCallback;
  
  void setRefreshCallback(Function callback) {
    _refreshFeedCallback = callback;
  }
}

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scrollController = ScrollController();
  final _feedScreenState = FeedScreenState();
  
  @override
  void initState() {
    super.initState();
    
    // Set the refresh callback
    _feedScreenState.setRefreshCallback(() {
      _refreshFeed();
    });
    
    // Load tweets when the feed screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTweets();
    });
    
    // Add scroll listener for infinite scroll
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreTweets();
    }
  }
  
  Future<void> _loadTweets() async {
    final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
    await tweetProvider.loadFeed(refresh: true);
  }
  
  Future<void> _loadMoreTweets() async {
    final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
    if (!tweetProvider.isLoading && tweetProvider.hasMore) {
      await tweetProvider.loadFeed();
    }
  }
  
  Future<void> _refreshFeed() async {
    await _loadTweets();
  }
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return ChangeNotifierProvider.value(
      value: _feedScreenState,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Feed'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshFeed,
            ),
          ],
        ),
        body: Consumer<TweetProvider>(
          builder: (context, tweetProvider, _) {
            if (tweetProvider.isLoading && tweetProvider.tweets.isEmpty) {
              return const LoadingIndicator();
            }
            
            if (tweetProvider.tweets.isEmpty) {
              return const Center(
                child: Text('No tweets available. Follow some users to see their tweets!'),
              );
            }
            
            return Column(
              children: [
                // Feed type switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'for_you',
                        label: Text('For You'),
                      ),
                      ButtonSegment<String>(
                        value: 'following',
                        label: Text('Following'),
                      ),
                    ],
                    selected: {tweetProvider.feedType},
                    onSelectionChanged: (Set<String> selection) {
                      tweetProvider.switchFeedType(selection.first);
                    },
                  ),
                ),
                
                // Tweet list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshFeed,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: tweetProvider.tweets.length + (tweetProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == tweetProvider.tweets.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final tweet = tweetProvider.tweets[index];
                        return TweetCard(
                          tweet: tweet,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TweetDetailScreen(tweetId: tweet.id),
                              ),
                            );
                          },
                          onLike: () async {
                            await tweetProvider.likeTweet(tweet.id);
                          },
                          onRetweet: () async {
                            // Show dialog with retweet options
                            _showRetweetDialog(tweet.id);
                          },
                          onComment: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TweetDetailScreen(
                                  tweetId: tweet.id,
                                  showCommentForm: true,
                                ),
                              ),
                            );
                          },
                          onShare: () async {
                            await tweetProvider.forwardTweet(tweet.id);
                          },
                          currentUser: user,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
                  Navigator.of(context).pop();
                  final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
                  await tweetProvider.retweet(tweetId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.comment),
                title: const Text('Quote Tweet'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to a quote tweet screen
                  // This would need to be implemented separately
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}