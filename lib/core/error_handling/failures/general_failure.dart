import '../failure.dart';

class GeneralFailure extends Failure {
  GeneralFailure(
      GeneralFailureType type, String description, StackTrace stackTrace,
      {args})
      : super(type, description, stackTrace, args);
}

enum GeneralFailureType {
  internetConnectionError,
  unexpectedError,
  formatError,
  socketException,
  platformError,
  jsonConversionError,
  timeoutError,
}
