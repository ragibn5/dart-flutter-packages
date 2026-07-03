import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:json_annotation/json_annotation.dart';

class AppLocaleMapper extends JsonConverter<AppLocale?, String?> {
  const AppLocaleMapper();

  @override
  AppLocale? fromJson(String? json) {
    if (json == null) {
      return null;
    }

    return AppLocale.values.where((e) => e.name == json).firstOrNull;
  }

  @override
  String? toJson(AppLocale? object) {
    return object?.name;
  }
}
