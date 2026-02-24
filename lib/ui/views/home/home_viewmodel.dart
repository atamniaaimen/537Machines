import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/machine_listing.dart';
import '../../../services/listing_service.dart';

class HomeViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _navigationService = locator<NavigationService>();
  final _crashlytics = locator<CrashlyticsService>();

  List<MachineListing> _featuredListings = [];
  List<MachineListing> get featuredListings => _featuredListings;

  List<MachineListing> _recentListings = [];
  List<MachineListing> get recentListings => _recentListings;

  List<String> get categories => AppConstants.categories;

  Future<void> init() async {
    setBusy(true);
    await Future.wait([_loadFeatured(), _loadRecent()]);
    setBusy(false);
  }

  Future<void> _loadFeatured() async {
    return Executor.run(_listingService.getListings(limit: 6))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'HomeViewModel',
                      '_loadFeatured()',
                      failure.toString()
                    ],
                    failure.stackTrace);
              },
              (data) {
                _featuredListings = data;
              },
            ));
  }

  Future<void> _loadRecent() async {
    return Executor.run(_listingService.getListings(limit: 4))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    ['HomeViewModel', '_loadRecent()', failure.toString()],
                    failure.stackTrace);
              },
              (data) {
                _recentListings = data;
              },
            ));
  }

  void onListingTapped(String listingId) {
    _navigationService.navigateTo(
      Routes.listingDetailView,
      arguments: ListingDetailViewArguments(listingId: listingId),
    );
  }

  void onSearchSubmitted(String query) {
    _navigationService.navigateTo(Routes.searchView);
  }

  void onCategoryTapped(String category) {
    _navigationService.navigateTo(Routes.searchView);
  }

  void navigateToCreateListing() {
    _navigationService.navigateTo(Routes.createListingView);
  }
}
