import 'dart:async';
import 'dart:math';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/models/notification.dart';
import 'package:nexus_mobile/models/topic.dart';

/// A mock service class that simulates backend responses
/// without actually connecting to a server
class MockService {
  // Simulated delay to mimic network requests
  final Duration _delay = const Duration(milliseconds: 800);
  
  // Mock user data
  final User _currentUser = User(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    emailVerified: true,
    profile: UserProfile(
      id: 1,
      bio: 'This is a test user profile',
      profileImageUrl: 'https://via.placeholder.com/150',
      coverPhotoUrl: 'https://via.placeholder.com/500x200',
      engagementScore: 85.5,
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      followersCount: 120,
      followingCount: 75,
      isFollowing: false,
      user: null, // Will be set after initialization
    ),
  );
  
  // List of mock tweets
  final List<Tweet> _tweets = [];
  
  // List of mock users
  final List<UserProfile> _users = [];
  
  // List of mock notifications
  final List<Notification> _notifications = [];
  
  // List of mock trending topics
  final List<TweetTopic> _trendingTopics = [];
  
  // Random generator for IDs
  final Random _random = Random();
  
  // Constructor to initialize mock data
  MockService() {
    _initMockData();
  }
  
  void _initMockData() {
    // Set user reference in profile
    _currentUser.profile?.user = _currentUser;
    
    // Create mock users
    _users.addAll([
      UserProfile(
        id: 2,
        bio: 'Software developer and tech enthusiast',
        profileImageUrl: 'https://via.placeholder.com/150',
        coverPhotoUrl: 'https://via.placeholder.com/500x200',
        engagementScore: 92.3,
        lastActive: DateTime.now().subtract(const Duration(minutes: 45)),
        followersCount: 450,
        followingCount: 230,
        isFollowing: true,
        user: User(
          id: 2,
          username: 'johndoe',
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          emailVerified: true,
          profile: null,
        ),
      ),
      UserProfile(
        id: 3,
        bio: 'Digital nomad | Travel photographer',
        profileImageUrl: 'https://via.placeholder.com/150',
        coverPhotoUrl: 'https://via.placeholder.com/500x200',
        engagementScore: 78.9,
        lastActive: DateTime.now().subtract(const Duration(hours: 3)),
        followersCount: 1240,
        followingCount: 350,
        isFollowing: false,
        user: User(
          id: 3,
          username: 'sarahsmith',
          email: 'sarah@example.com',
          firstName: 'Sarah',
          lastName: 'Smith',
          emailVerified: true,
          profile: null,
        ),
      ),
      UserProfile(
        id: 4,
        bio: 'UI/UX Designer, coffee lover',
        profileImageUrl: 'https://via.placeholder.com/150',
        coverPhotoUrl: 'https://via.placeholder.com/500x200',
        engagementScore: 88.1,
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
        followersCount: 820,
        followingCount: 410,
        isFollowing: true,
        user: User(
          id: 4,
          username: 'mikedesign',
          email: 'mike@example.com',
          firstName: 'Mike',
          lastName: 'Johnson',
          emailVerified: true,
          profile: null,
        ),
      ),
    ]);
    
    // Set self-references
    for (var profile in _users) {
      if (profile.user != null) {
        profile.user!.profile = profile;
      }
    }
    
    // Create mock trending topics
    _trendingTopics.addAll([
      TweetTopic(id: 1, name: 'Flutter', tweetCount: 1250),
      TweetTopic(id: 2, name: 'Programming', tweetCount: 980),
      TweetTopic(id: 3, name: 'Technology', tweetCount: 1530),
      TweetTopic(id: 4, name: 'Mobile', tweetCount: 750),
      TweetTopic(id: 5, name: 'AI', tweetCount: 2100),
    ]);
    
    // Create mock tweets
    _tweets.addAll([
      Tweet(
        id: 1,
        user: _users[0].user!,
        content: 'Just deployed my first Flutter app to the Play Store! #Flutter #Mobile',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        retweetsCount: 5,
        replyCount: 3,
        isLiked: true,
        topics: ['Flutter', 'Mobile'],
      ),
      Tweet(
        id: 2,
        user: _users[1].user!,
        content: 'Working on a new design system for our app. Excited to share the results soon! #Design #UI',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        mediaUrl: 'https://via.placeholder.com/400x300',
        likesCount: 56,
        retweetsCount: 12,
        replyCount: 8,
        isLiked: false,
        topics: ['Design', 'UI'],
      ),
      Tweet(
        id: 3,
        user: _currentUser,
        content: 'Learning about state management in Flutter. Provider pattern is pretty neat! #Flutter #Programming',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 18,
        retweetsCount: 3,
        replyCount: 2,
        isLiked: false,
        topics: ['Flutter', 'Programming'],
      ),
    ]);
    
    // Create comments for tweets
    final comments = [
      Tweet(
        id: 4,
        user: _users[1].user!,
        content: 'Congratulations! What kind of app did you build?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        parentTweet: _tweets[0],
        likesCount: 3,
        retweetsCount: 0,
        replyCount: 1,
        isLiked: false,
      ),
      Tweet(
        id: 5,
        user: _users[0].user!,
        content: 'Thanks! It\'s a productivity app for tracking daily tasks.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        parentTweet: _tweets[0],
        likesCount: 2,
        retweetsCount: 0,
        replyCount: 0,
        isLiked: true,
      ),
      Tweet(
        id: 6,
        user: _users[2].user!,
        content: 'I\'ve been using Provider too. Have you tried Riverpod?',
        createdAt: DateTime.now().subtract(const Duration(hours: 22)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 22)),
        parentTweet: _tweets[2],
        likesCount: 4,
        retweetsCount: 0,
        replyCount: 1,
        isLiked: false,
      ),
    ];
    
