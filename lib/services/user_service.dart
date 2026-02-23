import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/error_handling/failures/data_failure.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../models/app_user.dart';
import '../repositories/firestore_repository.dart';

class UserService {
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  Future<AppUser> getUser(String uid) {
    return Executor.run(_firestoreRepo.getDocument(
      collection: FirebaseConstants.usersCollection,
      id: uid,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['UserService', 'getUser($uid)', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (data) {
            if (data == null) {
              throw DataFailure(DataFailureType.notFound,
                  description: 'User $uid not found',
                  stackTrace: StackTrace.current);
            }
            return AppUser.fromJson(data, id: uid);
          },
        ));
  }

  Future<void> updateUser(AppUser user) {
    return Executor.run(_firestoreRepo.setDocument(
      collection: FirebaseConstants.usersCollection,
      id: user.uid,
      data: user.toJson(),
      merge: true,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'UserService',
                  'updateUser(${user.uid})',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }
}
