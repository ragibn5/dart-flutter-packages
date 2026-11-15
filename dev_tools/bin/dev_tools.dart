import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/whitelabel/whitelabel_command.dart';
import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

Future<void> main(List<String> args) async {
  const executableName = 'dev_tools';
  const description = 'Creates white-label apps from a template project.';
  final runner = CommandRunner<dynamic>(executableName, description)
    ..addCommand(WhitelabelCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(1);
  } on CommandExecutionException catch (e) {
    stderr.writeln(e);
    exit(1);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}
