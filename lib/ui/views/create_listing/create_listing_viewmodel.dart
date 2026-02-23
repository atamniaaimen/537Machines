import 'dart:io';
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

class CreateListingViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _storageService = locator<StorageService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _crashlytics = locator<CrashlyticsService>();

  final List<File> _pickedImages = [];
  List<File> get pickedImages => _pickedImages;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedCondition;
  String? get selectedCondition => _selectedCondition;

  void setCategory(String? category) {
    _selectedCategory = category;
    rebuildUi();
  }

  void setCondition(String? condition) {
    _selectedCondition = condition;
    rebuildUi();
  }

  Future<void> pickImage() async {
    if (_pickedImages.length >= AppConstants.maxImages) {
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
      _pickedImages.add(File(image.path));
      rebuildUi();
    }
  }

  void removeImage(int index) {
    _pickedImages.removeAt(index);
    rebuildUi();
  }

  Future<void> submit({
    required String title,
    required String brand,
    required String model,
    required String year,
    required String description,
    required String price,
    required String location,
  }) async {
    setBusy(true);

    final user = _authService.currentUser;
    if (user == null) {
      setError('You must be logged in to create a listing');
      setBusy(false);
      return;
    }

    final now = DateTime.now();
    final tempListingId = now.millisecondsSinceEpoch.toString();

    // Upload images first
    List<String> imageUrls = [];
    if (_pickedImages.isNotEmpty) {
      await Executor.run(_storageService.uploadListingImages(
        files: _pickedImages,
        userId: user.uid,
        listingId: tempListingId,
      )).then((result) => result.fold(
            (failure) {
              _crashlytics.logToCrashlytics(
                  Level.warning,
                  [
                    'CreateListingViewModel',
                    'submit(upload)',
                    failure.toString()
                  ],
                  failure.stackTrace);
              setError('Failed to upload images');
              setBusy(false);
            },
            (urls) {
              imageUrls = urls;
            },
          ));

      if (hasError) return;
    }

    final listing = MachineListing(
      id: '',
      sellerId: user.uid,
      sellerName: user.displayName,
      title: title,
      description: description,
      category: _selectedCategory ?? 'Other',
      price: double.tryParse(price) ?? 0,
      condition: _selectedCondition ?? 'New',
      location: location,
      imageUrls: imageUrls,
      brand: brand,
      model: model,
      year: int.tryParse(year),
      createdAt: now,
      updatedAt: now,
    );

    return Executor.run(_listingService.createListing(listing))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'CreateListingViewModel',
                      'submit(create)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Failed to create listing');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _snackbarService.showSnackbar(
                  message: 'Listing created successfully!',
                  duration: const Duration(seconds: 2),
                );
                _navigationService.back();
              },
            ));
  }
}
