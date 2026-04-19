import 'package:app_template/core/infrastructure/network/models/network_error.dart';

class ServerError<T> extends NetworkError {
  final int statusCode;
  final Map<String, List<String>> responseHeader;

  final T data;

  const ServerError({
    required this.statusCode,
    required this.responseHeader,
    required this.data,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(cause, stackTrace);

  @override
  List<Object?> get props => [
    statusCode,
    responseHeader,
    data,
    cause,
    stackTrace,
  ];
}
