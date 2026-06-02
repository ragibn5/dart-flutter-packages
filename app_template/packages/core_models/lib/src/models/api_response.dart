import 'package:core_models/src/models/either.dart';

sealed class ApiResponse<Err, Res> {
  final int statusCode;
  final Map<String, List<String>>? headers;

  ApiResponse({required this.statusCode, required this.headers});

  T fold<T>({
    required T Function(Err) onFailure,
    required T Function(Res) onSuccess,
  }) {
    final self = this;
    return switch (self) {
      Failure<Err>() => onFailure(self.error),
      Success<Res>() => onSuccess(self.data),
      _ => throw StateError(
          'Invalid state: should have been either $Failure, or $Success',
        ),
    };
  }

  Either<Err, Res> toEither() =>
      fold(onFailure: Left.new, onSuccess: Right.new);
}

final class Success<Res> extends ApiResponse<Never, Res> {
  final Res data;

  Success({
    required this.data,
    required super.statusCode,
    required super.headers,
  });
}

final class Failure<Err> extends ApiResponse<Err, Never> {
  final Err error;

  Failure({
    required this.error,
    required super.statusCode,
    required super.headers,
  });
}
