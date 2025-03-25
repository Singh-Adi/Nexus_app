class TweetTopic {
  final int id;
  final String name;
  final int tweetCount;

  TweetTopic({
    required this.id,
    required this.name,
    this.tweetCount = 0,
  });

  factory TweetTopic.fromJson(Map<String, dynamic> json) {
    return TweetTopic(
      id: json['id'],
      name: json['name'],
      tweetCount: json['tweet_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tweet_count': tweetCount,
    };
  }
}