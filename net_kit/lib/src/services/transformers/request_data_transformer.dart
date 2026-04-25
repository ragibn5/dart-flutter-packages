import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';

abstract interface class RequestDataTransformer {
  Result<ParseException, dynamic> transform<D>(
    D data,
    RequestDataEncoder<D> encoder,
  );
}

class DefaultRequestDataTransformer implements RequestDataTransformer {
  const DefaultRequestDataTransformer();

  @override
  Result<ParseException, dynamic> transform<D>(
    D data,
    RequestDataEncoder<D> encoder,
  ) {
    if (data == null) {
      return Result.success(null);
    }

    try {
      return Result.success(encoder.encodeRequestData(data));
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
