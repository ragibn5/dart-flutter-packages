import 'package:dev_tools/src/commands/find_replace/find_replace_command.dart';
import 'package:dev_tools/src/commands/find_replace/replace_command.dart';
import 'package:test/test.dart';

void main() {
  late FindReplaceCommand sut;

  setUp(() {
    sut = FindReplaceCommand();
  });

  test('should expose the find-replace name', () {
    expect(sut.name, FindReplaceCommand.commandName);
  });

  test('should describe find/replace related commands', () {
    expect(sut.description, FindReplaceCommand.commandDescription);
  });

  test('should register the replace subcommand', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>[ReplaceCommand.commandName]),
    );

    expect(
      sut.subcommands[ReplaceCommand.commandName],
      isA<ReplaceCommand>(),
    );
  });
}
