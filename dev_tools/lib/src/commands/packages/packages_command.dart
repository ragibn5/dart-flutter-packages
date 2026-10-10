import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/packages/all_packages_command.dart';
import 'package:dev_tools/src/commands/packages/touched_packages_command.dart';

class PackagesCommand extends Command<void> {
  static const String commandName = 'packages';
  static const String commandDescription = 'Package related commands.';

  PackagesCommand() {
    addSubcommand(TouchedPackagesCommand());
    addSubcommand(AllPackagesCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
