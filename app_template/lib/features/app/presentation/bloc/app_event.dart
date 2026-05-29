part of 'app_bloc.dart';

@immutable
sealed class AppEvent {}

final class AppInitializationRequested extends AppEvent {}

final class SystemLocaleChanged extends AppEvent {}

final class SystemBrightnessModeChanged extends AppEvent {}

final class _SessionDataRefreshRequested extends AppEvent {}

final class _LocaleChangeListenerInitRequested extends AppEvent {}

final class _ThemeModeChangeListenerInitRequested extends AppEvent {}

final class _SessionChangeListenerInitRequested extends AppEvent {}
