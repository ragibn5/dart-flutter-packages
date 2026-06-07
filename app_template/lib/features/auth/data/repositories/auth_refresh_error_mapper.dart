import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:core_models/core_models.dart';
import 'package:data_domain_converters/data_domain_converters.dart';

class AuthRefreshErrorMapper
    implements DataToDomainConverter<ServerMessage, AuthDataRefreshError> {
  static const String INVALID_REFRESH_TOKEN = 'INVALID_REFRESH_TOKEN';
  static const String INVALID_AUTH_STATE_FOR_REFRESH =
      'INVALID_AUTH_STATE_FOR_REFRESH';

  @override
  AuthDataRefreshError convertDataToDomain(ServerMessage dataModel) {
    final code = dataModel.code;
    return switch (code) {
      INVALID_REFRESH_TOKEN => InvalidRefreshToken(),
      INVALID_AUTH_STATE_FOR_REFRESH => InvalidAuthStateForRefresh(),
      _ => throw ArgumentError('Unknown error code: $code'),
    };
  }
}
