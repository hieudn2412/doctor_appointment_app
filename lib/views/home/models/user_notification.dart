enum UserNotificationType { success, danger, neutral }

class UserNotification {
  const UserNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final int userId;
  final UserNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  UserNotification copyWith({
    String? id,
    int? userId,
    UserNotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return UserNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'user_id': userId,
      'type': _typeToRaw(type),
      'title': title,
      'message': message,
      'created_at_ms': createdAt.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
    };
  }

  static UserNotification fromMap(Map<String, Object?> map) {
    return UserNotification(
      id: map['id'] as String,
      userId: (map['user_id'] as num).toInt(),
      type: _typeFromRaw(map['type'] as String?),
      title: map['title'] as String,
      message: map['message'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at_ms'] as num).toInt(),
      ),
      isRead: ((map['is_read'] as num?) ?? 0).toInt() == 1,
    );
  }

  static String _typeToRaw(UserNotificationType type) {
    return switch (type) {
      UserNotificationType.success => 'success',
      UserNotificationType.danger => 'danger',
      UserNotificationType.neutral => 'neutral',
    };
  }

  static UserNotificationType _typeFromRaw(String? raw) {
    return switch (raw) {
      'success' => UserNotificationType.success,
      'danger' => UserNotificationType.danger,
      _ => UserNotificationType.neutral,
    };
  }
}
