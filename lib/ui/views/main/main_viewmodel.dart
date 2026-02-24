import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';

class MainViewModel extends IndexTrackingViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();

  AppUser? get currentUser => _authService.currentUser;

  void navigateToSettings() {
    _navigationService.navigateTo(Routes.settingsView);
  }

  void navigateToNotifications() {
    _navigationService.navigateTo(Routes.notificationsView);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _navigationService.clearStackAndShow(Routes.loginView);
  }
}
