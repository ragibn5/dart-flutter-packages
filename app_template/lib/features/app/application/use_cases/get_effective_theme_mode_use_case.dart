import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

abstract interface class GetEffectiveThemeModeUseCase {
  /// Get the effective theme mode of the app.
  Future<AppThemeMode> call();
}
