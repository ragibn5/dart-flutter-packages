import 'package:dio/dio.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/error_mapper.dart';
import 'package:parser/parser.dart';

class NetKit<EncodedDataType, ErrorType> {
  final Dio _dio;
  final ErrorMapper<ErrorType> _errorMapper;
  final Parser<EncodedDataType> _dataParser;

  /// **Create a network client.**
  ///
  /// This constructor initializes a [NetKit] instance with the provided
  /// configurations for making network requests.
  ///
  /// - [client]: A required [Dio] instance. This will be used as the underlying
  ///   HTTP client for all network requests.You must configure the [Dio]
  ///   instance (e.g., setting base URL, timeouts, and other stuff) before
  ///   passing it here.
  ///
  /// - [errorMapper]: A required instance of [ErrorMapper<ErrorType>] that maps
  ///   exceptions or errors encountered during network requests to your custom
  ///   [ErrorType]. This allows you to handle errors in a type-safe manner.
  ///
  /// - [dataParser]: A required instance of [Parser]<EncodedDataType>] that
  ///   handles serialization and deserialization of request and response data.
  ///   This ensures that your data is properly encoded and decoded according to
  ///   your application's requirements. For JSON-based APIs, you can use the
  ///   built-in [JsonParser] provided by the library.
  ///
  /// **Example:**
  /// ```dart
  /// final client = NetKit(
  ///   // Specifying a custom Dio instance.
  ///   client: Dio(
  ///     BaseOptions(
  ///       baseUrl: 'https://example.api.com',
  ///       connectTimeout: Duration(seconds: 5),
  ///       receiveTimeout: Duration(seconds: 5),
  ///     ),
  ///   ),
  ///
  ///   // Specifying a custom data parser.
  ///   // You may extend built-in parsers and use that.
  ///   dataParser: MyJsonParser(),
  ///
  ///   // Specifying an error mapper.
  ///   errorMapper: MyErrorMapper(),
  /// );
  /// ```
  NetKit({
    required Dio client,
    required ErrorMapper<ErrorType> errorMapper,
    required Parser<EncodedDataType> dataParser,
  })  : _dio = client,
        _dataParser = dataParser,
        _errorMapper = errorMapper;

  /// **Execute a raw request and get raw response**.
  ///
  /// {@template named_params_doc}
  /// Note, properties of the passed [Options] parameters
  /// will be overridden by corresponding explicit parameters.
  /// {@endtemplate}}
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

  /// **Execute a raw request from a pre-defined [RequestOptions] and
  /// get raw response**.
  Future<Response<dynamic>> executeRawWithRequestOption(
    RequestOptions requestOptions,
  ) {
    return _dio.fetch<dynamic>(requestOptions);
  }

  /// **Execute a get request**.
  ///
  /// {@macro named_params_doc}
  Future<Result<ErrorType, ResultType>> get<ResultType>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request<ResultType>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'GET'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// **Execute a post request**.
  ///
  /// {@macro named_params_doc}
  Future<Result<ErrorType, ResultType>> post<ResultType>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request<ResultType>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'POST'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// **Execute a put request**.
  ///
  /// {@macro named_params_doc}
  Future<Result<ErrorType, ResultType>> put<ResultType>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request<ResultType>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'PUT'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// **Execute a patch request**.
  ///
  /// {@macro named_params_doc}
  Future<Result<ErrorType, ResultType>> patch<ResultType>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request<ResultType>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'PATCH'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// **Execute a delete request**.
  ///
  /// {@macro named_params_doc}
  Future<Result<ErrorType, ResultType>> delete<ResultType>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request<ResultType>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'DELETE'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// **Execute a delete request**.
  ///
  /// {@macro named_params_doc}
  Future<Response<dynamic>> download<ResultType>(
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

  Future<Response<dynamic>> downloadUri<ResultType>(
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

  void close() {
    _dio.close();
  }

  dynamic _buildRequest(dynamic requestData) {
    return requestData != null ? _dataParser.encode(requestData) : null;
  }

  Future<Result<ErrorType, ResultType>> _request<ResultType>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: _buildRequest(data),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Result.data(_dataParser.decode<ResultType>(response.data));
    } on ParseException catch (e) {
      return Result.error(
        _errorMapper.mapError(e, e.sourceExceptionStackTrace),
      );
    } catch (e, st) {
      return Result.error(_errorMapper.mapError(e, st));
    }
  }
}
