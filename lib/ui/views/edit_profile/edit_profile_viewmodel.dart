import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/app.locator.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/storage_service.dart';

class EditProfileViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _crashlytics = locator<CrashlyticsService>();

  AppUser? get currentUser => _authService.currentUser;

  // Form values as plain strings
  String _firstName = '';
  String _lastName = '';
  String _company = '';
  String _phone = '';
  String _location = '';
  String _bio = '';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get company => _company;
  String get phone => _phone;
  String get location => _location;
  String get bio => _bio;
  String get email => currentUser?.email ?? '';

  void setFirstName(String v) => _firstName = v;
  void setLastName(String v) => _lastName = v;
  void setCompany(String v) => _company = v;
  void setPhone(String v) => _phone = v;
  void setLocation(String v) => _location = v;
  void setBio(String v) => _bio = v;

  void initFields() {
    final user = currentUser;
    if (user != null) {
      _firstName = user.firstName;
      _lastName = user.lastName;
      _company = user.company;
      _phone = user.phone;
      _location = user.location;
      _bio = user.bio;
    }
  }

  XFile? _pickedAvatar;
  XFile? get pickedAvatar => _pickedAvatar;

  Uint8List? _pickedAvatarBytes;
  Uint8List? get pickedAvatarBytes => _pickedAvatarBytes;

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      _pickedAvatar = image;
      _pickedAvatarBytes = await image.readAsBytes();
      rebuildUi();
    }
  }

  Future<void> save() async {
    if (currentUser == null) return;
    setBusy(true);

    String photoUrl = currentUser!.photoUrl;

    if (_pickedAvatar != null) {
      await Executor.run(_storageService.uploadAvatar(
        file: _pickedAvatar!,
        userId: currentUser!.uid,
      )).then((result) => result.fold(
            (failure) {
              _crashlytics.logToCrashlytics(
                  Level.warning,
                  [
                    'EditProfileViewModel',
                    'save(avatar)',
                    failure.toString()
                  ],
                  failure.stackTrace);
              // Continue with profile update even if avatar fails
            },
            (url) {
              photoUrl = url;
            },
          ));
    }

    final updatedUser = currentUser!.copyWith(
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      company: _company.trim(),
      phone: _phone.trim(),
      location: _location.trim(),
      bio: _bio.trim(),
      photoUrl: photoUrl,
    );

    return Executor.run(_userService.updateUser(updatedUser))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'EditProfileViewModel',
                      'save(update)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                setError('Failed to update profile');
                setBusy(false);
              },
              (_) {
                setBusy(false);
                _snackbarService.showSnackbar(
                  message: 'Profile updated!',
                  duration: const Duration(seconds: 2),
                );
                _navigationService.back();
              },
            ));
  }
}
