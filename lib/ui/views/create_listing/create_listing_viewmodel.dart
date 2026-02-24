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

class CreateListingViewModel extends BaseViewModel {
  final _listingService = locator<ListingService>();
  final _storageService = locator<StorageService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _crashlytics = locator<CrashlyticsService>();

  final List<XFile> _pickedImages = [];
  List<XFile> get pickedImages => _pickedImages;

  final List<Uint8List> _pickedImageBytes = [];
  List<Uint8List> get pickedImageBytes => _pickedImageBytes;

  // Form values stored as plain strings (no Flutter imports)
  String _title = '';
  String _brand = '';
  String _model = '';
  String _year = '';
  String _price = '';
  String _location = '';
  String _description = '';

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedCondition;
  String? get selectedCondition => _selectedCondition;

  bool _isNegotiable = false;
  bool get isNegotiable => _isNegotiable;

  bool _acceptsOffers = true;
  bool get acceptsOffers => _acceptsOffers;

  String _serialNumber = '';

  void setTitle(String v) => _title = v;
  void setBrand(String v) => _brand = v;
  void setModel(String v) => _model = v;
  void setYear(String v) => _year = v;
  void setPrice(String v) => _price = v;
  void setLocation(String v) => _location = v;
  void setDescription(String v) => _description = v;
  void setSerialNumber(String v) => _serialNumber = v;

  void toggleNegotiable() {
    _isNegotiable = !_isNegotiable;
    rebuildUi();
  }

  void toggleAcceptsOffers() {
    _acceptsOffers = !_acceptsOffers;
    rebuildUi();
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
      _pickedImages.add(image);
      _pickedImageBytes.add(await image.readAsBytes());
      rebuildUi();
    }
  }

  void removeImage(int index) {
    _pickedImages.removeAt(index);
    _pickedImageBytes.removeAt(index);
    rebuildUi();
  }

  Future<void> submit() async {
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
      title: _title.trim(),
      description: _description.trim(),
      category: _selectedCategory ?? 'Other',
      price: double.tryParse(_price.trim()) ?? 0,
      condition: _selectedCondition ?? 'New',
      location: _location.trim(),
      imageUrls: imageUrls,
      brand: _brand.trim(),
      model: _model.trim(),
      year: int.tryParse(_year.trim()),
      isNegotiable: _isNegotiable,
      acceptsOffers: _acceptsOffers,
      serialNumber: _serialNumber.trim(),
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
