class ConversationModel {
  final String conversationId;
  final Map<String, int> participants; // userId -> lastRead timestamp
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final int unreadCount;
  final String type; // 'direct' or 'group'
  final List<String> participantNames;
  final List<String?> participantAvatars;

  const ConversationModel({
    required this.conversationId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.unreadCount = 0,
    this.type = 'direct',
    this.participantNames = const [],
    this.participantAvatars = const [],
  });

  factory ConversationModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return ConversationModel(
      conversationId: id,
      participants: (json['participants'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int? ?? 0)) ??
          {},
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime'] as int)
          : null,
      lastMessageSender: json['lastMessageSender'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      type: json['type'] as String? ?? 'direct',
      participantNames: (json['participantNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      participantAvatars: (json['participantAvatars'] as List<dynamic>?)
              ?.map((e) => e as String?)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSender': lastMessageSender,
      'unreadCount': unreadCount,
      'type': type,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
    };
  }

  ConversationModel copyWith({
    String? conversationId,
    Map<String, int>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSender,
    int? unreadCount,
    String? type,
    List<String>? participantNames,
    List<String?>? participantAvatars,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCount: unreadCount ?? this.unreadCount,
      type: type ?? this.type,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
    );
  }

  bool get isDirect => type == 'direct';
  bool get isGroup => type == 'group';

  String? get otherParticipantId {
    if (participants.length == 2) {
      return participants.keys.firstWhere(
        (id) => true,
        orElse: () => '',
      );
    }
    return null;
  }
}