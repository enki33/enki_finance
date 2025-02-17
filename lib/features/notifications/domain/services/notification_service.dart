import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;

  const NotificationService(this._repository);

  Future<Either<Failure, List<Notification>>> getUnreadNotifications(
      String userId) async {
    try {
      final result = await _repository.getNotifications(userId);
      return result.map(
        (notifications) => notifications
            .where((n) => n.status == NotificationStatus.unread.name)
            .toList(),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> createGoalProgressNotification({
    required String userId,
    required String goalId,
    required String goalName,
    required double percentageComplete,
  }) async {
    try {
      final notification = Notification(
        id: '', // Will be set by database
        userId: userId,
        title: 'Goal Progress Update',
        message: 'Your goal "$goalName" is now $percentageComplete% complete!',
        type: NotificationType.goalProgress.name,
        status: NotificationStatus.unread.name,
        referenceId: goalId,
        referenceType: 'goal',
        createdAt: DateTime.now(),
      );

      final result = await _repository.createNotification(notification);
      return result.map((_) => unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  // Add other notification creation methods...
}
