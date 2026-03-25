// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:build/build.dart';
import 'package:generator_core/src/models/session_data.dart';
import 'package:generator_core/src/services/session/session_data_factory.dart';
import 'package:generator_core/src/services/session/session_data_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockSessionDataFactory extends Mock implements SessionDataFactory {}

class _MockBuildStep extends Mock implements BuildStep {}

class _MockSessionData extends Mock implements SessionData {}

void main() {
  const packageName = 'my_package';
  const builderOptions = BuilderOptions({'key': 'value'});

  late _MockSessionDataFactory mockSessionDataFactory;
  late _MockBuildStep mockBuildStep;
  late _MockSessionData mockSessionData;

  late SessionDataManager sut;

  setUp(() {
    mockSessionDataFactory = _MockSessionDataFactory();
    mockBuildStep = _MockBuildStep();
    mockSessionData = _MockSessionData();

    sut = SessionDataManagerImpl.test({}, mockSessionDataFactory);

    when(
      () => mockBuildStep.inputId,
    ).thenReturn(AssetId(packageName, 'lib/something.dart'));
    when(
      () =>
          mockSessionDataFactory.createSessionData(mockBuildStep, builderOptions),
    ).thenAnswer((_) async => mockSessionData);
  });

  test('If already cached, return cached SessionData', () async {
    final localSUT = SessionDataManagerImpl.test({
      packageName: mockSessionData,
    }, mockSessionDataFactory);

    final result = await localSUT.getSessionDataFor(
      mockBuildStep,
      builderOptions,
    );
    expect(result.isNewlyCreated, false);
    expect(result.sessionData, mockSessionData);
    verifyNever(
      () =>
          mockSessionDataFactory.createSessionData(mockBuildStep, builderOptions),
    );
  });

  test('If not cached, return newly created SessionData', () async {
    final result = await sut.getSessionDataFor(mockBuildStep, builderOptions);
    expect(result.isNewlyCreated, true);
    expect(result.sessionData, mockSessionData);
    verify(
      () =>
          mockSessionDataFactory.createSessionData(mockBuildStep, builderOptions),
    ).called(1);
  });
}
