import 'package:adentweets_admin/core/constants/app_constants.dart';

enum VerificationBadge { none, blue, gray }

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? avatarBase64;
  final String? bannerUrl;
  final String? bannerBase64;
  final String? bio;
  final String? location;
  final String? website;
  final bool isVerified;
  final String verificationType;
  final bool isAdmin;
  final bool isSuspended;
  final bool isPrivate;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActive;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.avatarBase64,
    this.bannerUrl,
    this.bannerBase64,
    this.bio,
    this.location,
    this.website,
    this.isVerified = false,
    this.verificationType = AppConstants.verificationNone,
    this.isAdmin = false,
    this.isSuspended = false,
    this.isPrivate = false,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.lastActive,
    this.isOnline = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      displayName: map['displayName'] as String? ?? map['fullName'] as String? ?? map['name'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      avatarBase64: map['avatarBase64'] as String?,
      bannerUrl: map['bannerUrl'] as String?,
      bannerBase64: map['bannerBase64'] as String?,
      bio: map['bio'] as String?,
      location: map['location'] as String?,
      website: map['website'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      verificationType: map['verificationType'] as String? ?? map['verificationBadge'] as String? ?? AppConstants.verificationNone,
      isAdmin: map['isAdmin'] as bool? ?? false,
      isSuspended: map['isSuspended'] as bool? ?? false,
      isPrivate: map['isPrivate'] as bool? ?? false,
      postsCount: map['postsCount'] as int? ?? 0,
      followersCount: map['followersCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
      createdAt: _parseTimestamp(map['createdAt'] ?? map['joinedAt']),
      updatedAt: _parseNullableTimestamp(map['updatedAt']),
      lastActive: _parseNullableTimestamp(map['lastActive']),
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'avatarBase64': avatarBase64,
      'bannerUrl': bannerUrl,
      'bannerBase64': bannerBase64,
      'bio': bio,
      'location': location,
      'website': website,
      'isVerified': isVerified,
      'verificationType': verificationType,
      'isAdmin': isAdmin,
      'isSuspended': isSuspended,
      'isPrivate': isPrivate,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastActive': lastActive?.millisecondsSinceEpoch,
      'isOnline': isOnline,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? username,
    String? bio,
    String? location,
    String? website,
    bool? isVerified,
    String? verificationType,
    bool? isAdmin,
    bool? isSuspended,
    bool? isPrivate,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    DateTime? lastActive,
    bool? isOnline,
    String? avatarUrl,
    String? avatarBase64,
    String? bannerUrl,
    String? bannerBase64,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bannerBase64: bannerBase64 ?? this.bannerBase64,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      verificationType: verificationType ?? this.verificationType,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuspended: isSuspended ?? this.isSuspended,
      isPrivate: isPrivate ?? this.isPrivate,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  VerificationBadge get badge => switch (verificationType) {
    'blue' => VerificationBadge.blue,
    'gray' => VerificationBadge.gray,
    _ => VerificationBadge.none,
  };

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }

  static DateTime? _parseNullableTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}