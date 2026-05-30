part of 'app_bloc.dart';

@immutable
sealed class AppState extends Equatable {}

final class AppInitializationInitial extends AppState {
  @override
  List<Object?> get props => [];
}

final class AppInitializationInProgress extends AppState {
  @override
  List<Object?> get props => [];
}

final class AppInitializationError extends AppState {
  final ErrorReport errorReport;

  AppInitializationError({required this.errorReport});

  @override
  List<Object?> get props => [errorReport];
}

final class AppInitializationSuccess extends AppState {
  final AppLocale locale;
  final AppThemeMode themeMode;

  AppInitializationSuccess({required this.locale, required this.themeMode});

  AppInitializationSuccess copyWith({
    AppLocale? locale,
    AppThemeMode? themeMode,
  }) {
    return AppInitializationSuccess(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() {
    return 'AppInitializationSuccess{locale: $locale, themeMode: $themeMode}';
  }

  @override
  List<Object?> get props => [locale, themeMode];
}
