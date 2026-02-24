import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { message, offer, priceAlert, system }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final bool isRead;
  final String? referenceId;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.isRead = false,
    this.referenceId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, {String? id}) {
    return AppNotification(
      id: id ?? json['id'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isRead: json['isRead'] ?? false,
      referenceId: json['referenceId'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'isRead': isRead,
      'referenceId': referenceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? description,
    bool? isRead,
    String? referenceId,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static NotificationType _parseType(dynamic value) {
    if (value == null) return NotificationType.system;
    final str = value.toString();
    return NotificationType.values.firstWhere(
      (e) => e.name == str,
      orElse: () => NotificationType.system,
    );
  }
}
