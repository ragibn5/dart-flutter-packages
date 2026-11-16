import 'dart:io';

import 'package:dev_tools/src/utils/run_interactive_process.dart';
import 'package:test/test.dart';

void main() {
  const sut = RunInteractiveProcess();

  test('callShouldReturnTheExitCodeOfTheProcess', () async {
    expect(await sut('sh', ['-c', 'exit 3']), 3);
  });

  test('callShouldRunTheProcessInTheWorkingDirectoryIfOneIsGiven', () async {
    final dir = Directory.systemTemp.createTempSync('run_interactive_process');
    addTearDown(() => dir.deleteSync(recursive: true));
    final expected = dir.resolveSymbolicLinksSync();

    final exitCode = await sut(
      'sh',
      ['-c', '[ "\$(pwd -P)" = "$expected" ]'],
      workingDirectory: dir.path,
    );

    expect(exitCode, 0);
  });

  test('callShouldShareThisTerminalIfInheritStdioIsSet', () async {
    expect(await sut('sh', ['-c', 'exit 0'], inheritStdio: true), 0);
  });
}
