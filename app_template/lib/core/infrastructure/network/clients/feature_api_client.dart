import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_response.dart';
import 'package:functionals/functionals.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';

abstract interface class _NetKitRequestBuilder<Req> {
  RequestSpec createRequest(Req body);
}

abstract interface class _NetKitResponseDecoder<Err, Res> {
  ApiResponse<Err, Res> decodeResponse(NetKitResponse response);
}

abstract class FeatureApiClient<Req, Res, Err>
    implements _NetKitRequestBuilder<Req>, _NetKitResponseDecoder<Err, Res> {
  final NetClient _client;
  final NetKitExceptionTransformer _netKitExceptionTransformer;

  FeatureApiClient(NetClient client)
    : this._(client, const NetKitExceptionTransformer());

  @visibleForTesting
  FeatureApiClient.test(
    NetClient client,
    NetKitExceptionTransformer netKitExceptionTransformer,
  ) : this._(client, netKitExceptionTransformer);

  FeatureApiClient._(this._client, this._netKitExceptionTransformer);

  Future<Either<ApiError, ApiResponse<Err, Res>>> request(Req body) async {
    final requestSpec = createRequest(body);
    final rawResponse = await _client.execute(spec: requestSpec);
    return rawResponse.fold(
      onSuccess: (r) => Right(decodeResponse(r)),
      onError: (e) => Left(_netKitExceptionTransformer.transformApiError(e)),
    );
  }
}

class NetKitExceptionTransformer {
  const NetKitExceptionTransformer();

  ApiError transformApiError(NetKitException e) {
    return switch (e) {
      TransportException() => TransportError(
        type: _toAppTransportErrorType(e.type),
      ),
      CancellationException() => CancellationError(source: e.source),
      UnexpectedException() => UnexpectedError(
        cause: e.cause,
        stackTrace: e.stackTrace,
      ),
    };
  }

  TransportErrorType _toAppTransportErrorType(
    TransportExceptionType netKitTransportErrorType,
  ) {
    return switch (netKitTransportErrorType) {
      .CONNECTION_TIMEOUT => .CONNECTION_TIMEOUT,
      .SEND_TIMEOUT => .SEND_TIMEOUT,
      .RECEIVE_TIMEOUT => .RECEIVE_TIMEOUT,
      .CONNECTION_ERROR => .CONNECTION_ERROR,
      .BAD_CERTIFICATE => .BAD_CERTIFICATE,
    };
  }
}
