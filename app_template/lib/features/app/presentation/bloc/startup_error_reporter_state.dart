part of 'startup_error_reporter_bloc.dart';

@immutable
sealed class StartupErrorReporterState {}

final class StartupErrorReporterStateInitial
    extends StartupErrorReporterState {}

final class StartupErrorReporterStateSending
    extends StartupErrorReporterState {}

final class StartupErrorReporterStateError extends StartupErrorReporterState {}

final class StartupErrorReporterStateReported
    extends StartupErrorReporterState {}
