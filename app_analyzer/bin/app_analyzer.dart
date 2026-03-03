import 'dart:io';

import 'package:app_analyzer/app_analyzer.dart';
import 'package:args/args.dart';

import 'info.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show this help', negatable: false)
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Show version info',
      negatable: false,
    )
    ..addCommand(
      'analyze',
      ArgParser()
        ..addOption(
          'dir',
          abbr: 'd',
          help: 'Analysis directory',
          valueHelp: 'PATH',
          defaultsTo: '.',
        ),
    );

  try {
    final results = parser.parse(arguments);

    if (results.flag('help')) {
      print(helpText);
    } else if (results.flag('version')) {
      print(versionInfo);
    } else if (results.command?.name == 'analyze') {
      final dir = results.command!['dir'] as String? ?? '.';
      await runCLIAnalysis(dir);
    } else {
      // Show help if no valid command is provided
      print(helpText);
    }
  } catch (e, st) {
    print('Error: $e');
    print('$st');
    exit(1);
  }
}
