import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:enum_parser/enum_parser.dart';

class SettingsMapper implements DataDomainConverter<SettingsDTO, AppSettings> {
  @override
  AppSettings convertDataToDomain(SettingsDTO dataModel) {
    return AppSettings(
      locale: parseEnum(
        AppLocale.values,
        rawValue: dataModel.locale,
        fallbackValue: AppSettings.defaultLocale,
      ),
      themeMode: parseEnum(
        AppThemeMode.values,
        rawValue: dataModel.themeMode,
        fallbackValue: AppSettings.defaultThemeMode,
      ),
    );
  }

  @override
  SettingsDTO convertDomainToData(AppSettings domainModel) {
    return SettingsDTO(
      locale: domainModel.locale.name,
      themeMode: domainModel.themeMode.name,
    );
  }
}
