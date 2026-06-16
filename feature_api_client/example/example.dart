import 'package:feature_api_client/feature_api_client.dart';

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
  RequestSpec createRequest(MyRequest body) =>
      RequestSpec(
        method: HttpMethod.get,
        uri: Uri.parse('https://api.example.com/${body.id}'),
      );

  @override
  ApiResponse<MyError, MyResponse> decodeResponse(NetKitResponse response,) =>
      Success(
        data: MyResponse(response.body),
        statusCode: response.statusCode,
        headers: response.headers,
      );
}

void main() {
  print('FeatureApiClient ready');
}
