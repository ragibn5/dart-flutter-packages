import 'package:dev_tools/src/commands/release/release_command.dart';
import 'package:dev_tools/src/commands/release/validate_release_merge_command.dart';
import 'package:test/test.dart';

void main() {
  late ReleaseCommand sut;

  setUp(() {
    sut = ReleaseCommand();
  });

  test('should expose the release name', () {
    expect(sut.name, ReleaseCommand.commandName);
  });

  test('should describe release related commands', () {
    expect(sut.description, ReleaseCommand.commandDescription);
  });

  test('should register the validate-release-mr subcommand', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>[ValidateReleaseMergeCommand.commandName]),
    );

    expect(
      sut.subcommands[ValidateReleaseMergeCommand.commandName],
      isA<ValidateReleaseMergeCommand>(),
    );
  });
}
