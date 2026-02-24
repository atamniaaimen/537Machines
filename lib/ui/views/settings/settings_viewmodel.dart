import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class SettingsViewModel extends ReactiveViewModel {
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _crashlytics = locator<CrashlyticsService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_authService];

  AppUser? get currentUser => _authService.currentUser;

  bool get notifyMessages => currentUser?.notifyMessages ?? true;
  bool get notifyOffers => currentUser?.notifyOffers ?? true;
  bool get notifyPriceDrops => currentUser?.notifyPriceDrops ?? false;
  bool get notifyNewListings => currentUser?.notifyNewListings ?? false;

  Future<void> toggleNotifyMessages(bool value) async {
    await _updatePreference(notifyMessages: value);
  }

  Future<void> toggleNotifyOffers(bool value) async {
    await _updatePreference(notifyOffers: value);
  }

  Future<void> toggleNotifyPriceDrops(bool value) async {
    await _updatePreference(notifyPriceDrops: value);
  }

  Future<void> toggleNotifyNewListings(bool value) async {
    await _updatePreference(notifyNewListings: value);
  }

  Future<void> _updatePreference({
    bool? notifyMessages,
    bool? notifyOffers,
    bool? notifyPriceDrops,
    bool? notifyNewListings,
  }) async {
    if (currentUser == null) return;

    final updated = currentUser!.copyWith(
      notifyMessages: notifyMessages,
      notifyOffers: notifyOffers,
      notifyPriceDrops: notifyPriceDrops,
      notifyNewListings: notifyNewListings,
    );

    return Executor.run(_userService.updateUser(updated))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'SettingsViewModel',
                      '_updatePreference()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Failed to update preference');
              },
              (_) {},
            ));
  }

  Future<void> signOut() async {
    setBusy(true);

    return Executor.run(_authService.signOut()).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['SettingsViewModel', 'signOut()', failure.toString()],
                failure.stackTrace);
            setError('Failed to sign out');
            setBusy(false);
          },
          (_) {
            setBusy(false);
            _navigationService.clearStackAndShow(Routes.loginView);
          },
        ));
  }

  Future<void> deleteAccount() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Delete Account',
      description:
          'Are you sure you want to delete your account? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (response?.confirmed != true) return;

    // For now, just sign out. Full account deletion requires Firebase Admin SDK.
    await signOut();
  }
}
