import 'package:core_models/src/enums/transport_error_type.dart';
import 'package:equatable/equatable.dart';

sealed class ApiError {
  const ApiError();
}

class TransportError extends ApiError with EquatableMixin {
  final TransportErrorType type;

  const TransportError({required this.type});

  @override
  List<Object?> get props => [type];
}

class CancellationError extends ApiError with EquatableMixin {
  final String source;
  final String? message;

  const CancellationError({required this.source, this.message});

  @override
  List<Object?> get props => [source, message];
}

class UnexpectedError extends ApiError with EquatableMixin {
  final Object? cause;
  final StackTrace? stackTrace;

  const UnexpectedError({required this.cause, required this.stackTrace});

  @override
  List<Object?> get props => [cause, stackTrace];
}
