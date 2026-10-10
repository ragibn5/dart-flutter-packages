import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/find_replace/replace_command.dart';

class FindReplaceCommand extends Command<void> {
  static const String commandName = 'find-replace';
  static const String commandDescription = 'Find/replace related commands.';

  FindReplaceCommand() {
    addSubcommand(ReplaceCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
