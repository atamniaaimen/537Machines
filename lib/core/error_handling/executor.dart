import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../app/app.locator.dart';
import '../services/crashlytics_service.dart';
import 'failure.dart';
import 'failures/general_failure.dart';

class Executor<T> {
  static Future<Either<Failure, T>> run<T>(Future<T> f) => Task<T>(() => f)
      .attempt()
      .map((a) => a.leftMap((obj) {
            if (obj is Failure) {
              return obj;
            } else {
              locator<CrashlyticsService>().logToCrashlytics(
                  Level.error,
                  ['Executor Caught Exception', obj.toString()],
                  StackTrace.current);

              return GeneralFailure(GeneralFailureType.unexpectedError,
                  obj.toString(), StackTrace.current);
            }
          }))
      .run();
}
