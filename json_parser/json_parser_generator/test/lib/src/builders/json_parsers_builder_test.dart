import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:json_parser_generator/src/builders/json_parsers_builder.dart';
import 'package:json_parser_generator/src/models/gjp_annotated_class.dart';
import 'package:json_parser_generator/src/models/gjp_annotation_config.dart';
import 'package:json_parser_generator/src/readers/annotated_element_reader.dart';
import 'package:json_parser_generator/src/readers/gjp_annotation_reader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

class _FakeTypeChecker extends Fake implements TypeChecker {}

class _FakeAssetId extends Fake implements AssetId {}

class _MockBuildStep extends Mock implements BuildStep {}

class _MockAnnotatedElementReader extends Mock
    implements AnnotatedElementReader {}

class _MockGJPAnnotationReader extends Mock implements GJPAnnotationReader {}

class _MockAssetId extends Mock implements AssetId {}

class _MockClassElement extends Mock implements ClassElement {}

class _MockLibraryElement extends Mock implements LibraryElement {}

void main() {
  const config = JsonParsersBuilderConfig(
    outputPathRelativeToLib: 'generated/json_parsers.dart',
  );

  late _MockBuildStep mockBuildStep;
  late _MockAnnotatedElementReader mockAnnotatedElementReader;
  late _MockGJPAnnotationReader mockGJPAnnotationReader;
  late _MockAssetId mockInputId;

  late JsonParsersBuilder sut;

  setUpAll(() {
    registerFallbackValue(_FakeTypeChecker());
    registerFallbackValue(_FakeAssetId());
  });

  setUp(() {
    mockBuildStep = _MockBuildStep();
    mockAnnotatedElementReader = _MockAnnotatedElementReader();
    mockGJPAnnotationReader = _MockGJPAnnotationReader();
    mockInputId = _MockAssetId();

    sut = JsonParsersBuilder(
      config,
      annotatedClassReader: mockAnnotatedElementReader,
      gjpAnnotationReader: mockGJPAnnotationReader,
    );

    when(() => mockBuildStep.inputId).thenReturn(mockInputId);
    when(() => mockInputId.package).thenReturn('example');
    when(
      () => mockAnnotatedElementReader.read(
        mockBuildStep,
        any(),
        excludePathPrefix: any(named: 'excludePathPrefix'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () => mockBuildStep.writeAsString(any(), any()),
    ).thenAnswer((_) async {});
  });

  test('buildExtensions returns correct map', () {
    expect(sut.buildExtensions, {
      r'$lib$': [config.outputPathRelativeToLib],
    });
  });

  test('build returns early when no annotated classes are found', () async {
    when(() => mockGJPAnnotationReader.read([])).thenReturn([]);

    await sut.build(mockBuildStep);

    verifyNever(() => mockBuildStep.writeAsString(any(), any()));
  });

  test('build passes excludePathPrefix to annotated element reader', () async {
    when(() => mockGJPAnnotationReader.read([])).thenReturn([]);

    await sut.build(mockBuildStep);

    verify(
      () => mockAnnotatedElementReader.read(
        mockBuildStep,
        any(),
        excludePathPrefix: 'lib/generated/',
      ),
    ).called(1);
  });

  test('build writes output to correct AssetId', () async {
    final classElement = _MockClassElement();
    final libraryElement = _MockLibraryElement();

    when(() => classElement.displayName).thenReturn('User');
    when(() => classElement.library).thenReturn(libraryElement);
    when(
      () => libraryElement.uri,
    ).thenReturn(Uri.parse('package:example/user.dart'));

    when(() => mockGJPAnnotationReader.read([])).thenReturn([
      GJPAnnotatedClass(
        element: classElement,
        config: const GJPAnnotationConfig(registryKeys: {}),
      ),
    ]);

    await sut.build(mockBuildStep);

    final captured = verify(
      () => mockBuildStep.writeAsString(captureAny(), any()),
    ).captured;
    final writtenId = captured.first as AssetId;
    expect(writtenId.package, 'example');
    expect(writtenId.path, config.outputPathRelativeToPackageRoot);
  });
}
