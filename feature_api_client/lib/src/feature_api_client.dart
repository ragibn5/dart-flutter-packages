import 'package:dart_functionals/dart_functionals.dart';
import 'package:dio/dio.dart';
import 'package:feature_api_client/src/services/dio_exception_transformer.dart';
import 'package:meta/meta.dart';
import 'package:net_models/net_models.dart';

/// A client for one API feature: [Req] is what it sends, [Res] what the
/// server answers on success, and [Err] what it answers on failure.
abstract class FeatureApiClient<Req, Res, Err> {
  final Dio _dio;
  final DioExceptionTransformer _exceptionTransformer;

  FeatureApiClient(
    this._dio, {
    @visibleForTesting DioExceptionTransformer exceptionTransformer =
        const DioExceptionTransformer(),
  }) : _exceptionTransformer = exceptionTransformer;

  /// Sends [body] through [dio].
  @protected
  Future<Response<Object?>> send(Dio dio, Req body);

  /// Decodes what the server answered, whatever its status.
  @protected
  ApiResponse<Err, Res> decodeResponse(Response<Object?> response);

  /// Sends [body]: an [ApiError] if no answer was decoded, otherwise the
  /// decoded answer.
  Future<Either<ApiError, ApiResponse<Err, Res>>> request(Req body) async {
    try {
      final Response<Object?> response;
      try {
        response = await send(_dio, body);
      } on DioException catch (e) {
        final errorResponse = e.response;
        if (e.type != DioExceptionType.badResponse || errorResponse == null) {
          return Left(_exceptionTransformer.transformApiError(e));
        }
        // The server answered with an error status: its body is an [Err].
        return Right(decodeResponse(errorResponse));
      }
      return Right(decodeResponse(response));
    } catch (e, stackTrace) {
      return Left(UnexpectedError(cause: e, stackTrace: stackTrace));
    }
  }
}
