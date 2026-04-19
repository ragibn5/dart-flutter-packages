import 'package:equatable/equatable.dart';

abstract class NetworkError extends Equatable {
  final Object? cause;
  final StackTrace? stackTrace;

  const NetworkError(this.cause, this.stackTrace);
}
