enum _ResultType { SUCCESS, EXCEPTION }

class Result<T> {
  final _ResultType _type;

  final T? _value;

  final Object? _exception;
  final StackTrace? _stackTrace;

  Result._(this._type, this._value, this._exception, this._stackTrace);

  factory Result.success(T value) =>
      Result._(_ResultType.SUCCESS, value, null, null);

  factory Result.exception(Object exception, [StackTrace? stackTrace]) =>
      Result._(_ResultType.EXCEPTION, null, exception, stackTrace);

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object exception, StackTrace? stackTrace) onException,
  }) {
    return switch (this._type) {
      _ResultType.SUCCESS => onSuccess(this._value as T),
      _ResultType.EXCEPTION => onException(this._exception!, this._stackTrace),
    };
  }

  bool get isSuccess => _type == _ResultType.SUCCESS;

  bool get isException => _type == _ResultType.EXCEPTION;
}
