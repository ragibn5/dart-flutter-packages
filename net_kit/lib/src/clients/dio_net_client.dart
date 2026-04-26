import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/dio_client_exception_mapper.dart';
import 'package:net_kit/src/services/resolver/request_body_content_type_resolver.dart';
import 'package:net_kit/src/services/transformers/request/dio_request_body_transformer.dart';
import 'package:net_kit/src/services/transformers/request/request_body_transformer.dart';
import 'package:net_kit/src/services/transformers/response/error_response_data_transformer.dart';
import 'package:net_kit/src/services/transformers/response/successful_response_data_transformer.dart';
import 'package:net_kit/src/types/progress_listener.dart';

/// A thin, generic HTTP executor for typed requests and responses.
class DioNetClient implements NetClient {
  static const _defaultResponseCode = 0;
  static const _defaultRequestBodyTransformer = DioRequestBodyTransformer();
  static const _defaultRequestBodyContentTypeResolver =
      DefaultRequestBodyContentTypeResolver();
  static const _defaultErrorResponseDataTransformer =
      DefaultErrorResponseDataTransformer();
  static const _defaultSuccessfulResponseDataTransformer =
      DefaultSuccessfulResponseDataTransformer();
  static const _defaultClientExceptionMapper = DioClientExceptionMapper(
    _defaultResponseCode,
    _defaultErrorResponseDataTransformer,
  );

  final Dio _dio;

  final RequestBodyTransformer _requestBodyTransformer;
  final RequestBodyContentTypeResolver _requestBodyContentTypeResolver;
  final ErrorResponseDataTransformer _errorResponseDataTransformer;
  final SuccessfulResponseDataTransformer _successfulResponseDataTransformer;

  final ClientExceptionMapper _clientExceptionMapper;

  DioNetClient([DefaultClientConfig config = const DefaultClientConfig()])
      : this._(
          _createDio(config),
          _defaultRequestBodyTransformer,
          _defaultRequestBodyContentTypeResolver,
          _defaultErrorResponseDataTransformer,
          _defaultSuccessfulResponseDataTransformer,
          _defaultClientExceptionMapper,
        );

  @visibleForTesting
  DioNetClient.test(
    Dio dio,
    RequestBodyTransformer requestBodyTransformer,
    RequestBodyContentTypeResolver requestBodyContentTypeResolver,
    ErrorResponseDataTransformer errorResponseDataTransformer,
    SuccessfulResponseDataTransformer successfulResponseDataTransformer,
    ClientExceptionMapper clientExceptionMapper,
  ) : this._(
          dio,
          requestBodyTransformer,
          requestBodyContentTypeResolver,
          errorResponseDataTransformer,
          successfulResponseDataTransformer,
          clientExceptionMapper,
        );

  DioNetClient._(
    this._dio,
    this._requestBodyTransformer,
    this._requestBodyContentTypeResolver,
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
        followRedirects: config.followRedirects,
        maxRedirects: config.maxRedirects,
      ),
    );
  }

  /// Executes the given [spec] and returns a typed [Result].
  @override
  Future<ApiCallResult<Res, Err>> execute<Res, Err>({
    required RequestSpec spec,
    required ResponseDataCodec<Res, Err> codec,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
  }) async {
    try {
      final transformedRequest = _requestBodyTransformer.transform(spec.body);
      final resolvedContentType = spec.contentType ??
          _requestBodyContentTypeResolver.resolve(spec.body);
      final response = await _dio.request<dynamic>(
        spec.pathOrUrl,
        data: transformedRequest,
        queryParameters: spec.queryParameters,
        options: Options(
          method: spec.method.value,
          sendTimeout: spec.sendTimeout,
          receiveTimeout: spec.receiveTimeout,
          headers: spec.headers,
          contentType: resolvedContentType,
          followRedirects: spec.followRedirects,
          maxRedirects: spec.maxRedirects,
          // We may need multiple factors to decide whether the
          // response is an error response, the status-code itself
          // may not be sufficient. We will decide this with the
          // response classifier later on.
          validateStatus: (s) => true,
        ),
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        cancelToken: _createCancelToken(spec, requestCanceller),
      );

      final responseContext = ResponseContext(
        statusCode: response.statusCode ?? _defaultResponseCode,
        responseHeaders: response.headers.map,
        rawResponseBody: response.data,
        request: spec,
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

  CancelToken? _createCancelToken(
    RequestSpec requestSpec,
    RequestCanceller? requestCanceller,
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
