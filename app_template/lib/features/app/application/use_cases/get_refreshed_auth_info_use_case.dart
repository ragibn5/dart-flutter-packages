import 'package:app_template/features/app/domain/models/auth_info.dart';

/// Get refreshed auth info.
abstract interface class GetRefreshedAuthInfoUseCase {
  Future<AuthInfo?> call();
}
