import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/clients/dio/dio_cancel_token_factory.dart';
import 'package:net_kit/src/clients/dio/dio_client_exception_mapper.dart';
import 'package:net_kit/src/clients/dio/dio_factory.dart';
import 'package:net_kit/src/clients/dio/dio_request_body_transformer.dart';
import 'package:net_kit/src/clients/dio/dio_request_options_builder.dart';
import 'package:net_kit/src/services/composer/request_composer.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/resolver/request_body_content_type_resolver.dart';
import 'package:net_kit/src/services/transformers/request/request_body_transformer.dart';
import 'package:net_kit/src/services/transformers/response/error_response_data_transformer.dart';
import 'package:net_kit/src/services/transformers/response/successful_response_data_transformer.dart';
import 'package:net_kit/src/types/progress_listener.dart';

/// A thin, generic HTTP executor for typed requests and responses.
class DioNetClient implements NetClient {
  static const _defaultResponseCode = 0;
  static const _defaultDioCancelTokenFactory = DioCancelTokenFactory();
  static const _defaultDioRequestComposer = RequestComposer();
  static const _defaultDioRequestOptionsBuilder = DioRequestOptionsBuilder();
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
  final DefaultClientConfig _defaultClientConfig;
  final List<NetKitInterceptor> _interceptors;

  final RequestComposer _requestComposer;
  final RequestBodyTransformer _requestBodyTransformer;
  final RequestBodyContentTypeResolver _requestBodyContentTypeResolver;
  final DioCancelTokenFactory _dioCancelTokenFactory;
  final DioRequestOptionsBuilder _dioRequestOptionsBuilder;
  final ErrorResponseDataTransformer _errorResponseDataTransformer;
  final SuccessfulResponseDataTransformer _successfulResponseDataTransformer;
  final ClientExceptionMapper _clientExceptionMapper;

  DioNetClient([
    DefaultClientConfig config = const DefaultClientConfig(),
    List<NetKitInterceptor> interceptors = const [],
  ])  : _dio = DioFactory.createDio(config),
        _defaultClientConfig = config,
        _interceptors = interceptors,
        _requestComposer = _defaultDioRequestComposer,
        _requestBodyTransformer = _defaultRequestBodyTransformer,
        _requestBodyContentTypeResolver =
            _defaultRequestBodyContentTypeResolver,
        _dioCancelTokenFactory = _defaultDioCancelTokenFactory,
        _dioRequestOptionsBuilder = _defaultDioRequestOptionsBuilder,
        _errorResponseDataTransformer = _defaultErrorResponseDataTransformer,
        _successfulResponseDataTransformer =
            _defaultSuccessfulResponseDataTransformer,
        _clientExceptionMapper = _defaultClientExceptionMapper;

  @visibleForTesting
  DioNetClient.test(
    Dio dio,
    DefaultClientConfig defaultClientConfig,
    List<NetKitInterceptor> interceptors,
    RequestComposer requestComposer,
    RequestBodyTransformer requestBodyTransformer,
    RequestBodyContentTypeResolver requestBodyContentTypeResolver,
    DioCancelTokenFactory dioCancelTokenFactory,
    DioRequestOptionsBuilder dioRequestOptionsBuilder,
    ErrorResponseDataTransformer errorResponseDataTransformer,
    SuccessfulResponseDataTransformer successfulResponseDataTransformer,
    ClientExceptionMapper clientExceptionMapper,
  )   : _dio = dio,
        _defaultClientConfig = defaultClientConfig,
        _interceptors = interceptors,
        _requestComposer = requestComposer,
        _requestBodyTransformer = requestBodyTransformer,
        _requestBodyContentTypeResolver = requestBodyContentTypeResolver,
        _dioCancelTokenFactory = dioCancelTokenFactory,
        _dioRequestOptionsBuilder = dioRequestOptionsBuilder,
        _errorResponseDataTransformer = errorResponseDataTransformer,
        _successfulResponseDataTransformer = successfulResponseDataTransformer,
        _clientExceptionMapper = clientExceptionMapper;

