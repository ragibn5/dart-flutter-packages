import 'package:analyzer/dart/element/element.dart';
import 'package:generator_core/generator_core.dart';
import 'package:glob/glob.dart';
import 'package:json_parser_generator/src/readers/annotated_element_reader.dart';
import 'package:json_parser_generator/src/utils/library_reader_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockBuildStep extends Mock implements BuildStep {}

class _MockResolver extends Mock implements Resolver {}

class _MockLibraryReaderBuilder extends Mock implements LibraryReaderBuilder {}

class _MockLibraryReader extends Mock implements LibraryReader {}

class _MockLibraryElement extends Mock implements LibraryElement {}

class _MockAssetId extends Mock implements AssetId {}

class _MockTypeChecker extends Mock implements TypeChecker {}

class _MockAnnotatedElement extends Mock implements AnnotatedElement {}

void main() {
  late _MockBuildStep mockBuildStep;
  late _MockResolver mockResolver;
  late _MockLibraryReaderBuilder mockLibraryReaderBuilder;
  late _MockLibraryReader mockLibraryReader;
  late _MockTypeChecker mockAnnotation;

  late AnnotatedElementReader sut;

  setUpAll(() {
    registerFallbackValue(Glob('lib/**/*.dart'));
    registerFallbackValue(AssetId('xyz', 'lib/src/models/user.dart'));
  });

  setUp(() {
    mockBuildStep = _MockBuildStep();
    mockResolver = _MockResolver();
    mockLibraryReaderBuilder = _MockLibraryReaderBuilder();
    mockLibraryReader = _MockLibraryReader();
    mockAnnotation = _MockTypeChecker();

    sut = AnnotatedElementReader.test(mockLibraryReaderBuilder);

    when(() => mockBuildStep.resolver).thenReturn(mockResolver);
  });

  _MockAssetId buildAsset(String path) {
    final asset = _MockAssetId();
    when(() => asset.path).thenReturn(path);
    return asset;
  }

  void stubAssets(List<_MockAssetId> assets) {
    when(
      () => mockBuildStep.findAssets(any()),
    ).thenAnswer((_) => Stream.fromIterable(assets));
  }

  void stubLibrary(_MockAssetId asset, List<AnnotatedElement> elements) {
    final libraryElement = _MockLibraryElement();
    when(() => mockResolver.isLibrary(asset)).thenAnswer((_) async => true);
    when(
      () => mockResolver.libraryFor(asset),
    ).thenAnswer((_) async => libraryElement);
    when(
      () => mockLibraryReaderBuilder(libraryElement),
    ).thenReturn(mockLibraryReader);
    when(
      () => mockLibraryReader.annotatedWith(mockAnnotation),
    ).thenReturn(elements);
  }

  void stubNonLibrary(_MockAssetId asset) {
    when(() => mockResolver.isLibrary(asset)).thenAnswer((_) async => false);
  }

  test('Returns empty list when no assets are found', () async {
    stubAssets([]);

    final result = await sut.read(mockBuildStep, mockAnnotation);

    expect(result, isEmpty);
  });

  test('Skips assets whose path starts with excludePathPrefix', () async {
    final asset = buildAsset('lib/src/generated/foo.dart');
    stubAssets([asset]);

    final result = await sut.read(
      mockBuildStep,
      mockAnnotation,
      excludePathPrefix: 'lib/src/generated/',
    );

    expect(result, isEmpty);
    verifyNever(() => mockResolver.isLibrary(any()));
  });

  test('Processes assets that do not match excludePathPrefix', () async {
    final excluded = buildAsset('lib/src/generated/foo.dart');
    final included = buildAsset('lib/src/foo.dart');
    final element = _MockAnnotatedElement();

    stubAssets([excluded, included]);
    stubLibrary(included, [element]);

    final result = await sut.read(
      mockBuildStep,
      mockAnnotation,
      excludePathPrefix: 'lib/src/generated/',
    );

    expect(result, [element]);
    verifyNever(() => mockResolver.isLibrary(excluded));
  });

  test('Returns empty list when asset is not a library', () async {
    final asset = buildAsset('lib/src/foo.dart');
    stubAssets([asset]);
    stubNonLibrary(asset);

    final result = await sut.read(mockBuildStep, mockAnnotation);

    expect(result, isEmpty);
  });

  test('Returns empty list when library has no annotated elements', () async {
    final asset = buildAsset('lib/src/foo.dart');
    stubAssets([asset]);
    stubLibrary(asset, []);

    final result = await sut.read(mockBuildStep, mockAnnotation);

    expect(result, isEmpty);
  });

  test('Returns annotated elements from a library', () async {
    final asset = buildAsset('lib/src/foo.dart');
    final element = _MockAnnotatedElement();
    stubAssets([asset]);
    stubLibrary(asset, [element]);

    final result = await sut.read(mockBuildStep, mockAnnotation);

    expect(result, [element]);
  });

  test('Collects annotated elements across multiple libraries', () async {
    final asset1 = buildAsset('lib/src/foo.dart');
    final asset2 = buildAsset('lib/src/bar.dart');
    final element1 = _MockAnnotatedElement();
    final element2 = _MockAnnotatedElement();
    final libraryElement1 = _MockLibraryElement();
    final libraryElement2 = _MockLibraryElement();
    final mockLibraryReader2 = _MockLibraryReader();

    stubAssets([asset1, asset2]);

    when(() => mockResolver.isLibrary(asset1)).thenAnswer((_) async => true);
    when(() => mockResolver.isLibrary(asset2)).thenAnswer((_) async => true);
    when(
      () => mockResolver.libraryFor(asset1),
    ).thenAnswer((_) async => libraryElement1);
    when(
      () => mockResolver.libraryFor(asset2),
    ).thenAnswer((_) async => libraryElement2);
    when(
      () => mockLibraryReaderBuilder(libraryElement1),
    ).thenReturn(mockLibraryReader);
    when(
      () => mockLibraryReaderBuilder(libraryElement2),
    ).thenReturn(mockLibraryReader2);
    when(
      () => mockLibraryReader.annotatedWith(mockAnnotation),
    ).thenReturn([element1]);
    when(
      () => mockLibraryReader2.annotatedWith(mockAnnotation),
    ).thenReturn([element2]);

    final result = await sut.read(mockBuildStep, mockAnnotation);

    expect(result, [element1, element2]);
  });
}
