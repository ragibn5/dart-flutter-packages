import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/domain_exception.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/client_exception_mapper.dart';
import 'package:net_kit/src/services/codec/net_kit_request_encoder.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';

abstract interface class NetKit {
  Future<Result<NetKitException, Result<DomainException<Err>, Res>>>
      execute<Req, Res, Err>(
    RequestSpec<Req, Res, Err> spec, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });
}

/// A thin, generic HTTP executor for typed requests and responses.
class NetKitImpl implements NetKit {
  static const _defaultRequestEncoder = DefaultNetKitRequestEncoder();
  static const _defaultErrorResponseDecoder =
      DefaultNetKitResponseDecoder(ParseTargetType.ERROR_DECODE);
  static const _defaultSuccessfulResponseDecoder =
      DefaultNetKitResponseDecoder(ParseTargetType.RESPONSE_DECODE);
  static const _defaultClientExceptionMapper =
      ClientExceptionMapperImpl(_defaultErrorResponseDecoder);

  final Dio _dio;

  final NetKitRequestEncoder _requestEncoder;
  final NetKitResponseDecoder _errorResponseDecoder;
  final NetKitResponseDecoder _successfulResponseDecoder;

  final ClientExceptionMapper _clientExceptionMapper;

  NetKitImpl(Dio dio)
      : this._(
          dio,
          _defaultRequestEncoder,
          _defaultErrorResponseDecoder,
          _defaultSuccessfulResponseDecoder,
          _defaultClientExceptionMapper,
        );

  @visibleForTesting
  NetKitImpl.test(
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

  NetKitImpl._(
    this._dio,
    this._requestEncoder,
    this._errorResponseDecoder,
    this._successfulResponseDecoder,
    this._clientExceptionMapper,
  );

  /// Executes the given [spec] and returns a typed [Result].
  @override
  Future<Result<NetKitException, Result<DomainException<Err>, Res>>>
      execute<Req, Res, Err>(
    RequestSpec<Req, Res, Err> spec, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final encodedRequest =
          _requestEncoder.encode(spec.body, spec.codec.encodeBody);
      if (encodedRequest.isError) {
        return Result.error(encodedRequest.errorOrNull!);
      }

      final response = await _dio.request<dynamic>(
        spec.path,
        queryParameters: spec.queryParameters,
        options: Options(method: spec.method.value, headers: spec.headers),
        data: encodedRequest.resultOrNull,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (spec.responseClassifier.isError(response)) {
        return _errorResponseDecoder
            .decode(response.data, spec.codec.decodeError)
            .fold(
              onError: Result.error,
              onSuccess: (de) =>
                  Result.success(Result.error(DomainException(de))),
            );
      }

      return _successfulResponseDecoder
          .decode(response.data, spec.codec.decodeResponse)
          .fold(
            onError: Result.error,
            onSuccess: (d) => Result.success(Result.success(d)),
          );
    } catch (e, st) {
      return _clientExceptionMapper
          .mapException(
            e,
            stackTrace: st,
            errorDecoder: spec.codec.decodeError,
          )
          .fold(
            onError: Result.error,
            onSuccess: (d) => Result.success(Result.error(d)),
          );
    }
  }

  /// Fires a data request and returns the unwrapped [Response].
  ///
  /// Use this for endpoints where you need full control over the response —
  /// for example, file downloads or streaming. No encoding or decoding is
  /// performed.
  Future<Response<dynamic>> executeRaw(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.request<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Fires a request from a pre-built [RequestOptions] and returns the data
  /// [Response]. This can be useful for many scenarios, for example,
  /// retrying intercepted requests.
  Future<Response<dynamic>> executeRawWithOptions(
    RequestOptions requestOptions,
  ) {
    return _dio.fetch<dynamic>(requestOptions);
  }

  /// Downloads a file from [urlPath] and saves it to [savePath].
  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

  /// Downloads a file from [uri] and saves it to [savePath].
  Future<Response<dynamic>> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) {
    return _dio.downloadUri(
      uri,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

  /// Closes the underlying HTTP client and frees its resources.
  void close() => _dio.close();
}
