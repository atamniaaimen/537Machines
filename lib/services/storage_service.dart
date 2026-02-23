import 'dart:io';
import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../repositories/storage_repository.dart';

class StorageService {
  final _storageRepo = locator<StorageRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  Future<List<String>> uploadListingImages({
    required List<File> files,
    required String userId,
    required String listingId,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final path =
          '${FirebaseConstants.machineImagesPath}/$userId/$listingId/image_$i.jpg';

      await Executor.run(_storageRepo.uploadFile(
        path: path,
        file: files[i],
      )).then((result) => result.fold(
            (failure) {
              _crashlytics.logToCrashlytics(
                  Level.warning,
                  [
                    'StorageService',
                    'uploadListingImages(image_$i)',
                    failure.toString()
                  ],
                  failure.stackTrace);
              throw failure;
            },
            (url) {
              urls.add(url);
            },
          ));
    }

    return urls;
  }

  Future<void> deleteListingImages({
    required String userId,
    required String listingId,
  }) async {
    final path =
        '${FirebaseConstants.machineImagesPath}/$userId/$listingId';

    await Executor.run(_storageRepo.listFiles(path))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'StorageService',
                      'deleteListingImages(list)',
                      failure.toString()
                    ],
                    failure.stackTrace);
                // Silently handle — images may not exist
              },
              (refs) async {
                for (final ref in refs) {
                  await Executor.run(_storageRepo.deleteFile(ref.fullPath))
                      .then((result) => result.fold(
                            (failure) {
                              _crashlytics.logToCrashlytics(
                                  Level.warning,
                                  [
                                    'StorageService',
                                    'deleteListingImages(delete)',
                                    failure.toString()
                                  ],
                                  failure.stackTrace);
                              // Silently handle individual delete failures
                            },
                            (_) {},
                          ));
                }
              },
            ));
  }

  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) {
    final path = '${FirebaseConstants.avatarImagesPath}/$userId/avatar.jpg';

    return Executor.run(_storageRepo.uploadFile(
      path: path,
      file: file,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['StorageService', 'uploadAvatar()', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (url) => url,
        ));
  }
}
