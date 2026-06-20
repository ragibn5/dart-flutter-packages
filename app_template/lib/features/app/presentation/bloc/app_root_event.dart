part of 'app_root_bloc.dart';

@immutable
sealed class AppRootEvent {}

final class AppInitializationRequested extends AppRootEvent {}

final class SystemLocaleChanged extends AppRootEvent {}

final class SystemBrightnessModeChanged extends AppRootEvent {}

final class _SessionDataRefreshRequested extends AppRootEvent {}

final class _LocaleChangeListenerInitRequested extends AppRootEvent {}

final class _ThemeModeChangeListenerInitRequested extends AppRootEvent {}

final class _SessionChangeListenerInitRequested extends AppRootEvent {}
