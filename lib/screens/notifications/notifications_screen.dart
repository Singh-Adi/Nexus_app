import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_mobile/models/notification.dart' as app_notification;
import 'package:nexus_mobile/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }
  
  Future<void> _loadNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.loadNotifications();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Mark all as read',
            onPressed: () async {
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
              await notificationProvider.markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading && notificationProvider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (notificationProvider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationItem(notification, notificationProvider);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationItem(
    app_notification.Notification notification,
    NotificationProvider notificationProvider,
  ) {
    return InkWell(
      onTap: () {
        // Mark notification as read
        notificationProvider.markAsRead(notification.id);
      },
      child: Container(
        color: notification.read ? null : Colors.blue[50],
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getNotificationIcon(notification.message),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(notification.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months != 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years != 1 ? 's' : ''} ago';
    }
  }
  
  Widget _getNotificationIcon(String message) {
    // Determine icon based on message content
    IconData iconData;
    Color iconColor;
    
    if (message.contains('liked')) {
      iconData = Icons.favorite;
      iconColor = Colors.red;
    } else if (message.contains('retweet') || message.contains('shared')) {
      iconData = Icons.repeat;
      iconColor = Colors.green;
    } else if (message.contains('replied') || message.contains('commented')) {
      iconData = Icons.comment;
      iconColor = Colors.blue;
    } else if (message.contains('followed')) {
      iconData = Icons.person_add;
      iconColor = Colors.purple;
    } else if (message.contains('mentioned')) {
      iconData = Icons.alternate_email;
      iconColor = Colors.orange;
    } else {
      iconData = Icons.notifications;
      iconColor = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(
        iconData,
        size: 20,
        color: iconColor,
      ),
    );
  }
}