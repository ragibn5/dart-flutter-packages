import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

abstract interface class SetThemeModeUseCase {
  Future<void> call(AppThemeMode themeMode);
}
