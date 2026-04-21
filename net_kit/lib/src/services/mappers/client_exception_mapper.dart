import 'package:net_kit/src/models/decoded_error_response.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';

abstract interface class ClientExceptionMapper {
  Result<NetKitException, DecodedErrorResponse<DomainErrorType>>
      mapException<DomainErrorType>(
    Object exception, {
    StackTrace? stackTrace,
    required DomainErrorType Function(dynamic) errorDecoder,
  });
}
