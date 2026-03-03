import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_core/analyzer_core.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:app_analyzer/src/extensions/analysis_issue_location_extensions.dart';
import 'package:app_analyzer/src/extensions/analysis_issue_severity_extensions.dart';
import 'package:app_analyzer/src/extensions/analysis_issue_type_extensions.dart';

class AnalyzerPlugin extends ServerPlugin {
  final List<Analyzer> analyzers;

  AnalyzerPlugin({
    required this.analyzers,
    required super.resourceProvider,
  });

  @override
  List<String> get fileGlobsToAnalyze => ['**/*.dart'];

  // TODO: Give a name based on the enclosing app/package.
  @override
  String get name => 'VIVA_FLUTTER_APP_ANALYZER';

  /// The version of the ***analysis server plugin protocol*** this plugin
  /// requires.
  ///
  /// This specifies which version of the analysis server's plugin API
  /// this plugin is built against, not the version of the server itself,
  /// nor the version of this class (it may seem that way, as we are also
  /// providing a name here, which represents this plugin class).
  ///
  /// The analysis server uses this to ensure compatibility between the
  /// server and the plugin.
  @override
  String get version => '1.0.0';

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    try {
      // Get the resolved unit for the file
      final resolvedUnit = await analysisContext.currentSession.getResolvedUnit(
        path,
      );
      if (resolvedUnit is! ResolvedUnitResult) {
        return;
      }

      // Collect all issues
      final allIssues = <AnalysisIssue>[];
      for (final analyzer in analyzers) {
        final currentIssues = await analyzer.analyzeFile(analysisContext, path);
        allIssues.addAll(currentIssues);
      }

      // Notify clients about all issues
      channel.sendNotification(
        AnalysisErrorsParams(
          path,
          allIssues.map(_buildPluginAnalysisError).toList(),
        ).toNotification(),
      );
    } catch (e, st) {
      channel.sendNotification(
        PluginErrorParams(
          false,
          'Unexpected exception while analyzing file: $path',
          st.toString(),
        ).toNotification(),
      );
    }
  }

  AnalysisError _buildPluginAnalysisError(AnalysisIssue issue) {
    return AnalysisError(
      issue.data.severity.toAnalysisErrorSeverity(),
      issue.data.issueType.toAnalysisErrorType(),
      issue.location.toProtocolLocation(),
      issue.data.message,
      issue.data.code,
    );
  }
}
