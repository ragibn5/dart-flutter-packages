import 'package:equatable/equatable.dart';

enum _ResultType { error, success }

class Result<E, D> extends Equatable {
  final _ResultType _type;

  final D? _data;
  final E? _error;

  const Result._({required _ResultType type, D? data, E? error})
    : _error = error,
      _data = data,
      _type = type;

  /// Factory constructor for E
  factory Result.failure(E error) {
    return Result._(type: _ResultType.error, error: error);
  }

  /// Factory constructor for D
  factory Result.success(D data) {
    return Result._(type: _ResultType.success, data: data);
  }

  /// Fold method to handle different types
  T fold<T>({
    required T Function(D data) onSuccess,
    required T Function(E error) onFailure,
  }) {
    switch (_type) {
      case _ResultType.error:
        return onFailure(_error as E);
      case _ResultType.success:
        return onSuccess(_data as D);
    }
  }

  bool get isError => _type == _ResultType.error;

  bool get isSuccess => _type == _ResultType.success;

  E? get errorOrNull => _error;

  D? get dataOrNull => _data;

  @override
  List<Object?> get props => [_type, _data, _error];
}
