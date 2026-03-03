enum _ResultType {
  error,
  success;
}

class Result<E, D> {
  final _ResultType _type;

  final D? _data;
  final E? _error;

  Result._({
    required _ResultType typeId,
    D? data,
    E? error,
  })  : _type = typeId,
        _data = data,
        _error = error;

  /// Factory constructor for E
  factory Result.error(E value) {
    return Result._(typeId: _ResultType.error, error: value);
  }

  /// Factory constructor for D
  factory Result.data(D value) {
    return Result._(typeId: _ResultType.success, data: value);
  }

  /// Fold method to handle different types
  T fold<T>({
    required T Function(D value) onSuccess,
    required T Function(E value) onError,
  }) {
    switch (_type) {
      case _ResultType.error:
        return onError(_error as E);
      case _ResultType.success:
        return onSuccess(_data as D);
    }
  }

  bool get isError => _type == _ResultType.error;

  bool get isSuccess => _type == _ResultType.success;

  E? get errorOrNull => _error;

  D? get resultOrNull => _data;
}
