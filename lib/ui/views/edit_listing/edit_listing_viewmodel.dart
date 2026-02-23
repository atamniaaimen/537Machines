import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/app.locator.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/machine_listing.dart';
import '../../../services/listing_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/auth_service.dart';

class EditListingViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _storageService = locator<StorageService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _crashlytics = locator<CrashlyticsService>();

  final String listingId;
  EditListingViewModel({required this.listingId});

  MachineListing? _listing;
  MachineListing? get listing => _listing;

  final List<XFile> _newImages = [];
  List<XFile> get newImages => _newImages;

  final List<Uint8List> _newImageBytes = [];
  List<Uint8List> get newImageBytes => _newImageBytes;

  List<String> _existingImageUrls = [];
  List<String> get existingImageUrls => _existingImageUrls;

  int get totalImageCount => _existingImageUrls.length + _newImages.length;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedCondition;
  String? get selectedCondition => _selectedCondition;

  Future<void> init() async {
    setBusy(true);

    return Executor.run(_listingService.getListingById(listingId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'EditListingViewModel',
                      'init($listingId)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError(failure);
                setBusy(false);
              },
              (data) {
                _listing = data;
                _existingImageUrls = List.from(data.imageUrls);
                _selectedCategory = data.category;
                _selectedCondition = data.condition;
                setBusy(false);
                rebuildUi();
              },
            ));
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    rebuildUi();
  }

  void setCondition(String? condition) {
    _selectedCondition = condition;
    rebuildUi();
  }

  Future<void> pickImage() async {
    if (totalImageCount >= AppConstants.maxImages) {
      _snackbarService.showSnackbar(
        message: 'Maximum ${AppConstants.maxImages} images allowed',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      _newImages.add(image);
      _newImageBytes.add(await image.readAsBytes());
      rebuildUi();
    }
  }

  void removeExistingImage(int index) {
    _existingImageUrls.removeAt(index);
    rebuildUi();
  }

  void removeNewImage(int index) {
    _newImages.removeAt(index);
    _newImageBytes.removeAt(index);
    rebuildUi();
  }

  Future<void> deleteListing() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Delete Listing',
      description:
          'Are you sure you want to delete this listing? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (response?.confirmed != true) return;

    setBusy(true);

    return Executor.run(_listingService.deleteListing(listingId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'EditListingViewModel',
                      'deleteListing($listingId)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Failed to delete listing');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _snackbarService.showSnackbar(
                  message: 'Listing deleted',
                  duration: const Duration(seconds: 2),
                );
                _navigationService.back();
              },
            ));
  }

  Future<void> submit({
    required String title,
    required String brand,
    required String model,
    required String year,
    required String hours,
    required String description,
    required String price,
    required String location,
  }) async {
    setBusy(true);

    final user = _authService.currentUser;
    if (user == null || _listing == null) {
      setError('Unable to update listing');
      setBusy(false);
      return;
    }

    List<String> allImageUrls = List.from(_existingImageUrls);

    if (_newImages.isNotEmpty) {
      await Executor.run(_storageService.uploadListingImages(
        files: _newImages,
        userId: user.uid,
        listingId: listingId,
      )).then((result) => result.fold(
            (failure) {
              _crashlytics.logToCrashlytics(
                  Level.warning,
                  [
                    'EditListingViewModel',
                    'submit(upload)',
                    failure.toString()
                  ],
                  failure.stackTrace);
              setError('Failed to upload images');
              setBusy(false);
            },
            (urls) {
              allImageUrls.addAll(urls);
            },
          ));

      if (hasError) return;
    }

    final parsedYear = int.tryParse(year);
    final parsedHours = int.tryParse(hours);

    final updated = _listing!.copyWith(
      title: title,
      description: description,
      category: _selectedCategory,
      price: double.tryParse(price),
      condition: _selectedCondition,
      location: location,
      imageUrls: allImageUrls,
      brand: brand,
      model: model,
      year: parsedYear,
      clearYear: parsedYear == null && _listing!.year != null,
      hours: parsedHours,
      clearHours: parsedHours == null && _listing!.hours != null,
      updatedAt: DateTime.now(),
    );

    return Executor.run(_listingService.updateListing(updated))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'EditListingViewModel',
                      'submit(update)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Failed to update listing');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _snackbarService.showSnackbar(
                  message: 'Listing updated successfully!',
                  duration: const Duration(seconds: 2),
                );
                _navigationService.back();
              },
            ));
  }
}
