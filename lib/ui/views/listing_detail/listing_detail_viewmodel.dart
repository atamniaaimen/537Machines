import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../app/app.dialogs.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/machine_listing.dart';
import '../../../services/listing_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/auth_service.dart';

class ListingDetailViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _storageService = locator<StorageService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _crashlytics = locator<CrashlyticsService>();

  final String listingId;
  ListingDetailViewModel({required this.listingId});

  MachineListing? _listing;
  MachineListing? get listing => _listing;

  bool get isOwner =>
      _listing != null &&
      _authService.currentUser != null &&
      _listing!.sellerId == _authService.currentUser!.uid;

  Future<void> init() async {
    setBusy(true);

    return Executor.run(_listingService.getListingById(listingId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ListingDetailViewModel',
                      'init($listingId)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError(failure);
                setBusy(false);
              },
              (data) {
                _listing = data;
                setBusy(false);
                rebuildUi();
              },
            ));
  }

  void navigateToEdit() {
    _navigationService.navigateTo(
      Routes.editListingView,
      arguments: EditListingViewArguments(listingId: listingId),
    );
  }

  Future<void> deleteListing() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.confirm,
      title: 'Delete Listing',
      description: 'Are you sure you want to delete this listing?',
    );

    if (response?.confirmed != true) return;

    setBusy(true);

    // Delete images first
    await Executor.run(_storageService.deleteListingImages(
      userId: _listing!.sellerId,
      listingId: listingId,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'ListingDetailViewModel',
                  'deleteListing(images)',
                  failure.toString()
                ],
                failure.stackTrace);
            // Continue with listing delete even if image delete fails
          },
          (_) {},
        ));

    return Executor.run(_listingService.deleteListing(listingId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'ListingDetailViewModel',
                      'deleteListing()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Could not delete listing');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _navigationService.back();
              },
            ));
  }
}
