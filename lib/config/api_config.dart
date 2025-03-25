class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000'; // For Android Emulator
  // Use 'http://localhost:8000' for iOS simulator
  // Use actual network IP for physical devices
  
  static const String apiUrl = '$baseUrl';
  
  // Auth endpoints
  static const String login = '/accounts/login/';
  static const String register = '/accounts/register/';
  static const String verifyEmail = '/accounts/verify-email/';
  static const String forgotPassword = '/accounts/forgot-password/';
  static const String resetPassword = '/accounts/reset-password/';
  
  // Tweet endpoints
  static const String tweets = '/nexus/';
  static const String tweetDetail = '/nexus/tweet/';
  static const String postTweet = '/nexus/post-tweet/';
  static const String likeTweet = '/nexus/ajax/like/';
  static const String retweet = '/nexus/tweet/{id}/retweet/';
  static const String comment = '/nexus/ajax/comment/';
  static const String deleteTweet = '/nexus/ajax/delete/';
  
  // User endpoints
  static const String userProfile = '/nexus/profile/';
  static const String followUser = '/nexus/profile/{username}/follow/';
  static const String unfollowUser = '/nexus/profile/{username}/unfollow/';
  static const String followers = '/nexus/profile/{username}/followers/';
  static const String following = '/nexus/profile/{username}/following/';
  
  // Discover endpoints
  static const String trending = '/nexus/trending/';
  static const String suggestedUsers = '/nexus/suggested/';
  static const String topicDetail = '/nexus/topic/';
  
  // Notifications endpoint
  static const String notifications = '/nexus/notifications/';
  
  // Settings endpoint
  static const String settings = '/nexus/settings/';
}