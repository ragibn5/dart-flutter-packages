import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/publish/publish_release_candidates_command.dart';

class PublishCommand extends Command<void> {
  static const String commandName = 'publish';
  static const String commandDescription = 'Publish related commands.';

  PublishCommand() {
    addSubcommand(PublishReleaseCandidatesCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
