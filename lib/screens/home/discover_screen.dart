import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/models/topic.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/providers/tweet_provider.dart';
import 'package:nexus_mobile/providers/user_provider.dart';
import 'package:nexus_mobile/screens/profile/profile_screen.dart';
import 'package:nexus_mobile/widgets/trending_topic_card.dart';
import 'package:nexus_mobile/widgets/user_card.dart';
import 'package:nexus_mobile/widgets/loading_indicator.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load trending topics and suggested users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    await Future.wait([
      tweetProvider.loadTrendingTopics(),
      userProvider.loadSuggestedUsers(),
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    final tweetProvider = Provider.of<TweetProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                style: const TextStyle(color: Colors.black),
                onSubmitted: _performSearch,
              )
            : const Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trending Topics
                const Text(
                  'Trending Topics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTrendingTopics(tweetProvider),
                
                const SizedBox(height: 24),
                
                // Suggested Users
                const Text(
                  'Who to Follow',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSuggestedUsers(userProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrendingTopics(TweetProvider tweetProvider) {
    if (tweetProvider.isLoading && tweetProvider.trendingTopics.isEmpty) {
      return const LoadingIndicator();
    }
    
    if (tweetProvider.trendingTopics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No trending topics available.'),
        ),
      );
    }
    
    return Column(
      children: tweetProvider.trendingTopics.map((topic) {
        return TrendingTopicCard(
          topic: topic,
          onTap: () {
            _navigateToTopicScreen(topic);
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildSuggestedUsers(UserProvider userProvider) {
    if (userProvider.isLoading && userProvider.suggestedUsers.isEmpty) {
      return const LoadingIndicator();
    }
    
    if (userProvider.suggestedUsers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No suggested users available.'),
        ),
      );
    }
    
    return Column(
      children: userProvider.suggestedUsers.map((userProfile) {
        return UserCard(
          profile: userProfile,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  username: userProfile.user!.username,
                ),
              ),
            );
          },
          onFollowTap: () async {
            if (userProfile.isFollowing) {
              await userProvider.unfollowUser(userProfile.user!.username);
            } else {
              await userProvider.followUser(userProfile.user!.username);
            }
          },
        );
      }).toList(),
    );
  }
  
  void _navigateToTopicScreen(TweetTopic topic) {
    // Navigate to a topic screen showing tweets for this topic
    // This would need to be implemented separately
  }
  
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    // Implement search functionality
    // This would need to be implemented separately
  }
}