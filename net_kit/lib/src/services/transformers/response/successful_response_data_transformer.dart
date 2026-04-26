import 'package:net_kit/net_kit.dart';

abstract interface class SuccessfulResponseDataTransformer {
  Result<ParseException, D> transform<D>(
    dynamic data,
    ResponseDataDecoder<D> decoder,
  );
}

class DefaultSuccessfulResponseDataTransformer
    implements SuccessfulResponseDataTransformer {
  const DefaultSuccessfulResponseDataTransformer();

  @override
  Result<ParseException, D> transform<D>(
    dynamic data,
    ResponseDataDecoder<D> decoder,
  ) {
    try {
      return Result.success(decoder.decodeData(data));
    } catch (e, st) {
      return Result.error(
        ParseException(
          targetType: ParseTargetType.RESPONSE_DECODE,
          data: data,
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
