import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/models/topic.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/services/api_service.dart';

class TweetProvider with ChangeNotifier {
  final ApiService _apiService;
  final Random _random = Random();
  
  List<Tweet> _tweets = [];
  List<Tweet> _userTweets = [];
  List<TweetTopic> _trendingTopics = [];
  Tweet? _currentTweet;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _feedType = 'for_you';
  String? _error;
  
  TweetProvider(this._apiService) {
    _initializeMockData();
  }
  
  List<Tweet> get tweets => _tweets;
  List<Tweet> get userTweets => _userTweets;
  List<TweetTopic> get trendingTopics => _trendingTopics;
  Tweet? get currentTweet => _currentTweet;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get feedType => _feedType;
  String? get error => _error;
  
  void updateToken(String? token) {
    _apiService.setAuthToken(token);
  }
  
  void _initializeMockData() {
    // Create mock trending topics
    _trendingTopics = [
      TweetTopic(id: 1, name: 'Flutter', tweetCount: 1250),
      TweetTopic(id: 2, name: 'Programming', tweetCount: 980),
      TweetTopic(id: 3, name: 'Technology', tweetCount: 1530),
      TweetTopic(id: 4, name: 'Mobile', tweetCount: 750),
      TweetTopic(id: 5, name: 'AI', tweetCount: 2100),
    ];
    
    // Create mock user for tweets
    final john = User(
      id: 2,
      username: 'johndoe',
      email: 'john@example.com',
      firstName: 'John',
      lastName: 'Doe',
      emailVerified: true,
      profile: UserProfile(
        id: 2,
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
        bio: 'Software Developer',
        profileImageUrl: 'https://via.placeholder.com/150',
        coverPhotoUrl: 'https://via.placeholder.com/800x200',
        followersCount: 450,
        followingCount: 230,
      ),
    );
    
    final sarah = User(
      id: 3,
      username: 'sarahsmith',
      email: 'sarah@example.com',
      firstName: 'Sarah',
      lastName: 'Smith',
      emailVerified: true,
      profile: UserProfile(
        id: 3,
        lastActive: DateTime.now().subtract(const Duration(hours: 3)),
        bio: 'Digital Designer',
        profileImageUrl: 'https://via.placeholder.com/150',
        coverPhotoUrl: 'https://via.placeholder.com/800x200',
        followersCount: 1200,
        followingCount: 350,
      ),
    );
    
    // Create mock tweets
    _tweets = [
      Tweet(
        id: 1,
        user: john,
        content: 'Just deployed my first Flutter app to the Play Store! #Flutter #Mobile',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        retweetsCount: 5,
        replyCount: 3,
        topics: ['Flutter', 'Mobile'],
        isLiked: true,
      ),
      Tweet(
        id: 2,
        user: sarah,
        content: 'Working on a new design system for our app. Excited to share the results soon! #Design #UI',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        mediaUrl: 'https://via.placeholder.com/400x300',
        likesCount: 56,
        retweetsCount: 12,
        replyCount: 8,
        topics: ['Design', 'UI'],
        isLiked: false,
      ),
      Tweet(
        id: 3,
        user: john,
        content: 'Learning about state management in Flutter. Provider pattern is pretty neat! #Flutter #Programming',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 18,
        retweetsCount: 3,
        replyCount: 2,
        topics: ['Flutter', 'Programming'],
        isLiked: false,
      ),
    ];
    
    // Create some comments
    final comments = [
      Tweet(
        id: 4,
        user: sarah,
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
        user: john,
        content: 'Thanks! It\'s a productivity app for tracking daily tasks.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        parentTweet: _tweets[0],
        likesCount: 2,
        retweetsCount: 0,
        replyCount: 0,
        isLiked: true,
      ),
    ];
    
    // Add comments to tweets
    _tweets.addAll(comments);
  }
  
  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    
    if (_isLoading || (!_hasMore && !refresh)) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // We're using mock data, so just return filtered tweets
      final feedTweets = _tweets.where((tweet) => tweet.parentTweet == null).toList();
      
      if (refresh) {
        _tweets = feedTweets;
      } else {
        // In a real app, you'd add new tweets loaded from the next page
        // For mock, we'll just pretend there are no more tweets
        _hasMore = false;
      }
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void switchFeedType(String newFeedType) {
    if (_feedType != newFeedType) {
      _feedType = newFeedType;
      loadFeed(refresh: true);
    }
  }
  
