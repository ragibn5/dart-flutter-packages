import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:data_domain_converters/data_domain_converters.dart';

class AuthDataMapper implements DataDomainConverter<AuthDataDTO, AuthData> {
  @override
  AuthData convertDataToDomain(AuthDataDTO dataModel) {
    return AuthData(
      userId: dataModel.userId,
      accessToken: dataModel.accessToken,
      refreshToken: dataModel.refreshToken,
      accessTokenExpiry: dataModel.accessTokenExpiry,
      refreshTokenExpiry: dataModel.refreshTokenExpiry,
    );
  }

  @override
  AuthDataDTO convertDomainToData(AuthData domainModel) {
    return AuthDataDTO(
      userId: domainModel.userId,
      accessToken: domainModel.accessToken,
      refreshToken: domainModel.refreshToken,
      accessTokenExpiry: domainModel.accessTokenExpiry,
      refreshTokenExpiry: domainModel.refreshTokenExpiry,
    );
  }
}
