import 'package:dev_tools/src/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/verify_coverage_across_packages_command.dart';
import 'package:test/test.dart';

void main() {
  late CoverageCommand sut;

  setUp(() {
    sut = CoverageCommand();
  });

  test('should expose the coverage name', () {
    expect(sut.name, CoverageCommand.commandName);
  });

  test(
    'should describe running tests with coverage and enforcing thresholds',
    () {
      expect(sut.description, CoverageCommand.commandDescription);
    },
  );

  test('should register the verify-packages subcommand', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>[VerifyCoverageAcrossPackagesCommand.commandName]),
    );

    expect(
      sut.subcommands[VerifyCoverageAcrossPackagesCommand.commandName],
      isA<VerifyCoverageAcrossPackagesCommand>(),
    );
  });
}
