import 'package:dev_tools/src/commands/whitelabel/create_command.dart';
import 'package:dev_tools/src/commands/whitelabel/whitelabel_command.dart';
import 'package:test/test.dart';

void main() {
  test('registers the create subcommand', () {
    final command = WhitelabelCommand();

    expect(command.name, WhitelabelCommand.commandName);
    expect(
        command.subcommands[CreateCommand.commandName], isA<CreateCommand>());
  });
}
