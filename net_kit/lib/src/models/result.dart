sealed class Result<E, D> {
  const Result();

  factory Result.error(E value) = _ErrorResult<E, D>;

  factory Result.success(D value) = _SuccessResult<E, D>;

  T fold<T>({
    required T Function(D value) onSuccess,
    required T Function(E value) onError,
  });

  bool get isError;

  bool get isSuccess;

  E? get errorOrNull;

  D? get resultOrNull;
}

final class _ErrorResult<E, D> extends Result<E, D> {
  final E _error;

  const _ErrorResult(this._error);

  @override
  T fold<T>({
    required T Function(D value) onSuccess,
    required T Function(E value) onError,
  }) {
    return onError(_error);
  }

  @override
  bool get isError => true;

  @override
  bool get isSuccess => false;

  @override
  E get errorOrNull => _error;

  @override
  D? get resultOrNull => null;
}

final class _SuccessResult<E, D> extends Result<E, D> {
  final D _data;

  const _SuccessResult(this._data);

  @override
  T fold<T>({
    required T Function(D value) onSuccess,
    required T Function(E value) onError,
  }) {
    return onSuccess(_data);
  }

  @override
  bool get isError => false;

  @override
  bool get isSuccess => true;

  @override
  E? get errorOrNull => null;

  @override
  D get resultOrNull => _data;
}
