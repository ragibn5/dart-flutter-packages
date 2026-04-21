import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/models/result.dart';

abstract interface class ClientExceptionMapper {
  Result<NetClientException, ErrorResponseData<DomainErrorType>>
      mapException<DomainErrorType>(
    Object exception, {
    StackTrace? stackTrace,
    required DomainErrorType Function(dynamic) errorDecoder,
  });
}
