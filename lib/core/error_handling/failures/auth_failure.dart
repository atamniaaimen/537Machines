import '../failure.dart';

class AuthFailure extends Failure {
  AuthFailure(AuthFailureType type,
      {String? description, StackTrace? stackTrace, args})
      : super(type, description, stackTrace, args);
}

enum AuthFailureType {
  invalidCredentials,
  userNotFound,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  tokenExpired,
  error,
}
