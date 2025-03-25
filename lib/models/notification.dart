class Notification {
  final int id;
  final String message;
  final DateTime timestamp;
  final bool read;
  final dynamic targetTweet;

  Notification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.read = false,
    this.targetTweet,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'] ?? false,
      targetTweet: json['target_tweet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'target_tweet': targetTweet,
    };
  }
}