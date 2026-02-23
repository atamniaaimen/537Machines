abstract class FailureAbstract {
  final dynamic type;
  final String description;
  final StackTrace? stackTrace;
  final dynamic args;
  @override
  String toString();
  FailureAbstract(this.type, this.description, this.args, this.stackTrace);
}

class Failure implements FailureAbstract {
  late String _description;
  StackTrace? _stackTrace;
  dynamic _type;
  dynamic _args;

  @override
  Failure(
      dynamic type, String? description, StackTrace? stackTrace, dynamic args) {
    _description = description ?? "";
    _type = type;
    _stackTrace = stackTrace;
    _args = args;
  }

  @override
  String get description => _description;

  @override
  String toString() {
    return '${type.toString()} : $_description | args: $_args';
  }

  @override
  get type => _type;

  @override
  get args => _args;

  @override
  StackTrace get stackTrace => _stackTrace ?? StackTrace.current;
}
