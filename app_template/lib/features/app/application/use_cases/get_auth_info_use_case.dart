import 'package:app_template/features/app/domain/models/auth_info.dart';

/// Get auth info.
abstract interface class GetAuthInfoUseCase {
  Future<AuthInfo?> call();
}
