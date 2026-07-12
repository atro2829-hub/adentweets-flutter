class MessageModel {
  final String messageId;
  final String senderId;
  final String content;
  final String? imageBase64;
  final DateTime createdAt;
  final String type; // 'text', 'image', 'system'
  final bool isRead;

  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.content,
    this.imageBase64,
    required this.createdAt,
    this.type = 'text',
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageBase64: json['imageBase64'] as String?,
      createdAt: _parseDate(json['createdAt']),
      type: json['type'] as String? ?? 'text',
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'imageBase64': imageBase64,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? content,
    String? imageBase64,
    DateTime? createdAt,
    String? type,
    bool? isRead,
    bool clearImage,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      imageBase64: clearImage ? null : (imageBase64 ?? this.imageBase64),
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  bool get isImage => type == 'image';
  bool get isSystem => type == 'system';
  bool get isText => type == 'text';

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}