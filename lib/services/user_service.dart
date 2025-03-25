import 'dart:io';
import 'package:nexus_mobile/config/api_config.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/services/api_service.dart';
import 'package:path/path.dart' as path;

class UserService {
  final ApiService _apiService;
  
  UserService(this._apiService);
  
  // Get user profile by username
  Future<UserProfile> getUserProfile(String username) async {
    try {
      final response = await _apiService.get('${ApiConfig.userProfile}$username/');
      return UserProfile.fromJson(response['user_profile']);
    } catch (e) {
      throw Exception('Failed to load user profile: ${e.toString()}');
    }
  }
  
  // Edit user profile
  Future<UserProfile> updateProfile({
    String? bio,
    File? profileImage,
    File? coverPhoto,
  }) async {
    try {
      final Map<String, dynamic> formData = {};
      
      if (bio != null) {
        formData['bio'] = bio;
      }
      
      if (profileImage != null || coverPhoto != null) {
        // We need to use multipart/form-data for file uploads
        final extraData = bio != null ? {'bio': bio} : null;
        
        if (profileImage != null) {
          final fileName = path.basename(profileImage.path);
          final response = await _apiService.upload(
            '/nexus/profile/update/',
            file: profileImage,
            fileName: fileName,
            fieldName: 'profile_image',
            extraData: extraData,
          );
          return UserProfile.fromJson(response['user_profile']);
        }
        
        if (coverPhoto != null) {
          final fileName = path.basename(coverPhoto.path);
          final response = await _apiService.upload(
            '/nexus/profile/update/',
            file: coverPhoto,
            fileName: fileName,
            fieldName: 'cover_photo',
            extraData: extraData,
          );
          return UserProfile.fromJson(response['user_profile']);
        }
      }
      
      if (formData.isNotEmpty) {
        final response = await _apiService.post(
          '/nexus/profile/update/',
          data: formData,
        );
        return UserProfile.fromJson(response['user_profile']);
      }
      
      throw Exception('No profile changes specified');
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
  
  // Follow a user
  Future<bool> followUser(String username) async {
    try {
      final response = await _apiService.post(
        ApiConfig.followUser.replaceAll('{username}', username),
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to follow user: ${e.toString()}');
    }
  }
  
  // Unfollow a user
  Future<bool> unfollowUser(String username) async {
    try {
      final response = await _apiService.post(
        ApiConfig.unfollowUser.replaceAll('{username}', username),
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to unfollow user: ${e.toString()}');
    }
  }
  
  // Get user's followers
  Future<List<UserProfile>> getFollowers(String username) async {
    try {
      final response = await _apiService.get(
        ApiConfig.followers.replaceAll('{username}', username),
      );
      List<dynamic> followersJson = response['followers'];
      return followersJson.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load followers: ${e.toString()}');
    }
  }
  
  // Get users followed by a user
  Future<List<UserProfile>> getFollowing(String username) async {
    try {
      final response = await _apiService.get(
        ApiConfig.following.replaceAll('{username}', username),
      );
      List<dynamic> followingJson = response['following'];
      return followingJson.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load following: ${e.toString()}');
    }
  }
  
  // Get suggested users to follow
  Future<List<UserProfile>> getSuggestedUsers() async {
    try {
      final response = await _apiService.get(ApiConfig.suggestedUsers);
      List<dynamic> usersJson = response['suggested_users'];
      return usersJson.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load suggested users: ${e.toString()}');
    }
  }
  
  // Update user settings
  Future<Map<String, dynamic>> updateSettings({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? privacyPublic,
    bool? is2faEnabled,
    String? twoFaMethod,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (emailNotifications != null) data['email_notifications'] = emailNotifications;
      if (pushNotifications != null) data['push_notifications'] = pushNotifications;
      if (privacyPublic != null) data['privacy_public'] = privacyPublic;
      if (is2faEnabled != null) data['is_2fa_enabled'] = is2faEnabled;
      if (twoFaMethod != null) data['two_fa_method'] = twoFaMethod;
      
      final response = await _apiService.post(
        ApiConfig.settings,
        data: data,
      );
      
      return {'success': true, 'settings': response};
    } catch (e) {
      throw Exception('Failed to update settings: ${e.toString()}');
    }
  }
}