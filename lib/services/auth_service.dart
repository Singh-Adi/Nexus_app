import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nexus_mobile/config/api_config.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/services/api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthService(this._apiService);
  
  // Store mock token (used for testing)
  Future<void> storeTokenForMockLogin(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    _apiService.setAuthToken(token);
  }
  
  // Login user
  Future<User> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      final token = response['token'];
      final user = User.fromJson(response['user']);
      
      // Store token securely
      await _secureStorage.write(key: 'auth_token', value: token);
      _apiService.setAuthToken(token);
      
      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  // Register a new user
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'username': username,
          'email': email,
          'password1': password,
          'password2': passwordConfirm,
          'phone_number': phoneNumber,
        },
      );
      
      return User.fromJson(response['user']);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  // Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _apiService.get('${ApiConfig.verifyEmail}$token/');
      return response['success'] == true;
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }
  
  // Request password reset
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        ApiConfig.forgotPassword,
        data: {'email': email},
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }
  
  // Reset password with token
  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.resetPassword}$token/',
        data: {
          'new_password1': newPassword,
          'new_password2': confirmPassword,
        },
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      _apiService.setAuthToken(null);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
  
  // Check if user is logged in and get token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        _apiService.setAuthToken(token);
      }
      return token;
    } catch (e) {
      throw Exception('Failed to get token: ${e.toString()}');
    }
  }
  
  // Get current user profile (useful after app restart)
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      // For mock login, create a mock user
      if (token == 'mock_auth_token') {
        return User(
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
            followingCount: 85
          )
        );
      }
      
      // Normal API call
      final response = await _apiService.get('/nexus/profile/me/');
      return User.fromJson(response);
    } catch (e) {
      // If we can't get the current user, let's check if it's a mock token
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == 'mock_auth_token') {
        return User(
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
            followingCount: 85
          )
        );
      }
      
      // If not a mock token, invalidate
      await _secureStorage.delete(key: 'auth_token');
      return null;
    }
  }
}
