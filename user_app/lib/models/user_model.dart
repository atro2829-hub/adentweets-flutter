import 'package:adentweets_app/core/constants/app_constants.dart';

enum VerificationBadge { none, blue, gray }

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String fullName;
  final String bio;
  final String? avatarBase64;
  final String? bannerBase64;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final VerificationBadge verificationBadge;
  final bool isPrivate;
  final bool isSuspended;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? lastActive;
  final bool isOnline;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.fullName,
    this.bio = '',
    this.avatarBase64,
    this.bannerBase64,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isVerified = false,
    this.verificationBadge = VerificationBadge.none,
    this.isPrivate = false,
    this.isSuspended = false,
    this.isAdmin = false,
    required this.createdAt,
    this.lastActive,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarBase64: json['avatarBase64'] as String?,
      bannerBase64: json['bannerBase64'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      verificationBadge: _parseBadge(json['verificationBadge'] as String?),
      isPrivate: json['isPrivate'] as bool? ?? false,
      isSuspended: json['isSuspended'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      lastActive: json['lastActive'] != null
          ? _parseDate(json['lastActive'])
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'fullName': fullName,
      'bio': bio,
      'avatarBase64': avatarBase64,
      'bannerBase64': bannerBase64,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified,
      'verificationBadge': verificationBadge.name,
      'isPrivate': isPrivate,
      'isSuspended': isSuspended,
      'isAdmin': isAdmin,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActive': lastActive?.millisecondsSinceEpoch,
      'isOnline': isOnline,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? fullName,
    String? bio,
    String? avatarBase64,
    String? bannerBase64,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    VerificationBadge? verificationBadge,
    bool? isPrivate,
    bool? isSuspended,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isOnline,
    bool clearAvatar,
    bool clearBanner,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarBase64: clearAvatar ? null : (avatarBase64 ?? this.avatarBase64),
      bannerBase64: clearBanner ? null : (bannerBase64 ?? this.bannerBase64),
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      verificationBadge: verificationBadge ?? this.verificationBadge,
      isPrivate: isPrivate ?? this.isPrivate,
      isSuspended: isSuspended ?? this.isSuspended,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  String get avatarOrDefault =>
      avatarBase64 ?? AppConstants.defaultAvatar;

  static VerificationBadge _parseBadge(String? badge) {
    switch (badge) {
      case AppConstants.verificationBadgeBlue:
        return VerificationBadge.blue;
      case AppConstants.verificationBadgeGray:
        return VerificationBadge.gray;
      default:
        return VerificationBadge.none;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}