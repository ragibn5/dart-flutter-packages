import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/verify_coverage_across_packages_command.dart';

class CoverageCommand extends Command<void> {
  static const String commandName = 'coverage';
  static const String commandDescription = 'Coverage related commands.';

  CoverageCommand() {
    addSubcommand(VerifyCoverageAcrossPackagesCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
