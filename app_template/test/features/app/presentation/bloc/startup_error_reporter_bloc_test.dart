import 'package:app_template/features/app/domain/models/error_report.dart';
import 'package:app_template/features/app/presentation/bloc/startup_error_reporter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final errorReport = ErrorReport(
    source: 'test',
    description: 'failed',
    stackTrace: StackTrace.empty,
  );

  blocTest<StartupErrorReporterBloc, StartupErrorReporterState>(
    'sendShouldEmitSendingThenReported',
    build: StartupErrorReporterBloc.new,
    act: (bloc) => bloc.add(SendErrorReport(errorReport)),
    wait: const Duration(seconds: 3),
    expect: () => [
      isA<StartupErrorReporterStateSending>(),
      isA<StartupErrorReporterStateReported>(),
    ],
  );
}
