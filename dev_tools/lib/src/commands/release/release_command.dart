import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/release/validate_release_merge_command.dart';

class ReleaseCommand extends Command<void> {
  static const String commandName = 'release';
  static const String commandDescription = 'Release related commands.';

  ReleaseCommand() {
    addSubcommand(ValidateReleaseMergeCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
