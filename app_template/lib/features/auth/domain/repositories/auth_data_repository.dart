import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/either.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:disposable/disposable.dart';

abstract interface class AuthDataRepository implements Disposable {
  Stream<AuthData?> getAuthDataStream();

  Future<AuthData?> getCurrentAuthData();

  Future<void> setCurrentAuthData(AuthData? authData);

  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  refreshCurrentAuthData(AuthData authData);
}
