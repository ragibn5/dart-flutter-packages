import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/net_client_data_encoder.dart';

abstract interface class NetClientRequestEncoder
    implements NetClientDataEncoder<dynamic> {}

class DefaultNetClientRequestEncoder implements NetClientRequestEncoder {
  const DefaultNetClientRequestEncoder();

  @override
  EncodeResult encode<D>(D data, dynamic Function(D) encoder) {
    if (data == null) {
      return Result.success(null);
    }

    try {
      return Result.success(encoder(data));
    } catch (e, st) {
      return Result.error(
        ParseException(
          targetType: ParseTargetType.REQUEST_ENCODE,
          data: data,
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
