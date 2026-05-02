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

  final RequestComposer _requestComposer;
  final RequestBodyTransformer _requestBodyTransformer;
  final RequestBodyContentTypeResolver _requestBodyContentTypeResolver;
  final DioCancelTokenFactory _dioCancelTokenFactory;
  final DioRequestOptionsBuilder _dioRequestOptionsBuilder;
  final ErrorResponseDataTransformer _errorResponseDataTransformer;
  final SuccessfulResponseDataTransformer _successfulResponseDataTransformer;
  final ClientExceptionMapper _clientExceptionMapper;

  DioNetClient([DefaultClientConfig config = const DefaultClientConfig()])
      : _dio = DioFactory.createDio(config),
        _defaultClientConfig = config,
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
    final composedSpec = _requestComposer.compose(spec, _defaultClientConfig);
    final transformedRequest =
        _requestBodyTransformer.transform(composedSpec.body);
    final resolvedContentType = composedSpec.contentType ??
        _requestBodyContentTypeResolver.resolve(composedSpec.body);
    final cancelToken =
        _dioCancelTokenFactory.create(composedSpec, requestCanceller);
    try {
      final response = await _dio.fetch<dynamic>(
        _dioRequestOptionsBuilder.build(
          composedSpec: composedSpec,
          transformedBody: transformedRequest,
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
                  requestSpec: composedSpec,
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
                requestSpec: composedSpec,
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
                requestSpec: composedSpec,
              ),
            ),
          );
    }
  }

  /// Closes the underlying HTTP client and frees its resources.
  @override
  void close() => _dio.close();
}
