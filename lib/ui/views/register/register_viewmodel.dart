import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/error_handling/failures/auth_failure.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../services/auth_service.dart';

class RegisterViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _crashlytics = locator<CrashlyticsService>();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    rebuildUi();
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String company = '',
  }) async {
    setBusy(true);

    return Executor.run(_authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      company: company,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['RegisterViewModel', 'signUp()', failure.toString()],
                failure.stackTrace);

            switch (failure.type) {
              case AuthFailureType.emailAlreadyInUse:
                setError('An account with this email already exists');
                break;
              case AuthFailureType.weakPassword:
                setError('Password is too weak');
                break;
              default:
                setError('Registration failed. Please try again');
                break;
            }
            setBusy(false);
          },
          (_) {
            setBusy(false);
            _navigationService.clearStackAndShow(Routes.mainView);
          },
        ));
  }

  Future<void> signInWithGoogle() async {
    setBusy(true);

    return Executor.run(_authService.signInWithGoogle())
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'RegisterViewModel',
                      'signInWithGoogle()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Google sign in failed. Please try again');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _navigationService.clearStackAndShow(Routes.mainView);
              },
            ));
  }

  void navigateToLogin() {
    _navigationService.back();
  }
}
