import 'dart:async';

import 'package:net_kit/src/models/api_response.dart';
import 'package:net_kit/src/models/client_config.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/raw_response.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/adapters/network_request_adapter.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/composer/request_composer.dart';
import 'package:net_kit/src/services/interceptor/error_interceptor_result.dart';
import 'package:net_kit/src/services/interceptor/net_kit_interceptor.dart';
import 'package:net_kit/src/services/interceptor/request_interceptor_result.dart';
import 'package:net_kit/src/services/interceptor/response_interceptor_result.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/services/resolver/request_content_type_resolver.dart';
import 'package:net_kit/src/types/api_call_result.dart';
import 'package:net_kit/src/types/progress_listener.dart';

class NetClient {
  final ClientConfig _clientConfig;
  final List<NetKitInterceptor> _interceptors;
  final NetworkRequestAdapter _requestAdapter;

  final RequestComposer _requestComposer;
  final RequestContentTypeResolver _requestBodyContentTypeResolver;

  NetClient({
    required ClientConfig clientConfig,
    required List<NetKitInterceptor> interceptors,
    required NetworkRequestAdapter requestAdapter,
    RequestComposer requestComposer = const DefaultRequestComposer(),
    RequestContentTypeResolver requestContentTypeResolver =
        const DefaultRequestContentTypeResolver(),
  })  : _clientConfig = clientConfig,
        _interceptors = interceptors,
        _requestAdapter = requestAdapter,
        _requestComposer = requestComposer,
        _requestBodyContentTypeResolver = requestContentTypeResolver;

  /// Executes the given [spec] and returns a typed [ApiCallResult].
  Future<ApiCallResult> execute({
    required RequestSpec spec,
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
  }) async {
    var composedSpec = _requestComposer.compose(spec, _clientConfig).copyWith(
          contentType: _requestBodyContentTypeResolver.resolve(spec.body),
        );

    final requestResult = await _processRequest(composedSpec);
    switch (requestResult) {
      case ContinueWithRequest(:final request):
        composedSpec = request;
      case RejectRequest(:final error):
        return Result.error(error);
      case ResolveRequest(:final response):
        return Result.success(_buildResult(response, responseClassifier));
    }

    final result = await _requestAdapter.performRequest(
      spec: composedSpec,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      requestCanceller: requestCanceller,
    );
    return result.fold(
      onSuccess: (r) => _processResponse(r, responseClassifier),
      onError: (e) => _processError(e, composedSpec, responseClassifier),
    );
  }

  /// Closes the client and frees its resources.
  void close() => _requestAdapter.close();

  Future<RequestInterceptorResult> _processRequest(RequestSpec spec) async {
    var currentSpec = spec;

    for (final interceptor in _interceptors) {
      final result = await interceptor.onRequest(currentSpec);
      switch (result) {
        case ContinueWithRequest(:final request):
          currentSpec = request;
        default:
          return result;
      }
    }

    return ContinueWithRequest(currentSpec);
  }

  Future<ApiCallResult> _processResponse(
    RawResponse rawResponse,
    ResponseClassifier responseClassifier,
  ) async {
    var ctx = rawResponse;

    for (final interceptor in _interceptors) {
      final result = await interceptor.onResponse(ctx);
      switch (result) {
        case ContinueWithResponse(:final response):
          ctx = response;
        case RejectResponse(:final error):
          return Result.error(error);
        case ResolveResponse(:final response):
          return Result.success(_buildResult(response, responseClassifier));
      }
    }

    return Result.success(_buildResult(ctx, responseClassifier));
  }

  Future<ApiCallResult> _processError(
    NetKitException error,
    RequestSpec requestSpec,
    ResponseClassifier responseClassifier,
  ) async {
    var currentError = error;

    for (final interceptor in _interceptors) {
      final result = await interceptor.onError(currentError);
      switch (result) {
        case ContinueWithError(:final error):
          currentError = error;
        case RejectError(:final error):
          return Result.error(error);
        case RecoverError(:final response):
          return Result.success(_buildResult(response, responseClassifier));
      }
    }

    return Result.error(currentError);
  }

  ApiResponse _buildResult(
    RawResponse responseContext,
    ResponseClassifier responseClassifier,
  ) {
    return ApiResponse(
      isError: responseClassifier.isError(responseContext),
      statusCode: responseContext.statusCode,
      data: responseContext.rawResponseBody,
      headers: responseContext.responseHeaders,
      requestSpec: responseContext.request,
    );
  }
}