  /// Executes the given [spec] and returns a typed [Result].
  @override
  Future<ApiCallResult<Res, Err>> execute<Res, Err>({
    required RequestSpec spec,
    required ResponseDataCodec<Res, Err> codec,
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
  }) async {
    var composedSpec = _requestComposer.compose(spec, _defaultClientConfig);

    final requestResult = await _processRequest(composedSpec);
    switch (requestResult) {
      case ContinueWithRequest(:final request):
        composedSpec = request;
      case RejectRequest(:final error):
        return Result.error(error);
      case ResolveRequest(:final response):
        return _buildResult<Res, Err>(response, responseClassifier, codec);
    }

    final transformedBody =
        _requestBodyTransformer.transform(composedSpec.body);
    final resolvedContentType = composedSpec.contentType ??
        _requestBodyContentTypeResolver.resolve(composedSpec.body);
    final cancelToken =
        _dioCancelTokenFactory.create(composedSpec, requestCanceller);

    try {
      final response = await _dio.fetch<dynamic>(
        _dioRequestOptionsBuilder.build(
          composedSpec: composedSpec,
          transformedBody: transformedBody,
          resolvedContentType: resolvedContentType,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );
      final responseContext = ResponseContext(
        statusCode: response.statusCode ?? _defaultResponseCode,
        responseHeaders: response.headers.map,
        rawResponseBody: response.data,
        request: composedSpec,
      );

      return _processResponse<Res, Err>(
        responseContext,
        responseClassifier,
        codec,
      );
    } catch (e, st) {
      return _clientExceptionMapper
          .mapException(e, stackTrace: st, errorResponseDataDecoder: codec)
          .fold(
            onError: (exception) => _processError<Res, Err>(
              exception,
              composedSpec,
              responseClassifier,
              codec,
            ),
            onSuccess: (errorResponseData) => Result.success(
              ApiResponse(
                statusCode: errorResponseData.statusCode,
                data: Result.error(errorResponseData.error),
                headers: errorResponseData.headers,
                requestSpec: composedSpec,
              ),
            ),
          );
    }
  }

  ApiCallResult<Res, Err> _buildResult<Res, Err>(
    ResponseContext responseContext,
    ResponseClassifier responseClassifier,
    ResponseDataCodec<Res, Err> codec,
  ) {
    if (responseClassifier.isError(responseContext)) {
      return _errorResponseDataTransformer
          .transform(responseContext.rawResponseBody, codec)
          .fold(
            onError: Result.error,
            onSuccess: (decodedError) => Result.success(
              ApiResponse(
                statusCode: responseContext.statusCode,
                data: Result.error(decodedError),
                headers: responseContext.responseHeaders,
                requestSpec: responseContext.request,
              ),
            ),
          );
    }

    return _successfulResponseDataTransformer
        .transform(responseContext.rawResponseBody, codec)
        .fold(
          onError: Result.error,
          onSuccess: (decoded) => Result.success(
            ApiResponse(
              statusCode: responseContext.statusCode,
              data: Result.success(decoded),
              headers: responseContext.responseHeaders,
              requestSpec: responseContext.request,
            ),
          ),
        );
  }

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

  Future<ApiCallResult<Res, Err>> _processResponse<Res, Err>(
    ResponseContext responseContext,
    ResponseClassifier responseClassifier,
    ResponseDataCodec<Res, Err> codec,
  ) async {
    var ctx = responseContext;

    for (final interceptor in _interceptors) {
      final result = await interceptor.onResponse(ctx);
      switch (result) {
        case ContinueWithResponse(:final response):
          ctx = response;
        case RejectResponse(:final error):
          return Result.error(error);
        case ResolveResponse(:final response):
          return _buildResult<Res, Err>(response, responseClassifier, codec);
      }
    }

    return _buildResult<Res, Err>(ctx, responseClassifier, codec);
  }

  Future<ApiCallResult<Res, Err>> _processError<Res, Err>(
    NetKitException error,
    RequestSpec requestSpec,
    ResponseClassifier responseClassifier,
    ResponseDataCodec<Res, Err> codec,
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
          return _buildResult<Res, Err>(response, responseClassifier, codec);
      }
    }

    return Result.error(currentError);
  }

  /// Closes the underlying HTTP client and frees its resources.
  @override
  void close() => _dio.close();
}
