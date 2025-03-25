import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/services/api_service.dart';
import 'package:nexus_mobile/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService;
  late UserService _userService;
  
  UserProfile? _currentProfile;
  List<UserProfile> _followers = [];
  List<UserProfile> _following = [];
  List<UserProfile> _suggestedUsers = [];
  bool _isLoading = false;
  String? _error;
  
  UserProvider(this._apiService) {
    _userService = UserService(_apiService);
  }
  
  UserProfile? get currentProfile => _currentProfile;
  List<UserProfile> get followers => _followers;
  List<UserProfile> get following => _following;
  List<UserProfile> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void updateToken(String? token) {
    _apiService.setAuthToken(token);
  }
  
  Future<void> loadUserProfile(String username) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _currentProfile = await _userService.getUserProfile(username);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProfile({
    String? bio,
    File? profileImage,
    File? coverPhoto,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final updatedProfile = await _userService.updateProfile(
        bio: bio,
        profileImage: profileImage,
        coverPhoto: coverPhoto,
      );
      
      _currentProfile = updatedProfile;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> followUser(String username) async {
    try {
      final success = await _userService.followUser(username);
      
      if (success && _currentProfile != null && _currentProfile!.user!.username == username) {
        _currentProfile = _currentProfile!.copyWith(isFollowing: true);
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> unfollowUser(String username) async {
    try {
      final success = await _userService.unfollowUser(username);
      
      if (success && _currentProfile != null && _currentProfile!.user!.username == username) {
        _currentProfile = _currentProfile!.copyWith(isFollowing: false);
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadFollowers(String username) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _followers = await _userService.getFollowers(username);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadFollowing(String username) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _following = await _userService.getFollowing(username);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadSuggestedUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _suggestedUsers = await _userService.getSuggestedUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateSettings({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? privacyPublic,
    bool? is2faEnabled,
    String? twoFaMethod,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _userService.updateSettings(
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
        privacyPublic: privacyPublic,
        is2faEnabled: is2faEnabled,
        twoFaMethod: twoFaMethod,
      );
      
      return response['success'] == true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void resetState() {
    _currentProfile = null;
    _followers = [];
    _following = [];
    _suggestedUsers = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

// Extension for UserProfile to enable creating copies with modified properties
extension UserProfileExtension on UserProfile {
  UserProfile copyWith({
    int? id,
    String? coverPhotoUrl,
    String? bio,
    String? profileImageUrl,
    double? engagementScore,
    DateTime? lastActive,
    bool? isSuspended,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    User? user,
  }) {
    return UserProfile(
      id: id ?? this.id,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      engagementScore: engagementScore ?? this.engagementScore,
      lastActive: lastActive ?? this.lastActive,
      isSuspended: isSuspended ?? this.isSuspended,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}