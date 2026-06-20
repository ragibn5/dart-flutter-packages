import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/features/app/application/services/session_initializer_service.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/reporting/domain/models/error_report.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'app_root_event.dart';
part 'app_root_state.dart';

class AppRootBloc extends Bloc<AppRootEvent, AppRootState> {
  final AppLogger _logger;
  final AuthDataService _authDataService;
  final SettingsService _settingsService;
  final AppInitializerService _appInitializerService;
  final SessionInitializerService _sessionInitializerService;

  AppRootBloc(
    this._logger,
    this._authDataService,
    this._settingsService,
    this._appInitializerService,
    this._sessionInitializerService,
  ) : super(AppInitializationInitial()) {
    on<AppInitializationRequested>((event, emit) async {
      emit(AppInitializationInProgress());

      try {
        await _appInitializerService.initialize();
        await _sessionInitializerService.initialize();

        add(_LocaleChangeListenerInitRequested());
        add(_ThemeModeChangeListenerInitRequested());
        add(_SessionChangeListenerInitRequested());

        emit(
          AppInitializationSuccess(
            locale: await _settingsService.getEffectiveLocale(),
            themeMode: await _settingsService.getEffectiveThemeMode(),
          ),
        );
      } catch (e, st) {
        _logger.logError(
          tag: '$AppRootBloc',
          message: 'Error while initializing the app',
          error: e,
          stackTrace: st,
        );

        emit(
          AppInitializationError(
            errorReport: ErrorReport(
              source: '$AppRootBloc:${on<AppInitializationRequested>}',
              description: e.toString(),
              stackTrace: st,
            ),
          ),
        );
      }
    });

    on<SystemLocaleChanged>((event, emit) async {
      final currentState = state;
      if (currentState is! AppInitializationSuccess) {
        return;
      }

      final effectiveLocale = await _settingsService.getEffectiveLocale();
      emit(currentState.copyWith(locale: effectiveLocale));
    });

    on<SystemBrightnessModeChanged>((event, emit) async {
      final currentState = state;
      if (currentState is! AppInitializationSuccess) {
        return;
      }

      final effectiveThemeMode = await _settingsService.getEffectiveThemeMode();
      emit(currentState.copyWith(themeMode: effectiveThemeMode));
    });

    on<_LocaleChangeListenerInitRequested>((event, emit) {
      return emit.onEach(
        _settingsService.watchLocale(),
        onData: (newLocale) {
          final currentState = state;
          if (currentState is! AppInitializationSuccess) {
            return;
          }

          emit(currentState.copyWith(locale: newLocale));
        },
      );
    });

    on<_ThemeModeChangeListenerInitRequested>((event, emit) {
      return emit.onEach(
        _settingsService.watchThemeMode(),
        onData: (newThemeMode) {
          final currentState = state;
          if (currentState is! AppInitializationSuccess) {
            return;
          }

          emit(currentState.copyWith(themeMode: newThemeMode));
        },
      );
    });

    on<_SessionChangeListenerInitRequested>((event, emit) {
      return emit.onEach(
        _authDataService.watchAuthData(),
        onData: (data) {
          add(_SessionDataRefreshRequested());
        },
      );
    });

    on<_SessionDataRefreshRequested>((event, emit) {
      return _sessionInitializerService.initialize();
    });
  }
}
