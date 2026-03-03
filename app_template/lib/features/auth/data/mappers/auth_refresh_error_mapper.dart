import 'package:app_template/core/converters/data_to_domain_converter.dart';
import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthRefreshErrorMapper
    implements
        DataToDomainConverter<
          ApiError<ServerError<ServerMessage>>,
          ApiError<AuthDataRefreshError>
        > {
  static const String INVALID_REFRESH_TOKEN = 'INVALID_REFRESH_TOKEN';
  static const String INVALID_AUTH_STATE_FOR_REFRESH =
      'INVALID_AUTH_STATE_FOR_REFRESH';

  @override
  ApiError<AuthDataRefreshError> convertDataToDomain(
    ApiError<ServerError<ServerMessage>> dataModel,
  ) => dataModel.fold(
    ApiError.fromAppError,
    ApiError.fromNetworkError,
    (se) => ApiError.fromServerError(switch (se.errorResponse.code) {
      INVALID_REFRESH_TOKEN => InvalidRefreshToken(),
      INVALID_AUTH_STATE_FOR_REFRESH => InvalidAuthStateForRefresh(),
      _ => throw ArgumentError('Unknown error code: ${se.errorResponse.code}'),
    }),
  );
}
