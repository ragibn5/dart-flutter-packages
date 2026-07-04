import 'package:app_template/features/app/application/use_cases/set_settings_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';

class WatchLocaleUseCase {
  final WatchSettingsUseCase _watchSettings;

  final LocalComponentsMapper _localComponentsMapper;

  WatchLocaleUseCase(this._watchSettings, this._localComponentsMapper);

  /// Watch locale selection changes.
  ///
  /// This emits a new value whenever the user changes the app-locale,
  /// specifically, by calling the [SetSettingsUseCase].
  ///
  /// **Please note**: Do not call [SetSettingsUseCase] in response to events
  /// received from the stream return by this method, as it will result in an
  /// infinite loop.
  Stream<LocaleComponents> call() {
    return _watchSettings()
        .asyncMap(
          (settings) =>
              _localComponentsMapper.mapLocaleComponents(settings.locale),
        )
        .distinct();
  }
}
