import 'package:app_template/features/reporting/domain/models/error_report.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'startup_error_reporter_event.dart';
part 'startup_error_reporter_state.dart';

class StartupErrorReporterBloc
    extends Bloc<StartupErrorReporterEvent, StartupErrorReporterState> {
  StartupErrorReporterBloc() : super(StartupErrorReporterStateInitial()) {
    on<SendErrorReport>((event, emit) async {
      emit(StartupErrorReporterStateSending());

      await Future.delayed(Duration(seconds: 3));

      emit(StartupErrorReporterStateReported());
    });
  }
}
