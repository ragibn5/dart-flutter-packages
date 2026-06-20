part of 'startup_error_reporter_bloc.dart';

@immutable
sealed class StartupErrorReporterEvent {}

final class SendErrorReport extends StartupErrorReporterEvent {
  final ErrorReport errorReport;

  SendErrorReport(this.errorReport);
}
