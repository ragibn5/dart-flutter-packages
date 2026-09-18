import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/whitelabel/create_command.dart';

/// Commands for creating and configuring a project derived from a template.
class WhitelabelCommand extends Command<void> {
  static const String commandName = 'whitelabel';
  static const String commandDescription =
      'Create and configure white-label projects from a template.';

  WhitelabelCommand() {
    addSubcommand(CreateCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
