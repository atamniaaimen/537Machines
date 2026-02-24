import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/error_handling/failures/auth_failure.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _crashlytics = locator<CrashlyticsService>();

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String _email = '';
  String _password = '';

  void setEmail(String v) => _email = v;
  void setPassword(String v) => _password = v;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    rebuildUi();
  }

  Future<void> signIn() async {
    setBusy(true);

    return Executor.run(_authService.signIn(_email.trim(), _password))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    ['LoginViewModel', 'signIn()', failure.toString()],
                    failure.stackTrace);

                switch (failure.type) {
                  case AuthFailureType.invalidCredentials:
                    setError('Invalid email or password');
                    break;
                  case AuthFailureType.userNotFound:
                    setError('No account found with this email');
                    break;
                  case AuthFailureType.tooManyRequests:
                    setError('Too many attempts. Please try again later');
                    break;
                  default:
                    setError('Sign in failed. Please try again');
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
                      'LoginViewModel',
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

  void navigateToRegister() {
    _navigationService.navigateTo(Routes.registerView);
  }
}
