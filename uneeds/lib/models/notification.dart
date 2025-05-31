class NotificationModel {
  final int? id;
  final String title;
  final String subtitle;
  final String description;
  final String type; // 'target', 'schedule', 'system'
  final int? relatedId; // ID dari target atau jadwal terkait
  final DateTime createdAt;
  final bool isRead;
  final String priority; // 'high', 'medium', 'low'

  NotificationModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
    this.priority = 'medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'type': type,
      'related_id': relatedId,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'priority': priority,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'system',
      relatedId: map['related_id'],
      createdAt: DateTime.parse(map['created_at']),
      isRead: (map['is_read'] ?? 0) == 1,
      priority: map['priority'] ?? 'medium',
    );
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? description,
    String? type,
    int? relatedId,
    DateTime? createdAt,
    bool? isRead,
    String? priority,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
} 