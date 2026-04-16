import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/net_kit_encoder.dart';

abstract interface class NetKitRequestEncoder
    implements NetKitEncoder<dynamic> {}

class DefaultNetKitRequestEncoder implements NetKitRequestEncoder {
  const DefaultNetKitRequestEncoder();

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
