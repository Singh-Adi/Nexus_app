import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/services/mock_service.dart';

class MockAuthService {
  final MockService _mockService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  User? _currentUser;
  
  MockAuthService(this._mockService);
  
  // Login user
  Future<User> login(String username, String password) async {
    try {
      final user = await _mockService.login(username, password);
      
      // Store token securely (just a placeholder in mock)
      await _secureStorage.write(key: 'auth_token', value: 'mock_token');
      _currentUser = user;
      
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
      return await _mockService.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  // Verify email with token
  Future<bool> verifyEmail(String token) async {
    // Just return success for mock
    return true;
  }
  
  // Request password reset
  Future<bool> forgotPassword(String email) async {
    try {
      return await _mockService.forgotPassword(email);
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }
  
  // Reset password with token
  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    try {
      return await _mockService.resetPassword(token, newPassword, confirmPassword);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      _currentUser = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
  
  // Check if user is logged in and get token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      throw Exception('Failed to get token: ${e.toString()}');
    }
  }
  
  // Get current user profile (useful after app restart)
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      // Return mock user if token exists
      if (_currentUser == null) {
        // For mock service, always return the same test user
        _currentUser = await _mockService.login('testuser', 'password123');
      }
      
      return _currentUser;
    } catch (e) {
      // If we can't get the current user, let's invalidate the token
      await _secureStorage.delete(key: 'auth_token');
      return null;
    }
  }
}