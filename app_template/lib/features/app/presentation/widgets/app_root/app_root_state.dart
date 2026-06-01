part of 'app_root_bloc.dart';

@immutable
sealed class AppRootState extends Equatable {}

final class AppInitializationInitial extends AppRootState {
  @override
  List<Object?> get props => [];
}

final class AppInitializationInProgress extends AppRootState {
  @override
  List<Object?> get props => [];
}

final class AppInitializationError extends AppRootState {
  final ErrorReport errorReport;

  AppInitializationError({required this.errorReport});

  @override
  List<Object?> get props => [errorReport];
}

final class AppInitializationSuccess extends AppRootState {
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
