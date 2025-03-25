import 'package:flutter/foundation.dart';
import 'package:nexus_mobile/models/notification.dart';
import 'package:nexus_mobile/services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  NotificationProvider(this._apiService);
  
  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  
  void updateToken(String? token) {
    _apiService.setAuthToken(token);
  }
  
  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simulate loading notifications
      await Future.delayed(const Duration(seconds: 1));
      _notifications = [
        Notification(
          id: 1,
          message: "John liked your tweet",
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          read: false,
        ),
        Notification(
          id: 2,
          message: "Sarah retweeted your post",
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          read: true,
        ),
        Notification(
          id: 3,
          message: "Mike followed you",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          read: false,
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> markAsRead(int notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Create a new notification with read set to true
        final updatedNotification = Notification(
          id: _notifications[index].id,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          read: true,
          targetTweet: _notifications[index].targetTweet,
        );
        
        // Replace the old notification with the updated one
        _notifications[index] = updatedNotification;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> markAllAsRead() async {
    try {
      // Update all notifications to read
      _notifications = _notifications.map((notification) {
        return Notification(
          id: notification.id,
          message: notification.message,
          timestamp: notification.timestamp,
          read: true,
          targetTweet: notification.targetTweet,
        );
      }).toList();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void resetState() {
    _notifications = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}