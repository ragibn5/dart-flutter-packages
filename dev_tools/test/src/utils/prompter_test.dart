import 'dart:io';

import 'package:dev_tools/src/utils/prompter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockStdout extends Mock implements Stdout {}

class _MockStdin extends Mock implements Stdin {}

void main() {
  const sut = ConsolePrompter();

  test('writeShouldWriteTheMessageToStdoutWithoutANewline', () {
    final out = _MockStdout();

    IOOverrides.runZoned(() => sut.write('Name: '), stdout: () => out);

    verify(() => out.write('Name: ')).called(1);
  });

  test('readLineShouldReturnTheLineReadFromStdin', () {
    final input = _MockStdin();
    when(input.readLineSync).thenReturn('answer');

    final line = IOOverrides.runZoned(sut.readLine, stdin: () => input);

    expect(line, 'answer');
  });
}
