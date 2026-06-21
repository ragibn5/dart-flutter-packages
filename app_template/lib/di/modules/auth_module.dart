import 'dart:async';

import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_repository_impl.dart';
import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source_impl.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source_impl.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service_impl.dart';
import 'package:injectable/injectable.dart';
import 'package:preference_store/preference_store.dart';

@module
abstract class AuthModule {
  AuthDataMapper getAuthDataMapper() {
    return AuthDataMapper();
  }

  AuthRefreshErrorMapper getAuthRefreshErrorMapper() {
    return AuthRefreshErrorMapper();
  }

  @singleton
  RemoteAuthDataSource getRemoteAuthDataSource(
    AppServerTokenRefreshApiClient client,
  ) {
    return RemoteAuthDataSourceImpl(client);
  }

  @singleton
  LocalAuthDataSource getLocalAuthDataSource(PreferenceStore preferenceStore) {
    return LocalAuthDataSourceImpl(preferenceStore);
  }

  @singleton
  AuthDataRepository getAuthDataRepository(
    AuthDataMapper authDataMapper,
    AuthRefreshErrorMapper authRefreshErrorMapper,
    LocalAuthDataSource localAuthDataSource,
    RemoteAuthDataSource remoteAuthDataSource,
  ) {
    return AuthDataRepositoryImpl(
      StreamController.broadcast(),
      authDataMapper,
      authRefreshErrorMapper,
      localAuthDataSource,
      remoteAuthDataSource,
    );
  }

  @singleton
  AuthDataService getAuthDataService(AuthDataRepository repository) {
    return AuthDataServiceImpl(repository);
  }
}
