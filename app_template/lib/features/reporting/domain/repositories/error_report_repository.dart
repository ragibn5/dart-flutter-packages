import 'package:app_template/features/reporting/domain/entities/error_report.dart';

abstract interface class ErrorReportRepository {
  Future<void> reportError(ErrorReport errorReport);
}
