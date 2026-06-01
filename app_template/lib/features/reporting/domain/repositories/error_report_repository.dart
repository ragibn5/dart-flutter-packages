import 'package:app_template/features/reporting/domain/models/error_report.dart';

abstract interface class ErrorReportRepository {
  Future<void> reportError(ErrorReport errorReport);
}
