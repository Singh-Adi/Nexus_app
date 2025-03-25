import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/providers/auth_provider.dart';
import 'package:nexus_mobile/providers/tweet_provider.dart';
import 'package:nexus_mobile/providers/user_provider.dart';
import 'package:nexus_mobile/screens/profile/edit_profile_screen.dart';
import 'package:nexus_mobile/screens/profile/followers_screen.dart';
import 'package:nexus_mobile/screens/profile/following_screen.dart';
import 'package:nexus_mobile/screens/tweet/tweet_detail_screen.dart';
import 'package:nexus_mobile/widgets/tweet_card.dart';
import 'package:nexus_mobile/widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final bool isCurrentUser;
  
  const ProfileScreen({
    Key? key,
    required this.username,
    this.isCurrentUser = false,
  }) : super(key: key);
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load user profile and tweets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
    
    await userProvider.loadUserProfile(widget.username);
    await tweetProvider.loadUserTweets(widget.username);
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final tweetProvider = Provider.of<TweetProvider>(context);
    final currentUser = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      body: userProvider.isLoading && userProvider.currentProfile == null
          ? const LoadingIndicator()
          : userProvider.currentProfile == null
              ? const Center(child: Text('User not found'))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 200.0,
                        floating: false,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildCoverPhoto(userProvider.currentProfile!),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildProfileHeader(
                          userProvider.currentProfile!,
                          currentUser,
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: 'Tweets'),
                              Tab(text: 'Replies'),
                              Tab(text: 'Media'),
                              Tab(text: 'Likes'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tweets Tab
                      _buildTweetsTab(tweetProvider, currentUser),
                      
                      // Replies Tab
                      const Center(child: Text('Replies')),
                      
                      // Media Tab
                      const Center(child: Text('Media')),
                      
                      // Likes Tab
                      const Center(child: Text('Likes')),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildCoverPhoto(UserProfile profile) {
    return profile.coverPhotoUrl != null
        ? Image.network(
            profile.coverPhotoUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          )
        : Container(
            color: Colors.blue[100],
            width: double.infinity,
            height: 200,
          );
  }
  
  Widget _buildProfileHeader(UserProfile profile, User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              CircleAvatar(
                radius: 40,
                backgroundImage: profile.profileImageUrl != null
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
                child: profile.profileImageUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              
              // Follow/Edit button
              _buildActionButton(profile, currentUser),
            ],
          ),
          const SizedBox(height: 16),
          
          // Username and display name
          Text(
            profile.user?.username ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${profile.user?.username ?? ''}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(profile.bio!),
          ],
          
          const SizedBox(height: 16),
          
          // Followers and following counts
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowingScreen(username: profile.user!.username),
                    ),
                  );
                },
                child: Text(
                  '${profile.followingCount} Following',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowersScreen(username: profile.user!.username),
                    ),
                  );
                },
                child: Text(
                  '${profile.followersCount} Followers',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(UserProfile profile, User? currentUser) {
    // If this is the current user's profile, show Edit Profile button
    if (widget.isCurrentUser || currentUser?.id == profile.user?.id) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Edit Profile'),
      );
    }
    
    // Otherwise, show Follow/Unfollow button
    final userProvider = Provider.of<UserProvider>(context);
    final isFollowing = profile.isFollowing;
    
    return ElevatedButton(
      onPressed: () async {
        if (isFollowing) {
          await userProvider.unfollowUser(profile.user!.username);
        } else {
          await userProvider.followUser(profile.user!.username);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.white : Theme.of(context).primaryColor,
        foregroundColor: isFollowing ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isFollowing
              ? BorderSide(color: Colors.grey[300]!)
              : BorderSide.none,
        ),
      ),
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
  
  Widget _buildTweetsTab(TweetProvider tweetProvider, User? currentUser) {
    if (tweetProvider.isLoading && tweetProvider.userTweets.isEmpty) {
      return const LoadingIndicator();
    }
    
    if (tweetProvider.userTweets.isEmpty) {
      return const Center(
        child: Text('No tweets yet'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: tweetProvider.userTweets.length,
        itemBuilder: (context, index) {
          final tweet = tweetProvider.userTweets[index];
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
            onRetweet: () {
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
            currentUser: currentUser,
          );
        },
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
}

// Custom delegate for the tab bar in the sliver app bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _SliverTabBarDelegate(this.tabBar);
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}