  Future<void> loadTweetDetails(int tweetId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the tweet in our local data
      final tweet = _tweets.firstWhere(
        (t) => t.id == tweetId,
        orElse: () => throw Exception('Tweet not found'),
      );
      
      // Get all comments for this tweet
      final comments = _tweets.where((t) => t.parentTweet?.id == tweetId).toList();
      
      // Create a copy of the tweet with comments attached
      _currentTweet = Tweet(
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
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Tweet?> postTweet({required String content, File? mediaFile}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Create a new tweet with mock data
      final newTweet = Tweet(
        id: _tweets.length + 1000, // Ensure unique ID
        user: User(
          id: 1,
          username: 'testuser',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          emailVerified: true,
          profile: UserProfile(
            id: 1,
            lastActive: DateTime.now(),
            bio: 'Mock user for testing',
            profileImageUrl: 'https://via.placeholder.com/150',
            coverPhotoUrl: 'https://via.placeholder.com/800x200',
            followersCount: 120,
            followingCount: 85,
          ),
        ),
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        mediaUrl: mediaFile != null ? 'https://via.placeholder.com/400x300' : null,
        likesCount: 0,
        retweetsCount: 0,
        replyCount: 0,
        topics: _extractHashtags(content),
        isLiked: false,
        isRetweeted: false,
      );
      
      // Add to the beginning of the feed
      _tweets.insert(0, newTweet);
      
      return newTweet;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Tweet?> postComment(int tweetId, String content) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the parent tweet
      final parentTweet = _tweets.firstWhere(
        (t) => t.id == tweetId,
        orElse: () => throw Exception('Tweet not found'),
      );
      
      // Create a new comment
      final newComment = Tweet(
        id: _tweets.length + 1000, // Ensure unique ID
        user: User(
          id: 1,
          username: 'testuser',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          emailVerified: true,
          profile: UserProfile(
            id: 1,
            lastActive: DateTime.now(),
            bio: 'Mock user for testing',
            profileImageUrl: 'https://via.placeholder.com/150',
            coverPhotoUrl: 'https://via.placeholder.com/800x200',
            followersCount: 120,
            followingCount: 85,
          ),
        ),
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentTweet: parentTweet,
        likesCount: 0,
        retweetsCount: 0,
        replyCount: 0,
        isLiked: false,
      );
      
      // Add to tweets list
      _tweets.add(newComment);
      
      // Update parent tweet's reply count
      final parentIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (parentIndex >= 0) {
        _tweets[parentIndex].replyCount += 1;
      }
      
      // If we have the current tweet open, add this comment to its comments
      if (_currentTweet != null && _currentTweet!.id == tweetId) {
        final comments = _currentTweet!.comments ?? [];
        _currentTweet = Tweet(
          id: _currentTweet!.id,
          user: _currentTweet!.user,
          content: _currentTweet!.content,
          createdAt: _currentTweet!.createdAt,
          updatedAt: _currentTweet!.updatedAt,
          mediaUrl: _currentTweet!.mediaUrl,
          mediaFile: _currentTweet!.mediaFile,
          parentTweet: _currentTweet!.parentTweet,
          likesCount: _currentTweet!.likesCount,
          retweetsCount: _currentTweet!.retweetsCount,
          replyCount: _currentTweet!.replyCount + 1,
          trendingScore: _currentTweet!.trendingScore,
          isFlagged: _currentTweet!.isFlagged,
          flaggedReason: _currentTweet!.flaggedReason,
          isTrending: _currentTweet!.isTrending,
          engagementScore: _currentTweet!.engagementScore,
          topics: _currentTweet!.topics,
          forwardsCount: _currentTweet!.forwardsCount,
          isLiked: _currentTweet!.isLiked,
          isRetweeted: _currentTweet!.isRetweeted,
          comments: [...comments, newComment],
        );
      }
      
      return newComment;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> likeTweet(int tweetId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find the tweet in our list
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) {
        throw Exception('Tweet not found');
      }
      
      // Toggle like status
      final tweet = _tweets[tweetIndex];
      final isLiked = !tweet.isLiked;
      
      // Create a new tweet with updated like status
      _tweets[tweetIndex] = Tweet(
        id: tweet.id,
        user: tweet.user,
        content: tweet.content,
        createdAt: tweet.createdAt,
        updatedAt: tweet.updatedAt,
        mediaUrl: tweet.mediaUrl,
        mediaFile: tweet.mediaFile,
        parentTweet: tweet.parentTweet,
        likesCount: isLiked ? tweet.likesCount + 1 : tweet.likesCount - 1,
        retweetsCount: tweet.retweetsCount,
        replyCount: tweet.replyCount,
        trendingScore: tweet.trendingScore,
        isFlagged: tweet.isFlagged,
        flaggedReason: tweet.flaggedReason,
        isTrending: tweet.isTrending,
        engagementScore: tweet.engagementScore,
        topics: tweet.topics,
        forwardsCount: tweet.forwardsCount,
        isLiked: isLiked,
        isRetweeted: tweet.isRetweeted,
        comments: tweet.comments,
      );
      
      // If this is our current tweet, update it too
      if (_currentTweet != null && _currentTweet!.id == tweetId) {
        _currentTweet = Tweet(
          id: _currentTweet!.id,
          user: _currentTweet!.user,
          content: _currentTweet!.content,
          createdAt: _currentTweet!.createdAt,
          updatedAt: _currentTweet!.updatedAt,
          mediaUrl: _currentTweet!.mediaUrl,
          mediaFile: _currentTweet!.mediaFile,
          parentTweet: _currentTweet!.parentTweet,
          likesCount: isLiked ? _currentTweet!.likesCount + 1 : _currentTweet!.likesCount - 1,
          retweetsCount: _currentTweet!.retweetsCount,
          replyCount: _currentTweet!.replyCount,
          trendingScore: _currentTweet!.trendingScore,
          isFlagged: _currentTweet!.isFlagged,
          flaggedReason: _currentTweet!.flaggedReason,
          isTrending: _currentTweet!.isTrending,
          engagementScore: _currentTweet!.engagementScore,
          topics: _currentTweet!.topics,
          forwardsCount: _currentTweet!.forwardsCount,
          isLiked: isLiked,
          isRetweeted: _currentTweet!.isRetweeted,
          comments: _currentTweet!.comments,
        );
      }
      
      notifyListeners();
      return isLiked;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> retweet(int tweetId, {String? comment}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the tweet in our list
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) {
        throw Exception('Tweet not found');
      }
      
      final tweet = _tweets[tweetIndex];
      
      // Update retweet count
      _tweets[tweetIndex] = Tweet(
        id: tweet.id,
        user: tweet.user,
        content: tweet.content,
        createdAt: tweet.createdAt,
        updatedAt: tweet.updatedAt,
        mediaUrl: tweet.mediaUrl,
        mediaFile: tweet.mediaFile,
        parentTweet: tweet.parentTweet,
        likesCount: tweet.likesCount,
        retweetsCount: tweet.retweetsCount + 1,
        replyCount: tweet.replyCount,
        trendingScore: tweet.trendingScore,
        isFlagged: tweet.isFlagged,
        flaggedReason: tweet.flaggedReason,
        isTrending: tweet.isTrending,
        engagementScore: tweet.engagementScore,
        topics: tweet.topics,
        forwardsCount: tweet.forwardsCount,
        isLiked: tweet.isLiked,
        isRetweeted: true,
        comments: tweet.comments,
      );
      
      // If comment provided, create a quote tweet
      if (comment != null && comment.isNotEmpty) {
        final newTweet = Tweet(
          id: _tweets.length + 1000, // Ensure unique ID
          user: User(
            id: 1,
            username: 'testuser',
            email: 'test@example.com',
            firstName: 'Test',
            lastName: 'User',
            emailVerified: true,
            profile: UserProfile(
              id: 1,
              lastActive: DateTime.now(),
              bio: 'Mock user for testing',
              profileImageUrl: 'https://via.placeholder.com/150',
              coverPhotoUrl: 'https://via.placeholder.com/800x200',
              followersCount: 120,
              followingCount: 85,
            ),
          ),
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
        
        // Add to the beginning of the feed
        _tweets.insert(0, newTweet);
      }
      
      // Update current tweet if needed
      if (_currentTweet != null && _currentTweet!.id == tweetId) {
        _currentTweet = Tweet(
          id: _currentTweet!.id,
          user: _currentTweet!.user,
          content: _currentTweet!.content,
          createdAt: _currentTweet!.createdAt,
          updatedAt: _currentTweet!.updatedAt,
          mediaUrl: _currentTweet!.mediaUrl,
          mediaFile: _currentTweet!.mediaFile,
          parentTweet: _currentTweet!.parentTweet,
          likesCount: _currentTweet!.likesCount,
          retweetsCount: _currentTweet!.retweetsCount + 1,
          replyCount: _currentTweet!.replyCount,
          trendingScore: _currentTweet!.trendingScore,
          isFlagged: _currentTweet!.isFlagged,
          flaggedReason: _currentTweet!.flaggedReason,
          isTrending: _currentTweet!.isTrending,
          engagementScore: _currentTweet!.engagementScore,
          topics: _currentTweet!.topics,
          forwardsCount: _currentTweet!.forwardsCount,
          isLiked: _currentTweet!.isLiked,
          isRetweeted: true,
          comments: _currentTweet!.comments,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteTweet(int tweetId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the tweet in our list
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) {
        throw Exception('Tweet not found');
      }
      
      // Only allow deleting own tweets
      final tweet = _tweets[tweetIndex];
      if (tweet.user.username != 'testuser') {
        throw Exception('You can only delete your own tweets');
      }
      
      // Remove tweet
      _tweets.removeAt(tweetIndex);
      
      // If this is the current tweet, clear it
      if (_currentTweet != null && _currentTweet!.id == tweetId) {
        _currentTweet = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> forwardTweet(int tweetId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find the tweet in our list
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) {
        throw Exception('Tweet not found');
      }
      
      // Update forwards count
      final tweet = _tweets[tweetIndex];
      _tweets[tweetIndex] = Tweet(
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
        forwardsCount: tweet.forwardsCount + 1,
        isLiked: tweet.isLiked,
        isRetweeted: tweet.isRetweeted,
        comments: tweet.comments,
      );
      
      // Update current tweet if needed
      if (_currentTweet != null && _currentTweet!.id == tweetId) {
        _currentTweet = Tweet(
          id: _currentTweet!.id,
          user: _currentTweet!.user,
          content: _currentTweet!.content,
          createdAt: _currentTweet!.createdAt,
          updatedAt: _currentTweet!.updatedAt,
          mediaUrl: _currentTweet!.mediaUrl,
          mediaFile: _currentTweet!.mediaFile,
          parentTweet: _currentTweet!.parentTweet,
          likesCount: _currentTweet!.likesCount,
          retweetsCount: _currentTweet!.retweetsCount,
          replyCount: _currentTweet!.replyCount,
          trendingScore: _currentTweet!.trendingScore,
          isFlagged: _currentTweet!.isFlagged,
          flaggedReason: _currentTweet!.flaggedReason,
          isTrending: _currentTweet!.isTrending,
          engagementScore: _currentTweet!.engagementScore,
          topics: _currentTweet!.topics,
          forwardsCount: _currentTweet!.forwardsCount + 1,
          isLiked: _currentTweet!.isLiked,
          isRetweeted: _currentTweet!.isRetweeted,
          comments: _currentTweet!.comments,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadTrendingTopics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // We already have trending topics from mock data
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Tweet>> loadTopicTweets(int topicId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Find the topic
      final topic = _trendingTopics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => throw Exception('Topic not found'),
      );
      
      // Filter tweets by topic
      final topicTweets = _tweets.where((t) => 
        t.topics.contains(topic.name) && 
        t.parentTweet == null
      ).toList();
      
      _isLoading = false;
      notifyListeners();
      
      return topicTweets;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  Future<void> loadUserTweets(String username) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Filter tweets by username
      _userTweets = _tweets.where((t) => 
        t.user.username == username && 
        t.parentTweet == null
      ).toList();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper method to extract hashtags from content
  List<String> _extractHashtags(String content) {
    final regex = RegExp(r'#(\w+)');
    final matches = regex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void resetState() {
    // Do not reset mock data, just the loading state
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
