part of 'app_bloc.dart';

@immutable
sealed class AppEvent {}

final class AppInitializationRequested extends AppEvent {}

final class SystemLocaleChanged extends AppEvent {}

final class SystemBrightnessModeChanged extends AppEvent {}

final class _SessionDataRefreshRequested extends AppEvent {}

final class _ListenSessionChangeRequested extends AppEvent {}

final class _ListenLocaleChangeRequested extends AppEvent {}

final class _ListenThemeModeChangeRequested extends AppEvent {}
