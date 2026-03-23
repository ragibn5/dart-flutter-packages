import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:json_parser_generator/src/readers/gjp_annotation_reader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

class _MockAnnotatedElement extends Mock implements AnnotatedElement {}

class _MockConstantReader extends Mock implements ConstantReader {}

class _MockClassElement extends Mock implements ClassElement {}

class _MockElement extends Mock implements Element {}

class _MockDartObject extends Mock implements DartObject {}

/// Builds a [_MockAnnotatedElement] whose `.element` is a plain [_MockElement]
/// (i.e. NOT a [ClassElement]).
_MockAnnotatedElement _buildNonClassAnnotatedElement() {
  final annotated = _MockAnnotatedElement();
  when(() => annotated.element).thenReturn(_MockElement());
  return annotated;
}

/// Builds a [_MockAnnotatedElement] whose `.element` is a [_MockClassElement]
/// and whose annotation exposes [keysReader] for the 'registryKeys' field.
_MockAnnotatedElement _buildClassAnnotatedElement(
  _MockConstantReader keysReader,
) {
  final annotatedElement = _MockAnnotatedElement();
  final annotation = _MockConstantReader();
  final classElement = _MockClassElement();

  when(() => annotatedElement.element).thenReturn(classElement);
  when(() => annotatedElement.annotation).thenReturn(annotation);
  when(() => annotation.read('registryKeys')).thenReturn(keysReader);

  return annotatedElement;
}

/// Builds a registry key reader.
///
/// - If [rawValues] is null, mimics the `registryKeys` field
///   of the annotation being unset — [ConstantReader.isNull] is true.
/// - If [rawValues] is an empty list, mimics the `registryKeys` field
///    of the annotation being set to an empty set (`registryKeys: {}`).
/// - If [rawValues] is a non-empty list, mimics the `registryKeys` field
///   of the annotation being set to a set of string values, where null
///   entries represent non-string [DartObject] values.
_MockConstantReader _buildRegistryKeysReader(List<String?>? rawValues) {
  final r = _MockConstantReader();
  if (rawValues == null) {
    when(() => r.isNull).thenReturn(true);
    return r;
  }

  when(() => r.isNull).thenReturn(false);
  final dartObjects = rawValues.map((v) {
    final dartObject = _MockDartObject();
    if (v == null) {
      when(dartObject.toStringValue).thenReturn(null);
    } else {
      when(dartObject.toStringValue).thenReturn(v);
    }
    return dartObject;
  }).toList();

  when(() => r.setValue).thenReturn(dartObjects.toSet());

  return r;
}

void main() {
  late GJPAnnotationReader reader;

  setUp(() {
    reader = const GJPAnnotationReader();
  });

  test('Returns empty list when elements list is empty', () {
    expect(reader.read([]), isEmpty);
  });

  test('Skips non-class elements but processes class elements', () {
    final result = reader.read([
      _buildNonClassAnnotatedElement(),
      _buildClassAnnotatedElement(_buildRegistryKeysReader(null)),
    ]);
    expect(result, hasLength(1));
  });

  test('Produces empty registryKeys when annotation value is null', () {
    final result = reader.read([
      _buildClassAnnotatedElement(_buildRegistryKeysReader(null)),
    ]);
    expect(result.first.config.registryKeys, isEmpty);
  });

  test('Lowercases and trims keys', () {
    final result = reader.read([
      _buildClassAnnotatedElement(
        _buildRegistryKeysReader(['Foo', ' Bar ', 'BAZ']),
      ),
    ]);
    expect(result.first.config.registryKeys, {'foo', 'bar', 'baz'});
  });

  test('Filters out empty and whitespace-only keys', () {
    final result = reader.read([
      _buildClassAnnotatedElement(
        _buildRegistryKeysReader(['valid', '', '  ']),
      ),
    ]);
    expect(result.first.config.registryKeys, {'valid'});
  });

  test('Filters out null or blank keys', () {
    final result = reader.read([
      _buildClassAnnotatedElement(
        _buildRegistryKeysReader([null, '', ' ', 'keep']),
      ),
    ]);
    expect(result.first.config.registryKeys, {'keep'});
  });

  test('Deduplicates keys that collide after lowercasing', () {
    final result = reader.read([
      _buildClassAnnotatedElement(
        _buildRegistryKeysReader(['Alpha', 'alpha', 'ALPHA']),
      ),
    ]);
    expect(result.first.config.registryKeys, {'alpha'});
  });

  test('Element field references the exact ClassElement from the input', () {
    final annotated = _buildClassAnnotatedElement(
      _buildRegistryKeysReader(null),
    );
    final expected = annotated.element as ClassElement;

    final result = reader.read([annotated]);

    expect(result.first.element, same(expected));
  });
}
