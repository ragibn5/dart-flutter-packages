import 'package:core_models/core_models.dart';
import 'package:feature_api_client/src/services/net_kit_exception_transformer.dart';
import 'package:feature_api_client/src/services/net_kit_request_builder.dart';
import 'package:feature_api_client/src/services/net_kit_response_decoder.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';

abstract class FeatureApiClient<Req, Res, Err>
    implements NetKitRequestBuilder<Req>, NetKitResponseDecoder<Err, Res> {
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
