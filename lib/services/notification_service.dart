import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/services/crashlytics_service.dart';
import '../models/app_notification.dart';
import '../repositories/firestore_repository.dart';

class NotificationService {
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  String _collectionPath(String userId) => 'users/$userId/notifications';

  Future<List<AppNotification>> getNotifications(String userId) {
    return Executor.run(_firestoreRepo.getCollection(
      collection: _collectionPath(userId),
      queryBuilder: (ref) => ref.orderBy('createdAt', descending: true),
      limit: 50,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'NotificationService',
                  'getNotifications($userId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docs) => docs
              .map((d) => AppNotification.fromJson(d, id: d['id']))
              .toList(),
        ));
  }

  Future<void> markAsRead(String userId, String notificationId) {
    return Executor.run(_firestoreRepo.setDocument(
      collection: _collectionPath(userId),
      id: notificationId,
      data: {'isRead': true},
      merge: true,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'NotificationService',
                  'markAsRead($notificationId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }
}
