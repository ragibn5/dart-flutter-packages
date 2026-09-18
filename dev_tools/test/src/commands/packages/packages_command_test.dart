import 'package:dev_tools/src/commands/packages/all_packages_command.dart';
import 'package:dev_tools/src/commands/packages/packages_command.dart';
import 'package:dev_tools/src/commands/packages/touched_packages_command.dart';
import 'package:test/test.dart';

void main() {
  late PackagesCommand sut;

  setUp(() {
    sut = PackagesCommand();
  });

  test('should expose the packages name', () {
    expect(sut.name, PackagesCommand.commandName);
  });

  test('should describe package related commands', () {
    expect(sut.description, PackagesCommand.commandDescription);
  });

  test('should register the get-touched and get-all subcommands', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>[
        TouchedPackagesCommand.commandName,
        AllPackagesCommand.commandName,
      ]),
    );

    expect(
      sut.subcommands[TouchedPackagesCommand.commandName],
      isA<TouchedPackagesCommand>(),
    );
    expect(
      sut.subcommands[AllPackagesCommand.commandName],
      isA<AllPackagesCommand>(),
    );
  });
}
