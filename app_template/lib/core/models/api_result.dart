import 'package:equatable/equatable.dart';

enum _ApiResultType { error, success }

class ApiResult<E, D> extends Equatable {
  final _ApiResultType _type;

  final D? _data;
  final E? _error;

  const ApiResult._({required _ApiResultType type, D? data, E? error})
    : _error = error,
      _data = data,
      _type = type;

  /// Factory constructor for E
  factory ApiResult.failure(E error) {
    return ApiResult._(type: _ApiResultType.error, error: error);
  }

  /// Factory constructor for D
  factory ApiResult.success(D data) {
    return ApiResult._(type: _ApiResultType.success, data: data);
  }

  /// Fold method to handle different types
  T fold<T>({
    required T Function(D data) onSuccess,
    required T Function(E error) onFailure,
  }) {
    switch (_type) {
      case _ApiResultType.error:
        return onFailure(_error as E);
      case _ApiResultType.success:
        return onSuccess(_data as D);
    }
  }

  bool get isError => _type == _ApiResultType.error;

  bool get isSuccess => _type == _ApiResultType.success;

  E? get errorOrNull => _error;

  D? get dataOrNull => _data;

  @override
  List<Object?> get props => [_type, _data, _error];
}
