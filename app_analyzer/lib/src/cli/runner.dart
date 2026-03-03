import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_core/analyzer_core.dart';

class DirectoryAnalysisRunner {
  final List<Analyzer> analyzers;

  DirectoryAnalysisRunner(this.analyzers);

  Future<List<AnalysisIssue>> analyzeDirectory(String dirAbsolutePath) async {
    final context = AnalysisContextCollection(
      includedPaths: [dirAbsolutePath],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    return _analyzeContexts(context, analyzers);
  }

  Future<List<AnalysisIssue>> _analyzeContexts(
    AnalysisContextCollection collection,
    List<Analyzer> analyzers,
  ) async {
    final analysisIssues = <AnalysisIssue>[];

    for (final context in collection.contexts) {
      analysisIssues.addAll(await _analyzeFilesInContext(context, analyzers));
    }

    return analysisIssues;
  }

  Future<List<AnalysisIssue>> _analyzeFilesInContext(
    AnalysisContext context,
    List<Analyzer> analyzers,
  ) async {
    final issues = <AnalysisIssue>[];
    final analyzedFiles = context.contextRoot.analyzedFiles();

    for (final file in analyzedFiles) {
      issues.addAll(await _runAnalyzersOnFile(analyzers, context, file));
    }

    return issues;
  }

  Future<List<AnalysisIssue>> _runAnalyzersOnFile(
    List<Analyzer> analyzers,
    AnalysisContext context,
    String filePath,
  ) async {
    final issues = <AnalysisIssue>[];

    for (final analyzer in analyzers) {
      issues.addAll(await analyzer.analyzeFile(context, filePath));
    }

    return issues;
  }
}
