import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../app/app.bottomsheets.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/error_handling/failures/general_failure.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/machine_listing.dart';
import '../../../models/listing_filter.dart';
import '../../../services/listing_service.dart';
import '../../../services/auth_service.dart';

class ListingsViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _crashlytics = locator<CrashlyticsService>();

  List<MachineListing> _listings = [];
  List<MachineListing> get listings => _listings;

  ListingFilter _filter = const ListingFilter();
  ListingFilter get filter => _filter;

  bool get hasActiveFilters => !_filter.isEmpty;

  String get userInitials => _authService.currentUser?.initials ?? '?';
  String? get userPhotoUrl {
    final url = _authService.currentUser?.photoUrl;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  // Category tags for horizontal chips
  List<String> get categoryTags => ['All', ...AppConstants.categories];

  String _selectedCategoryTag = 'All';
  String get selectedCategoryTag => _selectedCategoryTag;

  Future<void> init() async {
    await _loadListings();
  }

  Future<void> _loadListings() async {
    setBusy(true);

    return Executor.run(
            _listingService.getListings(filter: _filter))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ListingsViewModel',
                      '_loadListings()',
                      failure.toString()
                    ],
                    failure.stackTrace);

                switch (failure.type) {
                  case GeneralFailureType.socketException:
                    setError('No internet connection');
                    break;
                  default:
                    setError('Could not load listings');
                    break;
                }
                setBusy(false);
              },
              (data) {
                _listings = data;
                setBusy(false);
                rebuildUi();
              },
            ));
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _filter = _filter.copyWith(clearSearch: true);
    } else {
      _filter = _filter.copyWith(searchQuery: query);
    }
    await _loadListings();
  }

  Future<void> selectCategoryTag(String tag) async {
    _selectedCategoryTag = tag;
    if (tag == 'All') {
      _filter = _filter.copyWith(clearCategory: true);
    } else {
      _filter = _filter.copyWith(category: tag);
    }
    rebuildUi();
    await _loadListings();
  }

  Future<void> showFilterSheet() async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.filter,
      title: 'Filter Listings',
      data: _filter,
      isScrollControlled: true,
    );
    if (response?.confirmed == true && response?.data != null) {
      _filter = response!.data as ListingFilter;
      // Sync category tag with filter
      _selectedCategoryTag = _filter.category ?? 'All';
      await _loadListings();
    }
  }

  Future<void> clearFilters() async {
    _filter = const ListingFilter();
    _selectedCategoryTag = 'All';
    await _loadListings();
  }

  void openListingDetail(String listingId) {
    _navigationService.navigateTo(
      Routes.listingDetailView,
      arguments: ListingDetailViewArguments(listingId: listingId),
    );
  }

  Future<void> refresh() async {
    await _loadListings();
  }
}
