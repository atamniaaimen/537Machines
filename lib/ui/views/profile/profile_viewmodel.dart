import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/app_user.dart';
import '../../../models/machine_listing.dart';
import '../../../services/auth_service.dart';
import '../../../services/listing_service.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _authService = locator<AuthService>();
  final _listingService = locator<ListingService>();
  final _navigationService = locator<NavigationService>();
  final _crashlytics = locator<CrashlyticsService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_authService];

  AppUser? get currentUser => _authService.currentUser;

  List<MachineListing> _myListings = [];
  List<MachineListing> get myListings => _myListings;

  Future<void> init() async {
    if (currentUser == null) return;
    await _loadMyListings();
  }

  Future<void> _loadMyListings() async {
    setBusy(true);

    return Executor.run(
            _listingService.getListingsBySeller(currentUser!.uid))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ProfileViewModel',
                      '_loadMyListings()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Could not load your listings');
                setBusy(false);
              },
              (data) {
                _myListings = data;
                setBusy(false);
                rebuildUi();
              },
            ));
  }

  void navigateToEditProfile() {
    _navigationService.navigateTo(Routes.editProfileView);
  }

  void openListingDetail(String listingId) {
    _navigationService.navigateTo(
      Routes.listingDetailView,
      arguments: ListingDetailViewArguments(listingId: listingId),
    );
  }

  void navigateToCreateListing() {
    _navigationService.navigateTo(Routes.createListingView);
  }

  Future<void> signOut() async {
    return Executor.run(_authService.signOut()).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['ProfileViewModel', 'signOut()', failure.toString()],
                failure.stackTrace);
          },
          (_) {
            _navigationService.clearStackAndShow(Routes.loginView);
          },
        ));
  }
}
