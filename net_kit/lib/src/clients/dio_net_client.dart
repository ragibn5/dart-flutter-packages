import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/api_response.dart';
import 'package:net_kit/src/models/default_client_config.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/codec/net_client_request_encoder.dart';
import 'package:net_kit/src/services/codec/net_client_response_decoder.dart';
import 'package:net_kit/src/services/codec/request_codec.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/dio_client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/services/mappers/response_classifier_impl.dart';
import 'package:net_kit/src/types/api_call_result.dart';
import 'package:net_kit/src/types/progress_listener.dart';

/// A thin, generic HTTP executor for typed requests and responses.
class DioNetClient implements NetClient {
  static const _defaultResponseCode = 0;
  static const _defaultRequestEncoder = DefaultNetClientRequestEncoder();
  static const _defaultErrorResponseDecoder =
      DefaultNetClientResponseDecoder(ParseTargetType.ERROR_DECODE);
  static const _defaultSuccessfulResponseDecoder =
      DefaultNetClientResponseDecoder(ParseTargetType.RESPONSE_DECODE);
  static const _defaultClientExceptionMapper = DioClientExceptionMapper(
    _defaultResponseCode,
    _defaultErrorResponseDecoder,
  );

  final Dio _dio;

  final NetClientRequestEncoder _requestEncoder;
  final NetClientResponseDecoder _errorResponseDecoder;
  final NetClientResponseDecoder _successfulResponseDecoder;

  final ClientExceptionMapper _clientExceptionMapper;

  DioNetClient([DefaultClientConfig config = const DefaultClientConfig()])
      : this._(
          _createDio(config),
          _defaultRequestEncoder,
          _defaultErrorResponseDecoder,
          _defaultSuccessfulResponseDecoder,
          _defaultClientExceptionMapper,
        );

  @visibleForTesting
  DioNetClient.test(
    Dio dio,
    NetClientRequestEncoder requestEncoder,
    NetClientResponseDecoder errorResponseDecoder,
    NetClientResponseDecoder successfulResponseDecoder,
    ClientExceptionMapper clientExceptionMapper,
  ) : this._(
          dio,
          requestEncoder,
          errorResponseDecoder,
          successfulResponseDecoder,
          clientExceptionMapper,
        );

  DioNetClient._(
    this._dio,
    this._requestEncoder,
    this._errorResponseDecoder,
    this._successfulResponseDecoder,
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
    required RequestCodec<Req, Res, Err> codec,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller<Req>? requestCanceller,
  }) async {
    try {
      final encodedRequest =
          _requestEncoder.encode(spec.body, codec.encodeBody);
      if (encodedRequest.isError) {
        return Result.error(encodedRequest.errorOrNull!);
      }

      final response = await _dio.fetch<dynamic>(
        RequestOptions(
          path: spec.pathOrUrl,
          data: encodedRequest.resultOrNull,
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
        return _errorResponseDecoder
            .decode(response.data, codec.decodeError)
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

      return _successfulResponseDecoder
          .decode(response.data, codec.decodeResponse)
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
          .mapException(e, stackTrace: st, errorDecoder: codec.decodeError)
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
