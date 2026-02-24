import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../repositories/firestore_repository.dart';

class FavoriteService {
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  Future<void> addFavorite(String userId, String listingId) {
    return Executor.run(_firestoreRepo.setDocument(
      collection:
          '${FirebaseConstants.usersCollection}/$userId/favorites',
      id: listingId,
      data: {'addedAt': Timestamp.now()},
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'FavoriteService',
                  'addFavorite($userId, $listingId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }

  Future<void> removeFavorite(String userId, String listingId) {
    return Executor.run(_firestoreRepo.deleteDocument(
      collection:
          '${FirebaseConstants.usersCollection}/$userId/favorites',
      id: listingId,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'FavoriteService',
                  'removeFavorite($userId, $listingId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }

  Future<List<String>> getFavoriteIds(String userId) {
    return Executor.run(_firestoreRepo.getCollection(
      collection:
          '${FirebaseConstants.usersCollection}/$userId/favorites',
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'FavoriteService',
                  'getFavoriteIds($userId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docs) => docs.map((d) => d['id'] as String).toList(),
        ));
  }

  Future<bool> isFavorite(String userId, String listingId) {
    return Executor.run(_firestoreRepo.getDocument(
      collection:
          '${FirebaseConstants.usersCollection}/$userId/favorites',
      id: listingId,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'FavoriteService',
                  'isFavorite($userId, $listingId)',
                  failure.toString()
                ],
                failure.stackTrace);
            return false;
          },
          (data) => data != null,
        ));
  }
}
