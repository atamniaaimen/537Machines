import 'dart:io';
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

  File? _pickedAvatar;
  File? get pickedAvatar => _pickedAvatar;

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      _pickedAvatar = File(image.path);
      rebuildUi();
    }
  }

  Future<void> save({
    required String firstName,
    required String lastName,
    required String company,
    required String phone,
    required String location,
    required String bio,
  }) async {
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
      firstName: firstName,
      lastName: lastName,
      company: company,
      phone: phone,
      location: location,
      bio: bio,
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
