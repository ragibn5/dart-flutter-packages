import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/whitelabel/create_command.dart';
import 'package:dev_tools/src/use_cases/whitelabel/copy_template_project.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockCopyTemplateProject extends Mock implements CopyTemplateProject {}

void main() {
  late _MockCopyTemplateProject copyTemplateProject;
  late CommandRunner<void> runner;

  setUp(() {
    copyTemplateProject = _MockCopyTemplateProject();
    when(
      () => copyTemplateProject(
        template: any(named: 'template'),
        destination: any(named: 'destination'),
        allowExistingEmptyDirectory: any(named: 'allowExistingEmptyDirectory'),
      ),
    ).thenAnswer((_) async => '/abs/new_app');
    runner = CommandRunner<void>('dev_tools', 'test')
      ..addCommand(CreateCommand(copyTemplateProject: copyTemplateProject));
  });

  test('runShouldCopyTheTemplateAndSayWhereTheProjectIs', () async {
    final printed = await capturePrints(
      () => runner.run(['create', '-t', '/template', '--force', 'new_app']),
    );

    verify(
      () => copyTemplateProject(
        template: '/template',
        destination: 'new_app',
        allowExistingEmptyDirectory: true,
      ),
    ).called(1);
    expect(
      printed,
      'White-label project created at: /abs/new_app\n'
      'Next: cd "/abs/new_app" and run the configuration commands there.\n',
    );
  });

  test('runShouldRejectAnythingButOneDestination', () {
    expect(runner.run(['create']), throwsA(isA<UsageException>()));
  });

  test('descriptionShouldDescribeTheCommand', () {
    expect(CreateCommand().description, CreateCommand.commandDescription);
  });
}
