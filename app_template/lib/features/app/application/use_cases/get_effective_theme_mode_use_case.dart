import 'package:app_template/features/app/application/use_cases/get_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';

class GetEffectiveThemeModeUseCase {
  final GetThemeModeUseCase _getThemeMode;

  GetEffectiveThemeModeUseCase(this._getThemeMode);

  /// Returns the current app theme mode.
  Future<AppThemeMode> call() => _getThemeMode();
}
