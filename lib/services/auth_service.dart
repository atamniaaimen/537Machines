import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firestore_repository.dart';

class AuthService with ListenableServiceMixin {
  final _authRepo = locator<AuthRepository>();
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  final ReactiveValue<AppUser?> _currentUser = ReactiveValue<AppUser?>(null);
  AppUser? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;

  AuthService() {
    listenToReactiveValues([_currentUser]);
  }

  Future<void> signIn(String email, String password) {
    return Executor.run(_authRepo.signInWithEmail(email, password))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    ['AuthService', 'signIn()', failure.toString()],
                    failure.stackTrace);
                throw failure;
              },
              (credential) async {
                await _loadUserDoc(credential.user!.uid);

                // If no Firestore doc, create one
                if (_currentUser.value == null) {
                  final firebaseUser = credential.user!;
                  final nameParts =
                      (firebaseUser.displayName ?? '').split(' ');
                  final user = AppUser(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? '',
                    firstName:
                        nameParts.isNotEmpty ? nameParts.first : '',
                    lastName: nameParts.length > 1
                        ? nameParts.sublist(1).join(' ')
                        : '',
                    photoUrl: firebaseUser.photoURL ?? '',
                    createdAt: DateTime.now(),
                  );

                  await Executor.run(_firestoreRepo.setDocument(
                    collection: FirebaseConstants.usersCollection,
                    id: firebaseUser.uid,
                    data: user.toJson(),
                  )).then((result) => result.fold(
                        (failure) {
                          _crashlytics.logToCrashlytics(
                              Level.warning,
                              [
                                'AuthService',
                                'signIn(createDoc)',
                                failure.toString()
                              ],
                              failure.stackTrace);
                          throw failure;
                        },
                        (_) {
                          _currentUser.value = user;
                        },
                      ));
                }
              },
            ));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String company = '',
  }) {
    return Executor.run(_authRepo.createAccountWithEmail(email, password))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    ['AuthService', 'signUp()', failure.toString()],
                    failure.stackTrace);
                throw failure;
              },
              (credential) async {
                final user = AppUser(
                  uid: credential.user!.uid,
                  email: email,
                  firstName: firstName,
                  lastName: lastName,
                  company: company,
                  createdAt: DateTime.now(),
                );

                await Executor.run(_firestoreRepo.setDocument(
                  collection: FirebaseConstants.usersCollection,
                  id: credential.user!.uid,
                  data: user.toJson(),
                )).then((result) => result.fold(
                      (failure) {
                        _crashlytics.logToCrashlytics(
                            Level.warning,
                            [
                              'AuthService',
                              'signUp(createDoc)',
                              failure.toString()
                            ],
                            failure.stackTrace);
                        throw failure;
                      },
                      (_) {
                        _currentUser.value = user;
                      },
                    ));
              },
            ));
  }

  Future<void> signInWithGoogle() {
    return Executor.run(_authRepo.signInWithGoogle())
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    ['AuthService', 'signInWithGoogle()', failure.toString()],
                    failure.stackTrace);
                throw failure;
              },
              (credential) async {
                final firebaseUser = credential.user!;
                final existingDoc =
                    await _tryGetUserDoc(firebaseUser.uid);

                if (existingDoc != null) {
                  _currentUser.value = existingDoc;
                } else {
                  final nameParts =
                      (firebaseUser.displayName ?? '').split(' ');
                  final user = AppUser(
                    uid: firebaseUser.uid,
                    email: firebaseUser.email ?? '',
                    firstName: nameParts.isNotEmpty ? nameParts.first : '',
                    lastName: nameParts.length > 1
                        ? nameParts.sublist(1).join(' ')
                        : '',
                    photoUrl: firebaseUser.photoURL ?? '',
                    createdAt: DateTime.now(),
                  );

                  await Executor.run(_firestoreRepo.setDocument(
                    collection: FirebaseConstants.usersCollection,
                    id: firebaseUser.uid,
                    data: user.toJson(),
                  )).then((result) => result.fold(
                        (failure) {
                          _crashlytics.logToCrashlytics(
                              Level.warning,
                              [
                                'AuthService',
                                'signInWithGoogle(createDoc)',
                                failure.toString()
                              ],
                              failure.stackTrace);
                          throw failure;
                        },
                        (_) {
                          _currentUser.value = user;
                        },
                      ));
                }
              },
            ));
  }

  Future<void> signOut() {
    return Executor.run(_authRepo.signOut()).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['AuthService', 'signOut()', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (_) {
            _currentUser.value = null;
          },
        ));
  }

  Future<void> tryAutoLogin() async {
    final firebaseUser = _authRepo.currentUser;
    if (firebaseUser == null) return;
    await _loadUserDoc(firebaseUser.uid);

    // If Firestore doc didn't exist, create one from Firebase Auth data
    if (_currentUser.value == null) {
      final nameParts = (firebaseUser.displayName ?? '').split(' ');
      final user = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: nameParts.isNotEmpty ? nameParts.first : '',
        lastName:
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        photoUrl: firebaseUser.photoURL ?? '',
        createdAt: DateTime.now(),
      );

      await Executor.run(_firestoreRepo.setDocument(
        collection: FirebaseConstants.usersCollection,
        id: firebaseUser.uid,
        data: user.toJson(),
      )).then((result) => result.fold(
            (failure) {
              _crashlytics.logToCrashlytics(
                  Level.warning,
                  [
                    'AuthService',
                    'tryAutoLogin(createDoc)',
                    failure.toString()
                  ],
                  failure.stackTrace);
            },
            (_) {
              _currentUser.value = user;
            },
          ));
    }
  }

  Future<void> _loadUserDoc(String uid) {
    return Executor.run(_firestoreRepo.getDocument(
      collection: FirebaseConstants.usersCollection,
      id: uid,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['AuthService', '_loadUserDoc($uid)', failure.toString()],
                failure.stackTrace);
            throw failure;
          },
          (data) {
            if (data != null) {
              _currentUser.value = AppUser.fromJson(data, id: uid);
            }
          },
        ));
  }

  Future<AppUser?> _tryGetUserDoc(String uid) async {
    AppUser? user;
    await Executor.run(_firestoreRepo.getDocument(
      collection: FirebaseConstants.usersCollection,
      id: uid,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['AuthService', '_tryGetUserDoc($uid)', failure.toString()],
                failure.stackTrace);
          },
          (data) {
            if (data != null) {
              user = AppUser.fromJson(data, id: uid);
            }
          },
        ));
    return user;
  }
}
