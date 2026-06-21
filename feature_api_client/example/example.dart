import 'package:core_models/core_models.dart';
import 'package:feature_api_client/feature_api_client.dart';
import 'package:net_kit/net_kit.dart';

class MyRequest {
  final String id;

  MyRequest(this.id);
}

class MyResponse {
  final String data;

  MyResponse(this.data);
}

class MyError {
  final String message;

  MyError(this.message);
}

class MyClient extends FeatureApiClient<MyRequest, MyResponse, MyError> {
  MyClient(super.client);

  @override
  RequestSpec createRequest(MyRequest body) => RequestSpec(
        pathOrUrl: 'https://api.example.com/${body.id}',
        method: HttpMethod.GET,
      );

  @override
  ApiResponse<MyError, MyResponse> decodeResponse(
    NetKitResponse response,
  ) =>
      Success(
        data: MyResponse(response.data.toString()),
        statusCode: response.statusCode,
        headers: response.headers,
      );
}

void main() {
  print('FeatureApiClient ready');
}
