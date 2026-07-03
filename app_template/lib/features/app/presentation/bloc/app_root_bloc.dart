import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_app_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_session_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_auth_state_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:app_template/features/app/domain/entities/locale_components.dart';
import 'package:app_template/features/reporting/domain/entities/error_report.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'app_root_event.dart';
part 'app_root_state.dart';

class AppRootBloc extends Bloc<AppRootEvent, AppRootState> {
  final AppLogger _logger;

  final WatchAuthStateUseCase _watchAuthState;

  final WatchLocaleUseCase _watchLocale;
  final WatchThemeModeUseCase _watchThemeMode;
  final GetEffectiveLocaleUseCase _getEffectiveLocale;
  final GetEffectiveThemeModeUseCase _getEffectiveThemeMode;

  final InitializeAppUseCase _initializeApp;
  final InitializeSessionUseCase _initializeSession;

  AppRootBloc(
    this._logger,
    this._watchAuthState,
    this._watchLocale,
    this._watchThemeMode,
    this._getEffectiveLocale,
    this._getEffectiveThemeMode,
    this._initializeApp,
    this._initializeSession,
  ) : super(AppInitializationInitial()) {
    on<AppInitializationRequested>((event, emit) async {
      emit(AppInitializationInProgress());

      try {
        await _initializeApp();
        await _initializeSession();

        add(_LocaleChangeListenerInitRequested());
        add(_ThemeModeChangeListenerInitRequested());
        add(_SessionChangeListenerInitRequested());

        emit(
          AppInitializationSuccess(
            locale: await _getEffectiveLocale(),
            themeMode: await _getEffectiveThemeMode(),
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

      final effectiveLocale = await _getEffectiveLocale();
      emit(currentState.copyWith(locale: effectiveLocale));
    });

    on<SystemBrightnessModeChanged>((event, emit) async {
      final currentState = state;
      if (currentState is! AppInitializationSuccess) {
        return;
      }

      final effectiveThemeMode = await _getEffectiveThemeMode();
      emit(currentState.copyWith(themeMode: effectiveThemeMode));
    });

    on<_LocaleChangeListenerInitRequested>((event, emit) {
      return emit.onEach(
        _watchLocale(),
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
        _watchThemeMode(),
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
        _watchAuthState(),
        onData: (data) {
          add(_SessionDataRefreshRequested());
        },
      );
    });

    on<_SessionDataRefreshRequested>((event, emit) {
      return _initializeSession();
    });
  }
}
