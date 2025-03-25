import 'dart:io';
import 'package:nexus_mobile/config/api_config.dart';
import 'package:nexus_mobile/models/tweet.dart';
import 'package:nexus_mobile/models/topic.dart';
import 'package:nexus_mobile/services/api_service.dart';
import 'package:path/path.dart' as path;

class TweetService {
  final ApiService _apiService;
  
  TweetService(this._apiService);
  
  // Get home feed tweets
  Future<List<Tweet>> getFeed({String feedType = 'for_you', int page = 1}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.tweets,
        queryParameters: {
          'feed': feedType,
          'page': page,
        },
      );
      
      List<dynamic> tweetsJson = response['tweets'];
      return tweetsJson.map((json) => Tweet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load feed: ${e.toString()}');
    }
  }
  
  // Get tweet details
  Future<Tweet> getTweetDetails(int tweetId) async {
    try {
      final response = await _apiService.get('${ApiConfig.tweetDetail}$tweetId/');
      return Tweet.fromJson(response['tweet']);
    } catch (e) {
      throw Exception('Failed to load tweet details: ${e.toString()}');
    }
  }
  
  // Post a new tweet
  Future<Tweet> postTweet({required String content, File? mediaFile}) async {
    try {
      if (mediaFile != null) {
        final fileName = path.basename(mediaFile.path);
        final response = await _apiService.upload(
          ApiConfig.postTweet,
          file: mediaFile,
          fileName: fileName,
          fieldName: 'media_file',
          extraData: {'content': content},
        );
        return Tweet.fromJson(response['tweet']);
      } else {
        final response = await _apiService.post(
          ApiConfig.postTweet,
          data: {'content': content},
        );
        return Tweet.fromJson(response['tweet']);
      }
    } catch (e) {
      throw Exception('Failed to post tweet: ${e.toString()}');
    }
  }
  
  // Post a comment/reply to a tweet
  Future<Tweet> postComment(int tweetId, String content) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.comment}$tweetId/',
        data: {'content': content},
      );
      return Tweet.fromJson(response['comment']);
    } catch (e) {
      throw Exception('Failed to post comment: ${e.toString()}');
    }
  }
  
  // Like or unlike a tweet
  Future<Map<String, dynamic>> likeTweet(int tweetId) async {
    try {
      final response = await _apiService.post('${ApiConfig.likeTweet}$tweetId/');
      return {
        'liked': response['liked'],
        'likes_count': response['likes_count'],
      };
    } catch (e) {
      throw Exception('Failed to like/unlike tweet: ${e.toString()}');
    }
  }
  
  // Retweet a tweet
  Future<Map<String, dynamic>> retweet(int tweetId, {String? comment}) async {
    try {
      final response = await _apiService.post(
        ApiConfig.retweet.replaceAll('{id}', tweetId.toString()),
        data: comment != null ? {'comment': comment} : null,
      );
      return {
        'retweeted': true,
        'retweets_count': response['retweets_count'],
      };
    } catch (e) {
      throw Exception('Failed to retweet: ${e.toString()}');
    }
  }
  
  // Delete a tweet
  Future<bool> deleteTweet(int tweetId) async {
    try {
      final response = await _apiService.post('${ApiConfig.deleteTweet}$tweetId/');
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete tweet: ${e.toString()}');
    }
  }
  
  // Forward a tweet (increment forward count)
  Future<Map<String, dynamic>> forwardTweet(int tweetId) async {
    try {
      final response = await _apiService.post('/nexus/ajax/forward/$tweetId/');
      return {
        'success': response['success'],
        'new_forwards_count': response['new_forwards_count'],
      };
    } catch (e) {
      throw Exception('Failed to forward tweet: ${e.toString()}');
    }
  }
  
  // Get trending topics
  Future<List<TweetTopic>> getTrendingTopics() async {
    try {
      final response = await _apiService.get(ApiConfig.trending);
      List<dynamic> topicsJson = response['trending_topics'];
      return topicsJson.map((json) => TweetTopic.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load trending topics: ${e.toString()}');
    }
  }
  
  // Get tweets for a specific topic
  Future<List<Tweet>> getTopicTweets(int topicId) async {
    try {
      final response = await _apiService.get('${ApiConfig.topicDetail}$topicId/');
      List<dynamic> tweetsJson = response['tweets'];
      return tweetsJson.map((json) => Tweet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load topic tweets: ${e.toString()}');
    }
  }
}