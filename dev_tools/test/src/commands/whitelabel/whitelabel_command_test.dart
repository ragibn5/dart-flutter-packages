import 'package:dev_tools/src/commands/whitelabel/clean_command.dart';
import 'package:dev_tools/src/commands/whitelabel/create_command.dart';
import 'package:dev_tools/src/commands/whitelabel/firebase_command.dart';
import 'package:dev_tools/src/commands/whitelabel/setup_command.dart';
import 'package:dev_tools/src/commands/whitelabel/whitelabel_command.dart';
import 'package:test/test.dart';

void main() {
  test('constructorShouldRegisterEveryWhiteLabelSubcommand', () {
    final command = WhitelabelCommand();

    expect(command.name, WhitelabelCommand.commandName);
    expect(
        command.subcommands[CreateCommand.commandName], isA<CreateCommand>());
    expect(command.subcommands[CleanCommand.commandName], isA<CleanCommand>());
    expect(command.subcommands[SetupCommand.commandName], isA<SetupCommand>());
    expect(
      command.subcommands[FirebaseCommand.commandName],
      isA<FirebaseCommand>(),
    );
  });

  test('descriptionShouldDescribeTheCommand', () {
    expect(
      WhitelabelCommand().description,
      WhitelabelCommand.commandDescription,
    );
  });
}
