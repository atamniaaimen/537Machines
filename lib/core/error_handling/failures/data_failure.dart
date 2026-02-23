import '../failure.dart';

class DataFailure extends Failure {
  DataFailure(DataFailureType type,
      {String? description, StackTrace? stackTrace, args})
      : super(type, description, stackTrace, args);
}

enum DataFailureType {
  notFound,
  permissionDenied,
  alreadyExists,
  resourceExhausted,
  unavailable,
  cancelled,
  uploadFailed,
  deleteFailed,
  requestFailed,
}
