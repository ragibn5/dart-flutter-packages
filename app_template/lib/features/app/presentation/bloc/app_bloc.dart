import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/features/app/application/services/session_initializer_service.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/reporting/domain/models/error_report.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:app_template/shared/logger/app_logger.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

part 'app_event.dart';
part 'app_state.dart';

@singleton
class AppBloc extends Bloc<AppEvent, AppState> {
  final AppLogger _logger;
  final AuthDataService _authDataService;
  final SettingsService _settingsService;
  final AppInitializerService _appInitializerService;
  final SessionInitializerService _sessionInitializerService;

  AppBloc(
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
            locale: _transformAppLocale(
              await _settingsService.getEffectiveLocale(),
            ),
            themeMode: _transformAppThemeMode(
              await _settingsService.getEffectiveThemeMode(),
            ),
          ),
        );
      } catch (e, st) {
        _logger.logError(
          tag: '$AppBloc',
          message: 'Error while initializing the app',
          error: e,
          stackTrace: st,
        );

        emit(
          AppInitializationError(
            errorReport: ErrorReport(
              source: '$AppBloc:${on<AppInitializationRequested>}',
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
      emit(currentState.copyWith(locale: _transformAppLocale(effectiveLocale)));
    });

    on<SystemBrightnessModeChanged>((event, emit) async {
      final currentState = state;
      if (currentState is! AppInitializationSuccess) {
        return;
      }

      final effectiveThemeMode = await _settingsService.getEffectiveThemeMode();
      emit(
        currentState.copyWith(
          themeMode: _transformAppThemeMode(effectiveThemeMode),
        ),
      );
    });

    on<_SessionDataRefreshRequested>((event, emit) {
      return _sessionInitializerService.initialize();
    });

    on<_LocaleChangeListenerInitRequested>((event, emit) {
      return emit.onEach(
        _settingsService.watchLocale(),
        onData: (data) {
          final currentState = state;
          if (currentState is! AppInitializationSuccess) {
            return;
          }

          emit(currentState.copyWith(locale: _transformAppLocale(data)));
        },
      );
    });

    on<_ThemeModeChangeListenerInitRequested>((event, emit) {
      return emit.onEach(
        _settingsService.watchThemeMode(),
        onData: (data) {
          final currentState = state;
          if (currentState is! AppInitializationSuccess) {
            return;
          }

          emit(currentState.copyWith(themeMode: _transformAppThemeMode(data)));
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
  }

  Locale _transformAppLocale(AppLocale data) {
    return Locale.fromSubtags(
      languageCode: data.languageCode,
      scriptCode: data.scriptCode,
      countryCode: data.countryCode,
    );
  }

  ThemeMode _transformAppThemeMode(AppThemeMode data) {
    return switch (data) {
      AppThemeMode.LIGHT => ThemeMode.light,
      AppThemeMode.DARK => ThemeMode.dark,
      AppThemeMode.SYSTEM => ThemeMode.system,
    };
  }
}
