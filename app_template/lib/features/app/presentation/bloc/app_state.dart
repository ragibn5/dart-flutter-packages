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
  @override
  List<Object?> get props => [];
}

final class AppInitializationSuccess extends AppState {
  final Locale locale;
  final ThemeMode themeMode;

  AppInitializationSuccess({required this.locale, required this.themeMode});

  AppInitializationSuccess copyWith({Locale? locale, ThemeMode? themeMode}) {
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
