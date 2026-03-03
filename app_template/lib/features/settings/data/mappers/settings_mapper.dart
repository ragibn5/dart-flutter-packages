import 'package:app_template/core/converters/data_domain_converter.dart';
import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: DataDomainConverter<SettingsDTO, AppSettings>)
class SettingsMapper implements DataDomainConverter<SettingsDTO, AppSettings> {
  @override
  AppSettings convertDataToDomain(SettingsDTO dataModel) {
    return AppSettings(
      locale: dataModel.locale,
      themeMode: dataModel.themeMode,
    );
  }

  @override
  SettingsDTO convertDomainToData(AppSettings domainModel) {
    return SettingsDTO(
      locale: domainModel.locale,
      themeMode: domainModel.themeMode,
    );
  }
}
