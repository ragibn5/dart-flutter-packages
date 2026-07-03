import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:json_annotation/json_annotation.dart';

class AppThemeModeMapper extends JsonConverter<AppThemeMode?, String?> {
  const AppThemeModeMapper();

  @override
  AppThemeMode? fromJson(String? json) {
    if (json == null) {
      return null;
    }

    return AppThemeMode.values.where((e) => e.name == json).firstOrNull;
  }

  @override
  String? toJson(AppThemeMode? object) {
    return object?.name;
  }
}
