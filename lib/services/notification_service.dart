import 'package:nexus_mobile/config/api_config.dart';
import 'package:nexus_mobile/models/notification.dart';
import 'package:nexus_mobile/services/api_service.dart';

class NotificationService {
  final ApiService _apiService;
  
  NotificationService(this._apiService);
  
  // Get user notifications
  Future<List<Notification>> getNotifications() async {
    try {
      final response = await _apiService.get(ApiConfig.notifications);
      List<dynamic> notificationsJson = response['notifications'];
      return notificationsJson.map((json) => Notification.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }
  
  // Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post(
        '/nexus/notifications/mark-read/$notificationId/',
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post(
        '/nexus/notifications/mark-all-read/',
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
}