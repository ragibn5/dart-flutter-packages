import 'dart:async';

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
    on<AppInitializationRequested>(_handleAppInitializationRequest);
    on<SystemLocaleChanged>(_handleSystemLocaleChangeRequest);
    on<SystemBrightnessModeChanged>(_handleSystemBrightnessModeChangeRequest);
    on<_SessionDataRefreshRequested>(_handleSessionDataRefreshRequest);
    on<_LocaleChangeListenerInitRequested>(
      _handleLocaleChangeListenerInitRequest,
    );
    on<_ThemeModeChangeListenerInitRequested>(
      _handleThemeModeChangeListenerInitRequest,
    );
    on<_SessionChangeListenerInitRequested>(
      _handleSessionChangeListenerInitRequest,
    );
  }

  Future<void> _handleAppInitializationRequest(
    AppInitializationRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(AppInitializationInProgress());

    try {
      await _appInitializerService.initialize();
      await _sessionInitializerService.initialize();

      add(_LocaleChangeListenerInitRequested());
      add(_ThemeModeChangeListenerInitRequested());
      add(_SessionChangeListenerInitRequested());

      emit(await _buildNewAppInitializationSuccessState());
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
            source: '$AppBloc:$_handleAppInitializationRequest',
            description: e.toString(),
            stackTrace: st,
          ),
        ),
      );
    }
  }

  FutureOr<void> _handleSystemLocaleChangeRequest(
    SystemLocaleChanged event,
    Emitter<AppState> emit,
  ) async {
    // TODO
  }

  FutureOr<void> _handleSystemBrightnessModeChangeRequest(
    SystemBrightnessModeChanged event,
    Emitter<AppState> emit,
  ) {
    // TODO
  }

  FutureOr<void> _handleSessionDataRefreshRequest(
    _SessionDataRefreshRequested event,
    Emitter<AppState> emit,
  ) {
    return _sessionInitializerService.initialize();
  }

  FutureOr<void> _handleLocaleChangeListenerInitRequest(
    _LocaleChangeListenerInitRequested event,
    Emitter<AppState> emit,
  ) {
    return emit.onEach(
      _settingsService.watchLocale(),
      onData: (data) {
        if (state is! AppInitializationSuccess) return;
        emit(
          (state as AppInitializationSuccess).copyWith(
            locale: _transformAppLocale(data),
          ),
        );
      },
    );
  }

  FutureOr<void> _handleThemeModeChangeListenerInitRequest(
    _ThemeModeChangeListenerInitRequested event,
    Emitter<AppState> emit,
  ) {
    return emit.onEach(
      _settingsService.watchThemeMode(),
      onData: (data) {
        if (state is! AppInitializationSuccess) return;
        emit(
          (state as AppInitializationSuccess).copyWith(
            themeMode: _transformAppThemeMode(data),
          ),
        );
      },
    );
  }

  FutureOr<void> _handleSessionChangeListenerInitRequest(
    _SessionChangeListenerInitRequested event,
    Emitter<AppState> emit,
  ) {
    return emit.onEach(
      _authDataService.watchAuthData(),
      onData: (data) {
        add(_SessionDataRefreshRequested());
      },
    );
  }

  Future<AppInitializationSuccess>
  _buildNewAppInitializationSuccessState() async {
    return AppInitializationSuccess(
      locale: _transformAppLocale(await _settingsService.getEffectiveLocale()),
      themeMode: _transformAppThemeMode(
        await _settingsService.getEffectiveThemeMode(),
      ),
    );
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
