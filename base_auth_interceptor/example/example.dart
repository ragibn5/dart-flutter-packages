import 'package:base_auth_interceptor/base_auth_interceptor.dart';

class AppAuthInterceptor extends BaseAuthInterceptor<String> {
  @override
  Future<String?> getAuthData() async => 'my-token';

  @override
  Future<RequestSpec> transformRequestWithAuthData(RequestSpec request,
      String authData,) async =>
      request.addHeader('Authorization', 'Bearer ${authData}');

  @override
  bool didServerReportAuthError(RawResponse response) =>
      response.statusCode == 401;

  @override
  bool shouldRefreshAuthData(RequestSpec request, String authData) => false;

  @override
  Future<String?> requestAuthDataRefresh(String oldAuthData) async => null;

  @override
  Future<ApiCallResult> retryRequest(RequestSpec request,
      String refreshedAuthData,) async =>
      ApiCallResult(data: '', statusCode: 200);
}