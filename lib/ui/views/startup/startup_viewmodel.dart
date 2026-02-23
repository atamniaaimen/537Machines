import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../services/auth_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 1));

    // On web with placeholder Firebase config, skip auth entirely
    if (kIsWeb) {
      try {
        final authService = locator<AuthService>();
        final crashlytics = locator<CrashlyticsService>();
        await Executor.run(authService.tryAutoLogin())
            .then((result) => result.fold(
                  (failure) {
                    crashlytics.logToCrashlytics(
                        Level.warning,
                        ['StartupViewModel', 'init()', failure.toString()],
                        failure.stackTrace);
                    _navigationService.clearStackAndShow(Routes.loginView);
                  },
                  (_) {
                    if (authService.isLoggedIn) {
                      _navigationService.clearStackAndShow(Routes.mainView);
                    } else {
                      _navigationService.clearStackAndShow(Routes.loginView);
                    }
                  },
                ));
      } catch (e) {
        debugPrint('Startup auth failed (web): $e');
        _navigationService.clearStackAndShow(Routes.loginView);
      }
      return;
    }

    // Native platforms
    final authService = locator<AuthService>();
    final crashlytics = locator<CrashlyticsService>();

    try {
      await Executor.run(authService.tryAutoLogin())
          .then((result) => result.fold(
                (failure) {
                  crashlytics.logToCrashlytics(
                      Level.warning,
                      ['StartupViewModel', 'init()', failure.toString()],
                      failure.stackTrace);
                  _navigationService.clearStackAndShow(Routes.loginView);
                },
                (_) {
                  if (authService.isLoggedIn) {
                    _navigationService.clearStackAndShow(Routes.mainView);
                  } else {
                    _navigationService.clearStackAndShow(Routes.loginView);
                  }
                },
              ));
    } catch (e) {
      _navigationService.clearStackAndShow(Routes.loginView);
    }
  }
}
