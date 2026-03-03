import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service_impl.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AuthModule {
  @singleton
  AuthDataService getAuthDataService(AuthDataRepository repository) {
    return AuthDataServiceImpl(repository);
  }
}
