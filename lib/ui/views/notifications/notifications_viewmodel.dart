import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/app_notification.dart';
import '../../../services/notification_service.dart';
import '../../../services/auth_service.dart';

class NotificationsViewModel extends BaseViewModel {
  final _notificationService = locator<NotificationService>();
  final _authService = locator<AuthService>();
  final _crashlytics = locator<CrashlyticsService>();

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setBusy(true);

    return Executor.run(_notificationService.getNotifications(user.uid))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'NotificationsViewModel',
                      'init()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Could not load notifications');
                setBusy(false);
              },
              (data) {
                _notifications = data;
                setBusy(false);
                rebuildUi();
              },
            ));
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    return Executor.run(
            _notificationService.markAsRead(user.uid, notificationId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'NotificationsViewModel',
                      'markAsRead($notificationId)',
                      failure.toString()
                    ],
                    failure.stackTrace);
              },
              (_) {
                final index =
                    _notifications.indexWhere((n) => n.id == notificationId);
                if (index != -1) {
                  _notifications[index] =
                      _notifications[index].copyWith(isRead: true);
                  rebuildUi();
                }
              },
            ));
  }

  Future<void> markAllRead() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final unread = _notifications.where((n) => !n.isRead).toList();
    for (final notif in unread) {
      await markAsRead(notif.id);
    }
  }
}
