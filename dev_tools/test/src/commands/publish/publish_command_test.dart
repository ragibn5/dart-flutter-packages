import 'package:dev_tools/src/commands/publish/publish_command.dart';
import 'package:dev_tools/src/commands/publish/publish_release_candidates_command.dart';
import 'package:test/test.dart';

void main() {
  late PublishCommand sut;

  setUp(() {
    sut = PublishCommand();
  });

  test('should expose the publish name', () {
    expect(sut.name, PublishCommand.commandName);
  });

  test('should describe publish related commands', () {
    expect(sut.description, PublishCommand.commandDescription);
  });

  test('should register the publish-release-candidates subcommand', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>[PublishReleaseCandidatesCommand.commandName]),
    );

    expect(
      sut.subcommands[PublishReleaseCandidatesCommand.commandName],
      isA<PublishReleaseCandidatesCommand>(),
    );
  });
}
