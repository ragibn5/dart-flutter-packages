import 'dart:async';

import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/services/adapters/network_request_adapter.dart';
import 'package:net_kit/src/services/composer/request_composer.dart';
import 'package:net_kit/src/types/progress_listener.dart';

class NetClientImpl implements NetClient {
  final ClientConfig _clientConfig;
  final List<NetKitInterceptor> _interceptors;
  final NetworkRequestAdapter _requestAdapter;

  final RequestComposer _requestComposer;

  NetClientImpl({
    required ClientConfig clientConfig,
    required List<NetKitInterceptor> interceptors,
    required NetworkRequestAdapter requestAdapter,
    RequestComposer requestComposer = const DefaultRequestComposer(),
  })  : _clientConfig = clientConfig,
        _interceptors = interceptors,
        _requestAdapter = requestAdapter,
        _requestComposer = requestComposer;

  @override
  Future<ApiCallResult> execute({
    required RequestSpec spec,
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
  }) async {
    var composedSpec = _requestComposer.compose(spec, _clientConfig);

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
      requestCanceller: requestCanceller,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return result.fold(
      onSuccess: (r) => _processResponse(r, responseClassifier),
      onError: (e) => _processError(e, composedSpec, responseClassifier),
    );
  }

  @override
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

  @visibleForTesting
  ClientConfig get clientConfig => _clientConfig;

  @visibleForTesting
  List<NetKitInterceptor> get interceptors => _interceptors;

  @visibleForTesting
  NetworkRequestAdapter get requestAdapter => _requestAdapter;
}
