import 'dart:async';

import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/features/app/application/services/session_initializer_service.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:app_template/features/settings/domain/services/settings_service.dart';
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
    on<AppInitializationRequested>(_handleAppInitialization);
    on<SystemLocaleChanged>(_handleSystemLocaleChanged);
    on<SystemBrightnessModeChanged>(_handleSystemBrightnessModeChanged);
    on<_SessionDataRefreshRequested>(_handleSessionDataRefresh);
    on<_ListenSessionChangeRequested>(_handleSessionChangeListenerStart);
    on<_ListenLocaleChangeRequested>(_handleLocaleChangeListenerStart);
    on<_ListenThemeModeChangeRequested>(_handleThemeModeChangeListenerStart);
  }

  Future<void> _handleAppInitialization(
    AppInitializationRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(AppInitializationInProgress());

    try {
      await _appInitializerService.initialize();
      await _sessionInitializerService.initialize();

      emit(await _buildNewAppInitializationSuccessState());

      add(_ListenLocaleChangeRequested());
      add(_ListenThemeModeChangeRequested());
      add(_ListenSessionChangeRequested());
    } catch (e, st) {
      _logger.logError(
        tag: '$AppBloc',
        message: 'Error while initializing the app',
        error: e,
        stackTrace: st,
      );

      emit(
        AppInitializationError(
          errorTitle: 'Error while initializing the app',
          errorDescription: e.toString(),
          stackTrace: st,
        ),
      );
    }
  }

  FutureOr<void> _handleSystemLocaleChanged(
    SystemLocaleChanged event,
    Emitter<AppState> emit,
  ) async {
    // TODO
  }

  FutureOr<void> _handleSystemBrightnessModeChanged(
    SystemBrightnessModeChanged event,
    Emitter<AppState> emit,
  ) {
    // TODO
  }

  FutureOr<void> _handleSessionDataRefresh(
    _SessionDataRefreshRequested event,
    Emitter<AppState> emit,
  ) {
    return _sessionInitializerService.initialize();
  }

  FutureOr<void> _handleSessionChangeListenerStart(
    _ListenSessionChangeRequested event,
    Emitter<AppState> emit,
  ) {
    return emit.onEach(
      _authDataService.watchAuthData(),
      onData: (data) {
        add(_SessionDataRefreshRequested());
      },
    );
  }

  FutureOr<void> _handleLocaleChangeListenerStart(
    _ListenLocaleChangeRequested event,
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

  FutureOr<void> _handleThemeModeChangeListenerStart(
    _ListenThemeModeChangeRequested event,
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
