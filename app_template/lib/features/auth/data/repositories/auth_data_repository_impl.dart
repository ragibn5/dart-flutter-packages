import 'dart:async';

import 'package:app_template/features/auth/data/mappers/auth_data_mapper.dart';
import 'package:app_template/features/auth/data/mappers/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:core_models/core_models.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@Singleton(as: AuthDataRepository)
class AuthDataRepositoryImpl implements AuthDataRepository {
  final AuthDataMapper _authDataMapper;
  final AuthRefreshErrorMapper _authRefreshErrorMapper;

  final StreamController<AuthData?> _authDataStreamController;

  final LocalAuthDataSource _localAuthDataSource;
  final RemoteAuthDataSource _remoteAuthDataSource;

  AuthDataRepositoryImpl(
    AuthDataMapper authDataMapper,
    AuthRefreshErrorMapper authDataRefreshErrorMapper,
    LocalAuthDataSource localAuthDataSource,
    RemoteAuthDataSource remoteAuthDataSource,
  ) : this._(
        authDataMapper,
        authDataRefreshErrorMapper,
        StreamController.broadcast(),
        localAuthDataSource,
        remoteAuthDataSource,
      );

  @visibleForTesting
  AuthDataRepositoryImpl.test(
    AuthDataMapper authDataMapper,
    AuthRefreshErrorMapper authDataRefreshErrorMapper,
    StreamController<AuthData?> authDataStreamController,
    LocalAuthDataSource localAuthDataSource,
    RemoteAuthDataSource remoteAuthDataSource,
  ) : this._(
        authDataMapper,
        authDataRefreshErrorMapper,
        authDataStreamController,
        localAuthDataSource,
        remoteAuthDataSource,
      );

  AuthDataRepositoryImpl._(
    this._authDataMapper,
    this._authRefreshErrorMapper,
    this._authDataStreamController,
    this._localAuthDataSource,
    this._remoteAuthDataSource,
  );

  @override
  Future<AuthData?> getCurrentAuthData() async {
    final authDataDTO = await _localAuthDataSource.getCurrentAuthData();
    if (authDataDTO == null) {
      return null;
    }

    return _authDataMapper.convertDataToDomain(authDataDTO);
  }

  @override
  Future<void> setCurrentAuthData(AuthData? authData) {
    // First add to stream to notify listeners
    _authDataStreamController.add(authData);

    // Then add to data source
    return _localAuthDataSource.setCurrentAuthData(
      authData != null ? _authDataMapper.convertDomainToData(authData) : null,
    );
  }

  @override
  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  refreshCurrentAuthData(AuthData authData) async {
    final request = TokenRefreshRequest(refreshToken: authData.refreshToken);
    final result = await _remoteAuthDataSource.getRefreshedAuthData(request);
    return result.fold(
      onLeft: Left.new,
      onRight: (r) async => Right(
        await r.fold(
          onLeft: (l) => Left(_authRefreshErrorMapper.convertDataToDomain(l)),
          onRight: (r) async {
            final authData = _authDataMapper.convertDataToDomain(r);
            await setCurrentAuthData(authData);
            return Right(authData);
          },
        ),
      ),
    );
  }

  @override
  Stream<AuthData?> getAuthDataStream() {
    return _authDataStreamController.stream;
  }

  @disposeMethod
  @override
  void dispose() {
    _authDataStreamController.close();
  }
}
