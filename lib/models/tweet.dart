import 'package:nexus_mobile/models/user.dart';

class Tweet {
  final int id;
  final User user;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mediaUrl;
  final String? mediaFile;
  final Tweet? parentTweet;
  int likesCount;
  int retweetsCount;
  int replyCount;
  final double trendingScore;
  final bool isFlagged;
  final String? flaggedReason;
  final bool isTrending;
  double engagementScore;
  final List<String> topics;
  int forwardsCount;
  bool isLiked;
  bool isRetweeted;
  final List<Tweet>? comments; // Added comments property

  Tweet({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.mediaUrl,
    this.mediaFile,
    this.parentTweet,
    this.likesCount = 0,
    this.retweetsCount = 0,
    this.replyCount = 0,
    this.trendingScore = 0.0,
    this.isFlagged = false,
    this.flaggedReason,
    this.isTrending = false,
    this.engagementScore = 0.0,
    this.topics = const [],
    this.forwardsCount = 0,
    this.isLiked = false,
    this.isRetweeted = false,
    this.comments, // Added comments property
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'],
      user: User.fromJson(json['registration']),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mediaUrl: json['media_url'],
      mediaFile: json['media_file'],
      parentTweet: json['parent_tweet'] != null ? Tweet.fromJson(json['parent_tweet']) : null,
      likesCount: json['likes_count'] ?? 0,
      retweetsCount: json['retweets_count'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
      trendingScore: (json['trending_score'] ?? 0.0).toDouble(),
      isFlagged: json['is_flagged'] ?? false,
      flaggedReason: json['flagged_reason'],
      isTrending: json['is_trending'] ?? false,
      engagementScore: (json['engagement_score'] ?? 0.0).toDouble(),
      topics: json['topics'] != null ? List<String>.from(json['topics']) : [],
      forwardsCount: json['forwards_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isRetweeted: json['is_retweeted'] ?? false,
      comments: json['comments'] != null 
          ? (json['comments'] as List).map((c) => Tweet.fromJson(c)).toList() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration': user.toJson(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'media_url': mediaUrl,
      'media_file': mediaFile,
      'parent_tweet': parentTweet?.toJson(),
      'likes_count': likesCount,
      'retweets_count': retweetsCount,
      'reply_count': replyCount,
      'trending_score': trendingScore,
      'is_flagged': isFlagged,
      'flagged_reason': flaggedReason,
      'is_trending': isTrending,
      'engagement_score': engagementScore,
      'topics': topics,
      'forwards_count': forwardsCount,
      'is_liked': isLiked,
      'is_retweeted': isRetweeted,
      'comments': comments?.map((c) => c.toJson()).toList(),
    };
  }
}