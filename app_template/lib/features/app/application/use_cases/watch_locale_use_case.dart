import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';

/// Watch locale selection changes.
///
/// This emits a new value whenever the user changes the app-locale,
/// specifically, by calling `SetSettingsUseCase`.
///
/// **Please note**: Do not call `SetSettingsUseCase` in response to events
/// received from the stream return by this method, as it will result in an
/// infinite loop.
class WatchLocaleUseCase {
  final SettingsRepository _settingsRepository;

  final LocalComponentsMapper _localComponentsMapper;

  WatchLocaleUseCase(this._settingsRepository, this._localComponentsMapper);

  Stream<LocaleComponents> call() {
    return _settingsRepository
        .getSettingsStream()
        .asyncMap(
          (settings) =>
              _localComponentsMapper.mapLocaleComponents(settings.locale),
        )
        .distinct();
  }
}