    // Add comments to tweets
    _tweets.addAll(comments);
    
    // Add comments to their parent tweets
    for (var tweet in _tweets) {
      if (tweet.parentTweet != null) {
        final parentIndex = _tweets.indexWhere((t) => t.id == tweet.parentTweet!.id);
        if (parentIndex >= 0) {
          final parent = _tweets[parentIndex];
          parent.replyCount += 1;
        }
      }
    }
    
    // Create mock notifications
    _notifications.addAll([
      Notification(
        id: 1,
        message: '${_users[0].user!.username} liked your tweet',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        read: false,
        targetTweet: _tweets[2],
      ),
      Notification(
        id: 2,
        message: '${_users[1].user!.username} retweeted your post',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        read: true,
        targetTweet: _tweets[2],
      ),
      Notification(
        id: 3,
        message: '${_users[2].user!.username} followed you',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        read: false,
      ),
    ]);
  }
  
  // AUTH METHODS
  
  Future<User> login(String username, String password) async {
    await Future.delayed(_delay);
    
    // Simulate validation
    if (username.toLowerCase() != 'testuser' || password != 'password123') {
      throw Exception('Invalid username or password');
    }
    
    return _currentUser;
  }
  
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phoneNumber,
  }) async {
    await Future.delayed(_delay);
    
    // Simulate validation
    if (password != passwordConfirm) {
      throw Exception('Passwords do not match');
    }
    
    if (username.toLowerCase() == 'testuser') {
      throw Exception('Username already taken');
    }
    
    // Create a new user
    final newUser = User(
      id: 999,
      username: username,
      email: email,
      emailVerified: false,
      phoneNumber: phoneNumber,
      profile: UserProfile(
        id: 999,
        lastActive: DateTime.now(),
        user: null, // Will be set after initialization
      ),
    );
    
    // Set self-reference
    newUser.profile?.user = newUser;
    
    return newUser;
  }
  
  Future<bool> forgotPassword(String email) async {
    await Future.delayed(_delay);
    return true; // Always succeed in mock
  }
  
  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    await Future.delayed(_delay);
    
    if (newPassword != confirmPassword) {
      throw Exception('Passwords do not match');
    }
    
    return true;
  }
  
  // TWEET METHODS
  
  Future<List<Tweet>> getFeed({String feedType = 'for_you', int page = 1}) async {
    await Future.delayed(_delay);
    
    // Return tweets without comments
    return _tweets.where((tweet) => tweet.parentTweet == null).toList();
  }
  
  Future<Tweet> getTweetDetails(int tweetId) async {
    await Future.delayed(_delay);
    
    final tweet = _tweets.firstWhere(
      (tweet) => tweet.id == tweetId,
      orElse: () => throw Exception('Tweet not found'),
    );
    
    // Add comments to tweet
    final comments = _tweets.where((t) => t.parentTweet?.id == tweetId).toList();
    return Tweet(
      id: tweet.id,
      user: tweet.user,
      content: tweet.content,
      createdAt: tweet.createdAt,
      updatedAt: tweet.updatedAt,
      mediaUrl: tweet.mediaUrl,
      mediaFile: tweet.mediaFile,
      parentTweet: tweet.parentTweet,
      likesCount: tweet.likesCount,
      retweetsCount: tweet.retweetsCount,
      replyCount: tweet.replyCount,
      trendingScore: tweet.trendingScore,
      isFlagged: tweet.isFlagged,
      flaggedReason: tweet.flaggedReason,
      isTrending: tweet.isTrending,
      engagementScore: tweet.engagementScore,
      topics: tweet.topics,
      forwardsCount: tweet.forwardsCount,
      isLiked: tweet.isLiked,
      isRetweeted: tweet.isRetweeted,
      comments: comments,
    );
  }
  
  Future<Tweet> postTweet({required String content, String? mediaUrl}) async {
    await Future.delayed(_delay);
    
    final newTweet = Tweet(
      id: _random.nextInt(10000) + 1000,
      user: _currentUser,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      mediaUrl: mediaUrl,
      likesCount: 0,
      retweetsCount: 0,
      replyCount: 0,
      isLiked: false,
      isRetweeted: false,
      topics: [],
    );
    
    _tweets.insert(0, newTweet);
    return newTweet;
  }
  
  Future<Tweet> postComment(int tweetId, String content) async {
    await Future.delayed(_delay);
    
    final parentTweet = _tweets.firstWhere(
      (tweet) => tweet.id == tweetId,
      orElse: () => throw Exception('Tweet not found'),
    );
    
    final newComment = Tweet(
      id: _random.nextInt(10000) + 1000,
      user: _currentUser,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      parentTweet: parentTweet,
      likesCount: 0,
      retweetsCount: 0,
      replyCount: 0,
      isLiked: false,
      isRetweeted: false,
    );
    
    _tweets.insert(0, newComment);
    
    // Update parent tweet's reply count
    final parentIndex = _tweets.indexWhere((t) => t.id == tweetId);
    if (parentIndex >= 0) {
      _tweets[parentIndex].replyCount += 1;
    }
    
    return newComment;
  }
  
  Future<Map<String, dynamic>> likeTweet(int tweetId) async {
    await Future.delayed(_delay);
    
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex < 0) {
      throw Exception('Tweet not found');
    }
    
    final tweet = _tweets[tweetIndex];
    final isLiked = !tweet.isLiked;
    
    // Update like status and count
    tweet.isLiked = isLiked;
    if (isLiked) {
      tweet.likesCount += 1;
    } else {
      tweet.likesCount = tweet.likesCount > 0 ? tweet.likesCount - 1 : 0;
    }
    
    return {
      'liked': isLiked,
      'likes_count': tweet.likesCount,
    };
  }
  
  Future<Map<String, dynamic>> retweet(int tweetId, {String? comment}) async {
    await Future.delayed(_delay);
    
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex < 0) {
      throw Exception('Tweet not found');
    }
    
    final tweet = _tweets[tweetIndex];
    
    // Update retweet count
    tweet.retweetsCount += 1;
    tweet.isRetweeted = true;
    
    // If there's a comment, create a new tweet
    if (comment != null && comment.isNotEmpty) {
      final newRetweet = Tweet(
        id: _random.nextInt(10000) + 1000,
        user: _currentUser,
        content: comment,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentTweet: tweet,
        likesCount: 0,
        retweetsCount: 0,
        replyCount: 0,
        isLiked: false,
        isRetweeted: false,
      );
      
      _tweets.insert(0, newRetweet);
    }
    
    return {
      'success': true,
      'retweets_count': tweet.retweetsCount,
    };
  }
  
  Future<bool> deleteTweet(int tweetId) async {
    await Future.delayed(_delay);
    
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex < 0) {
      throw Exception('Tweet not found');
    }
    
    // Only allow deleting own tweets
    final tweet = _tweets[tweetIndex];
    if (tweet.user.id != _currentUser.id) {
      throw Exception('Cannot delete tweet from another user');
    }
    
    _tweets.removeAt(tweetIndex);
    return true;
  }
  
  // USER METHODS
  
  Future<UserProfile> getUserProfile(String username) async {
    await Future.delayed(_delay);
    
    if (username.toLowerCase() == _currentUser.username.toLowerCase()) {
      return _currentUser.profile!;
    }
    
    final profile = _users.firstWhere(
      (profile) => profile.user?.username.toLowerCase() == username.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );
    
    return profile;
  }
  
  Future<List<Tweet>> getUserTweets(String username) async {
    await Future.delayed(_delay);
    
    return _tweets.where((tweet) => 
      tweet.user.username.toLowerCase() == username.toLowerCase() && 
      tweet.parentTweet == null
    ).toList();
  }
  
  Future<bool> followUser(String username) async {
    await Future.delayed(_delay);
    
    final profileIndex = _users.indexWhere(
      (profile) => profile.user?.username.toLowerCase() == username.toLowerCase(),
    );
    
    if (profileIndex < 0) {
      throw Exception('User not found');
    }
    
    final profile = _users[profileIndex];
    if (!profile.isFollowing) {
      profile.isFollowing = true;
      profile.followersCount += 1;
      _currentUser.profile!.followingCount += 1;
    }
    
    return true;
  }
  
  Future<bool> unfollowUser(String username) async {
    await Future.delayed(_delay);
    
    final profileIndex = _users.indexWhere(
      (profile) => profile.user?.username.toLowerCase() == username.toLowerCase(),
    );
    
    if (profileIndex < 0) {
      throw Exception('User not found');
    }
    
    final profile = _users[profileIndex];
    if (profile.isFollowing) {
      profile.isFollowing = false;
      profile.followersCount -= 1;
      _currentUser.profile!.followingCount -= 1;
    }
    
    return true;
  }
  
  Future<List<UserProfile>> getFollowers(String username) async {
    await Future.delayed(_delay);
    
    // Mock followers - just return some of the mock users
    return _users.where((profile) => profile.isFollowing).toList();
  }
  
  Future<List<UserProfile>> getFollowing(String username) async {
    await Future.delayed(_delay);
    
    // Mock following - just return some of the mock users
    return _users.sublist(0, 2);
  }
  
  Future<List<UserProfile>> getSuggestedUsers() async {
    await Future.delayed(_delay);
    
    // Return users that current user is not following
    return _users.where((profile) => !profile.isFollowing).toList();
  }
  
  // NOTIFICATION METHODS
  
  Future<List<Notification>> getNotifications() async {
    await Future.delayed(_delay);
    return _notifications;
  }
  
  Future<bool> markAsRead(int notificationId) async {
    await Future.delayed(_delay);
    
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = Notification(
        id: _notifications[index].id,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        read: true,
        targetTweet: _notifications[index].targetTweet,
      );
    }
    
    return true;
  }
  
  Future<bool> markAllAsRead() async {
    await Future.delayed(_delay);
    
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = Notification(
        id: _notifications[i].id,
        message: _notifications[i].message,
        timestamp: _notifications[i].timestamp,
        read: true,
        targetTweet: _notifications[i].targetTweet,
      );
    }
    
    return true;
  }
  
  // TRENDING TOPICS
  
  Future<List<TweetTopic>> getTrendingTopics() async {
    await Future.delayed(_delay);
    return _trendingTopics;
  }
  
  Future<List<Tweet>> getTopicTweets(int topicId) async {
    await Future.delayed(_delay);
    
    final topic = _trendingTopics.firstWhere(
      (topic) => topic.id == topicId,
      orElse: () => throw Exception('Topic not found'),
    );
    
    // Return tweets that have this topic
    return _tweets.where((tweet) => 
      tweet.topics.contains(topic.name) && 
      tweet.parentTweet == null
    ).toList();
  }
}