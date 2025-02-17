import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getNotifications(String userId);
  Future<Either<Failure, Notification>> createNotification(
      Notification notification);
  Future<Either<Failure, Unit>> markAsRead(String notificationId);
  Future<Either<Failure, Unit>> dismiss(String notificationId);
  Future<Either<Failure, Unit>> deleteNotification(String notificationId);
  Stream<Notification> watchNotifications(String userId);
}
