import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/domain/entities/app_settings.dart';
import 'package:data_domain_converters/data_domain_converters.dart';

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
