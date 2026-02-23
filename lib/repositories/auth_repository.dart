import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/error_handling/failure.dart';
import '../core/error_handling/failures/general_failure.dart';
import '../core/error_handling/failures/auth_failure.dart';

/// Primitive adapter for Firebase Auth.
/// Single responsibility: authentication operations.
/// Catches FirebaseAuthException and throws typed AuthFailures.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _lazyGoogleSignIn;
  GoogleSignIn get _googleSignIn => _lazyGoogleSignIn ??= GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, s) {
      throw _mapAuthException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<UserCredential> createAccountWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, s) {
      throw _mapAuthException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure(AuthFailureType.error,
            description: 'Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, s) {
      throw _mapAuthException(e, s);
    } on SocketException catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.socketException, e.toString(), s);
    } catch (e, s) {
      if (e is Failure) rethrow;
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on FirebaseAuthException catch (e, s) {
      throw _mapAuthException(e, s);
    } catch (e, s) {
      throw GeneralFailure(
          GeneralFailureType.unexpectedError, e.toString(), s);
    }
  }

  Failure _mapAuthException(FirebaseAuthException e, StackTrace s) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return AuthFailure(AuthFailureType.invalidCredentials,
            description: e.message, stackTrace: s);
      case 'user-not-found':
        return AuthFailure(AuthFailureType.userNotFound,
            description: e.message, stackTrace: s);
      case 'user-disabled':
        return AuthFailure(AuthFailureType.userDisabled,
            description: e.message, stackTrace: s);
      case 'email-already-in-use':
        return AuthFailure(AuthFailureType.emailAlreadyInUse,
            description: e.message, stackTrace: s);
      case 'weak-password':
        return AuthFailure(AuthFailureType.weakPassword,
            description: e.message, stackTrace: s);
      case 'too-many-requests':
        return AuthFailure(AuthFailureType.tooManyRequests,
            description: e.message, stackTrace: s);
      default:
        return AuthFailure(AuthFailureType.error,
            description: '${e.code}: ${e.message}', stackTrace: s);
    }
  }
}
