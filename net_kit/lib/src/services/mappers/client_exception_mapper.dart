import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';

abstract interface class ClientExceptionMapper {
  Result<NetKitException, ErrorResponseData<DomainErrorType>>
      mapException<DomainErrorType>(
    Object exception, {
    StackTrace? stackTrace,
    required ErrorResponseDataDecoder<DomainErrorType> errorResponseDataDecoder,
  });
}
