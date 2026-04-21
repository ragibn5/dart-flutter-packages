import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/api_response.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/client_exception_mapper.dart';
import 'package:net_kit/src/services/codec/net_kit_request_encoder.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';
import 'package:net_kit/src/services/request_canceller.dart';
import 'package:net_kit/src/services/request_codec.dart';
import 'package:net_kit/src/services/response_classifier.dart';
import 'package:net_kit/src/types/api_call_result.dart';
import 'package:net_kit/src/types/progress_listener.dart';

/// A thin, generic HTTP executor for typed requests and responses.
class NetClientImpl implements NetClient {
  static const _defaultResponseCode = 0;
  static const _defaultRequestEncoder = DefaultNetKitRequestEncoder();
  static const _defaultErrorResponseDecoder =
      DefaultNetKitResponseDecoder(ParseTargetType.ERROR_DECODE);
  static const _defaultSuccessfulResponseDecoder =
      DefaultNetKitResponseDecoder(ParseTargetType.RESPONSE_DECODE);
  static const _defaultClientExceptionMapper = ClientExceptionMapperImpl(
    _defaultResponseCode,
    _defaultErrorResponseDecoder,
  );

  final Dio _dio;

  final NetKitRequestEncoder _requestEncoder;
  final NetKitResponseDecoder _errorResponseDecoder;
  final NetKitResponseDecoder _successfulResponseDecoder;

  final ClientExceptionMapper _clientExceptionMapper;

  NetClientImpl(Dio dio)
      : this._(
          dio,
          _defaultRequestEncoder,
          _defaultErrorResponseDecoder,
          _defaultSuccessfulResponseDecoder,
          _defaultClientExceptionMapper,
        );

  @visibleForTesting
  NetClientImpl.test(
    Dio dio,
    NetKitRequestEncoder requestEncoder,
    NetKitResponseDecoder errorResponseDecoder,
    NetKitResponseDecoder successfulResponseDecoder,
    ClientExceptionMapper clientExceptionMapper,
  ) : this._(
          dio,
          requestEncoder,
          errorResponseDecoder,
          successfulResponseDecoder,
          clientExceptionMapper,
        );

  NetClientImpl._(
    this._dio,
    this._requestEncoder,
    this._errorResponseDecoder,
    this._successfulResponseDecoder,
    this._clientExceptionMapper,
  );

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

      final response = await _dio.request<dynamic>(
        spec.path,
        queryParameters: spec.queryParameters,
        options: Options(method: spec.method.value, headers: spec.headers),
        data: encodedRequest.resultOrNull,
        cancelToken: _createCancelToken(spec, requestCanceller),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
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
            onSuccess: (e) => Result.success(
              ApiResponse(
                statusCode: e.statusCode,
                data: Result.error(e.error),
                headers: e.headers,
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
