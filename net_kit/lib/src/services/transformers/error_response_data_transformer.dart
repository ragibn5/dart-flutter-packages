import 'package:net_kit/net_kit.dart';

abstract interface class ErrorResponseDataTransformer {
  Result<ParseException, E> transform<E>(
    dynamic data,
    ErrorResponseDataDecoder<E> decoder,
  );
}

class DefaultErrorResponseDataTransformer
    implements ErrorResponseDataTransformer {
  const DefaultErrorResponseDataTransformer();

  @override
  Result<ParseException, E> transform<E>(
    dynamic data,
    ErrorResponseDataDecoder<E> decoder,
  ) {
    try {
      return Result.success(decoder.decodeErrorData(data));
    } catch (e, st) {
      return Result.error(
        ParseException(
          targetType: ParseTargetType.ERROR_DECODE,
          data: data,
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
