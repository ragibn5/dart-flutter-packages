import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

abstract interface class WatchThemeModeSelectionUseCase {
  /// A stream of user selected theme mode.
  Stream<AppThemeMode> call();
}
