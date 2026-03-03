import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_core/analyzer_core.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:app_analyzer/src/cli/runner.dart';
import 'package:app_analyzer/src/plugin/plugin.dart';
import 'package:path/path.dart' as path;

// Put new analyzers here.
final _analyzers = <Analyzer>[];

void startAnalysisPluginServer(List<String> args, SendPort sendPort) {
  // Starting the server ...
  ServerPluginStarter(
    AnalyzerPlugin(
      analyzers: _analyzers,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    ),
  ).start(sendPort);
}

Future<void> runCLIAnalysis(String dirPath) async {
  final dirAbsolutePath = path.canonicalize(dirPath);
  final directory = Directory(dirAbsolutePath);
  if (!directory.existsSync()) {
    print('Directory not found: $dirPath');
    exit(1);
  }

  print('Running analysis at $dirAbsolutePath ...');
  final analysisIssues = await DirectoryAnalysisRunner(
    _analyzers,
  ).analyzeDirectory(dirAbsolutePath);

  if (analysisIssues.isEmpty) {
    print('No issues found!');
    return;
  }

  final issueCount = analysisIssues.length;
  print('\nFound ${analysisIssues.length} issue${issueCount > 1 ? 's' : ''}\n');
  for (final issue in analysisIssues) {
    print('$issue\n');
  }

  exit(1);
}
