import 'package:logger/logger.dart';

class CrashlyticsService {
  final _logger = Logger();

  void logToCrashlytics(
      Level level, List<String> context, StackTrace stackTrace) {
    switch (level) {
      case Level.error:
        _logger.e(context.join(' | '), stackTrace: stackTrace);
        break;
      case Level.warning:
        _logger.w(context.join(' | '));
        break;
      case Level.info:
        _logger.i(context.join(' | '));
        break;
      default:
        _logger.d(context.join(' | '));
    }
  }
}
