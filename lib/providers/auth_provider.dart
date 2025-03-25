import 'package:flutter/foundation.dart';
import 'package:nexus_mobile/models/user.dart';
import 'package:nexus_mobile/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  User? _user;
  bool _isLoading = true;
  String? _token;
  String? _error;
  
  AuthProvider(this._authService) {
    _initializeAuth();
  }
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get error => _error;
  
  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Try to get token - if we're working with mock data, this might be null
      _token = await _authService.getToken();
      
      if (_token != null) {
        _user = await _authService.getCurrentUser();
        if (_user == null) {
          _token = null;
        }
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // For testing purposes - always succeed with test credentials
      if (username == 'testuser' && password == 'password123') {
        // Create a mock user
        _user = User(
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
        
        // Set a mock token
        _token = 'mock_auth_token';
        
        // Store token in secure storage
        await _authService.storeTokenForMockLogin(_token!);
        
        return true;
      }
      
      // If not using test credentials, try the actual login
      try {
        _user = await _authService.login(username, password);
        _token = await _authService.getToken();
        return true;
      } catch (e) {
        _error = 'Invalid username or password';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authService.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phoneNumber: phoneNumber,
      );
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _authService.forgotPassword(email);
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      return await _authService.resetPassword(token, newPassword, confirmPassword);
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.logout();
      _user = null;
      _token = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> refreshUser() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
