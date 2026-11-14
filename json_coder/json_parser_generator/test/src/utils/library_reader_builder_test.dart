import 'package:analyzer/dart/element/element.dart';
import 'package:json_parser_generator/src/utils/library_reader_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLibraryElement extends Mock implements LibraryElement {}

void main() {
  test('callShouldReadTheGivenLibraryIfCalled', () {
    final library = _MockLibraryElement();

    expect(const LibraryReaderBuilder()(library).element, library);
  });
}
