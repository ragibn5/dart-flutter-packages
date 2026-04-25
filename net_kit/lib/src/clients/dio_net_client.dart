import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/dio_client_exception_mapper.dart';
import 'package:net_kit/src/services/transformers/error_response_data_transformer.dart';
import 'package:net_kit/src/services/transformers/request_data_transformer.dart';
import 'package:net_kit/src/services/transformers/successful_response_data_transformer.dart';
import 'package:net_kit/src/types/progress_listener.dart';

/// A thin, generic HTTP executor for typed requests and responses.
class DioNetClient implements NetClient {
  static const _defaultResponseCode = 0;
  static const _defaultRequestDataTransformer = DefaultRequestDataTransformer();
  static const _defaultErrorResponseDataTransformer =
      DefaultErrorResponseDataTransformer();
  static const _defaultSuccessfulResponseDataTransformer =
      DefaultSuccessfulResponseDataTransformer();
  static const _defaultClientExceptionMapper = DioClientExceptionMapper(
    _defaultResponseCode,
    _defaultErrorResponseDataTransformer,
  );

  final Dio _dio;

  final RequestDataTransformer _requestDataTransformer;
  final ErrorResponseDataTransformer _errorResponseDataTransformer;
  final SuccessfulResponseDataTransformer _successfulResponseDataTransformer;

  final ClientExceptionMapper _clientExceptionMapper;

  DioNetClient([DefaultClientConfig config = const DefaultClientConfig()])
      : this._(
          _createDio(config),
          _defaultRequestDataTransformer,
          _defaultErrorResponseDataTransformer,
          _defaultSuccessfulResponseDataTransformer,
          _defaultClientExceptionMapper,
        );

  @visibleForTesting
  DioNetClient.test(
    Dio dio,
    RequestDataTransformer requestDataTransformer,
    ErrorResponseDataTransformer errorResponseDataTransformer,
    SuccessfulResponseDataTransformer successfulResponseDataTransformer,
    ClientExceptionMapper clientExceptionMapper,
  ) : this._(
          dio,
          requestDataTransformer,
          errorResponseDataTransformer,
          successfulResponseDataTransformer,
          clientExceptionMapper,
        );

  DioNetClient._(
    this._dio,
    this._requestDataTransformer,
    this._errorResponseDataTransformer,
    this._successfulResponseDataTransformer,
    this._clientExceptionMapper,
  );

  static Dio _createDio(DefaultClientConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl ?? '',
        connectTimeout: config.connectionTimeout,
        sendTimeout: config.sendTimeout,
        receiveTimeout: config.receiveTimeout,
        queryParameters: config.queryParameters,
        headers: config.headers,
      ),
    );
  }

  /// Executes the given [spec] and returns a typed [Result].
  @override
  Future<ApiCallResult<Req, Res, Err>> execute<Req, Res, Err>({
    required RequestSpec<Req> spec,
    required RequestDataCodec<Req, Res, Err> codec,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller<Req>? requestCanceller,
  }) async {
    try {
      final transformedRequest =
          _requestDataTransformer.transform(spec.body, codec);
      if (transformedRequest.isError) {
        return Result.error(transformedRequest.errorOrNull!);
      }

      final response = await _dio.fetch<dynamic>(
        RequestOptions(
          path: spec.pathOrUrl,
          data: transformedRequest.resultOrNull,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          cancelToken: _createCancelToken(spec, requestCanceller),
          method: spec.method.value,
          sendTimeout: spec.sendTimeout,
          receiveTimeout: spec.receiveTimeout,
          connectTimeout: spec.connectionTimeout,
          queryParameters: spec.queryParameters,
          headers: spec.headers,
          // We may need multiple factors to decide whether the
          // response is an error response, the status-code itself
          // may not be sufficient. We will decide this with the
          // response classifier later on.
          validateStatus: (s) => true,
        ),
      );

      final responseContext = ResponseContext(
        statusCode: response.statusCode ?? _defaultResponseCode,
        responseHeaders: response.headers.map,
        rawResponseBody: response.data,
        requestMetadata: spec,
      );
      if (responseClassifier.isError(responseContext)) {
        return _errorResponseDataTransformer
            .transform(response.data, codec)
            .fold(
              onError: Result.error,
              onSuccess: (e) => Result.success(
                ApiResponse(
                  statusCode: responseContext.statusCode,
                  data: Result.error(e),
                  headers: responseContext.responseHeaders,
                  requestSpec: spec,
                ),
              ),
            );
      }

      return _successfulResponseDataTransformer
          .transform(response.data, codec)
          .fold(
            onError: Result.error,
            onSuccess: (r) => Result.success(
              ApiResponse(
                statusCode: responseContext.statusCode,
                data: Result.success(r),
                headers: responseContext.responseHeaders,
                requestSpec: spec,
              ),
            ),
          );
    } catch (e, st) {
      return _clientExceptionMapper
          .mapException(e, stackTrace: st, errorResponseDataDecoder: codec)
          .fold(
            onError: Result.error,
            onSuccess: (errorResponse) => Result.success(
              ApiResponse(
                statusCode: errorResponse.statusCode,
                data: Result.error(errorResponse.error),
                headers: errorResponse.headers,
                requestSpec: spec,
              ),
            ),
          );
    }
  }

  /// Closes the underlying HTTP client and frees its resources.
  @override
  void close() => _dio.close();

  CancelToken? _createCancelToken<Req>(
    RequestSpec<Req> requestSpec,
    RequestCanceller<Req>? requestCanceller,
  ) {
    if (requestCanceller == null) {
      return null;
    }

    requestCanceller.bindRequestSpec(requestSpec);

    final cancelToken = CancelToken();
    final reason = requestCanceller.reason;
    if (reason != null) {
      cancelToken.cancel(reason);
      return cancelToken;
    } else {
      unawaited(
        requestCanceller.whenCancel.then(cancelToken.cancel),
      );
    }

    return cancelToken;
  }
}
