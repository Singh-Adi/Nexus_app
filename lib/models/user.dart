class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool emailVerified;
  UserProfile? _profile;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.emailVerified = false,
    UserProfile? profile,
  }) : _profile = profile;

  UserProfile? get profile => _profile;
  set profile(UserProfile? value) {
    _profile = value;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      emailVerified: json['email_verified'] ?? false,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email_verified': emailVerified,
      'profile': _profile?.toJson(),
    };
  }
}

class UserProfile {
  final int id;
  String? _coverPhotoUrl;
  String? _bio;
  String? _profileImageUrl;
  double _engagementScore;
  DateTime _lastActive;
  bool _isSuspended;
  int _followersCount;
  int _followingCount;
  bool _isFollowing;
  User? _user;

  UserProfile({
    required this.id,
    String? coverPhotoUrl,
    String? bio,
    String? profileImageUrl,
    double engagementScore = 0.0,
    required DateTime lastActive,
    bool isSuspended = false,
    int followersCount = 0,
    int followingCount = 0,
    bool isFollowing = false,
    User? user,
  }) : 
    _coverPhotoUrl = coverPhotoUrl,
    _bio = bio,
    _profileImageUrl = profileImageUrl,
    _engagementScore = engagementScore,
    _lastActive = lastActive,
    _isSuspended = isSuspended,
    _followersCount = followersCount,
    _followingCount = followingCount,
    _isFollowing = isFollowing,
    _user = user;

  String? get coverPhotoUrl => _coverPhotoUrl;
  set coverPhotoUrl(String? value) {
    _coverPhotoUrl = value;
  }

  String? get bio => _bio;
  set bio(String? value) {
    _bio = value;
  }

  String? get profileImageUrl => _profileImageUrl;
  set profileImageUrl(String? value) {
    _profileImageUrl = value;
  }

  double get engagementScore => _engagementScore;
  set engagementScore(double value) {
    _engagementScore = value;
  }

  DateTime get lastActive => _lastActive;
  set lastActive(DateTime value) {
    _lastActive = value;
  }

  bool get isSuspended => _isSuspended;
  set isSuspended(bool value) {
    _isSuspended = value;
  }

  int get followersCount => _followersCount;
  set followersCount(int value) {
    _followersCount = value;
  }

  int get followingCount => _followingCount;
  set followingCount(int value) {
    _followingCount = value;
  }

  bool get isFollowing => _isFollowing;
  set isFollowing(bool value) {
    _isFollowing = value;
  }

  User? get user => _user;
  set user(User? value) {
    _user = value;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      coverPhotoUrl: json['cover_photo'],
      bio: json['bio'],
      profileImageUrl: json['profile_image'],
      engagementScore: (json['engagement_score'] ?? 0.0).toDouble(),
      lastActive: DateTime.parse(json['last_active']),
      isSuspended: json['is_suspended'] ?? false,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cover_photo': _coverPhotoUrl,
      'bio': _bio,
      'profile_image': _profileImageUrl,
      'engagement_score': _engagementScore,
      'last_active': _lastActive.toIso8601String(),
      'is_suspended': _isSuspended,
      'followers_count': _followersCount,
      'following_count': _followingCount,
      'is_following': _isFollowing,
      'user': _user?.toJson(),
    };
  }
}
