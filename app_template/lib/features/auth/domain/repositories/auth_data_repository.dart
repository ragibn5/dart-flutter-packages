import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:disposable/disposable.dart';
import 'package:net_models/net_models.dart';

abstract interface class AuthDataRepository implements Disposable {
  Stream<AuthData?> getAuthDataStream();

  Future<AuthData?> getCurrentAuthData();

  Future<void> setCurrentAuthData(AuthData? authData);

  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  refreshCurrentAuthData(AuthData authData);
}
