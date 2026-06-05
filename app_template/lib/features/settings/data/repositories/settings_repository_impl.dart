import 'dart:async';

import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/data/sources/settings_data_source.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@Singleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final DataDomainConverter<SettingsDTO, AppSettings> _settingsMapper;
  final StreamController<AppSettings> _settingsStreamController;
  final SettingsDataSource _settingsDataSource;

  SettingsRepositoryImpl(
    DataDomainConverter<SettingsDTO, AppSettings> settingsMapper,
    SettingsDataSource settingsDataSource,
  ) : this._(settingsMapper, StreamController.broadcast(), settingsDataSource);

  @visibleForTesting
  SettingsRepositoryImpl.test(
    DataDomainConverter<SettingsDTO, AppSettings> settingsMapper,
    StreamController<AppSettings> settingsController,
    SettingsDataSource settingsDataSource,
  ) : this._(settingsMapper, settingsController, settingsDataSource);

  SettingsRepositoryImpl._(
    this._settingsMapper,
    this._settingsStreamController,
    this._settingsDataSource,
  );

  @override
  Future<AppSettings> getCurrentSettings() async {
    final settingsDTO = await _settingsDataSource.getCurrentSettings();
    if (settingsDTO == null) {
      return const AppSettings();
    }

    return _settingsMapper.convertDataToDomain(settingsDTO);
  }

  @override
  Future<void> setCurrentSettings(AppSettings settings) async {
    // First add to stream to notify listeners
    _settingsStreamController.add(settings);

    // Then add to data source
    final settingsDTO = _settingsMapper.convertDomainToData(settings);
    return _settingsDataSource.setCurrentSettings(settingsDTO);
  }

  @override
  Stream<AppSettings> getSettingsStream() => _settingsStreamController.stream;

  @disposeMethod
  @override
  FutureOr<void> dispose() {
    _settingsStreamController.close();
  }
}
