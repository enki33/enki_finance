import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String title,
    required String message,
    required String type,
    required String status,
    String? referenceId,
    String? referenceType,
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? dismissedAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

enum NotificationType {
  goalProgress,
  balanceAlert,
  budgetAlert,
  transactionAlert,
  systemAlert,
}

enum NotificationStatus {
  unread,
  read,
  dismissed,
}
