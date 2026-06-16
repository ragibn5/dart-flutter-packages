// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:analysis_server_core/src/models/session_data.dart';
import 'package:analysis_server_core/src/services/session/session_data_factory.dart';
import 'package:analysis_server_core/src/services/session/session_data_manager.dart';
import 'package:analysis_server_core/src/typedefs/typedefs.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/workspace/workspace.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockSessionDataFactory extends Mock implements SessionDataFactory {}

class _MockRuleContext extends Mock implements RuleContext {}

class _MockWorkspacePackage extends Mock implements WorkspacePackage {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockRuleContextFolder extends Mock implements AnalyzerFolder {}

class _MockRuleContextFile extends Mock implements AnalyzerFile {}

class _MockSessionData extends Mock implements SessionData {}

void main() {
  const packageRoot = 'a/b/c/';
  const unitParent = '$packageRoot/lib';

  late _MockSessionDataFactory mockSessionDataFactory;
  late _MockRuleContext mockRuleContext;
  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockWorkspacePackage mockWorkspacePackage;
  late _MockRuleContextFolder mockContextPackageRoot;
  late _MockRuleContextFolder mockContextUnitParent;
  late _MockRuleContextFile mockContextUnitFile;
  late _MockSessionData mockSessionData;

  late SessionDataManager sut;

  setUp(() {
    mockSessionDataFactory = _MockSessionDataFactory();
    mockRuleContext = _MockRuleContext();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockWorkspacePackage = _MockWorkspacePackage();
    mockContextPackageRoot = _MockRuleContextFolder();
    mockContextUnitParent = _MockRuleContextFolder();
    mockContextUnitFile = _MockRuleContextFile();
    mockSessionData = _MockSessionData();

    sut = SessionDataManagerImpl.test({}, mockSessionDataFactory);

    when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
    when(() => mockWorkspacePackage.root).thenReturn(mockContextPackageRoot);
    when(() => mockContextPackageRoot.path).thenReturn(packageRoot);
    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockContextUnitFile);
    when(() => mockContextUnitFile.parent).thenReturn(mockContextUnitParent);
    when(() => mockContextUnitParent.path).thenReturn(unitParent);
    when(
      () => mockSessionDataFactory.createSessionData(mockRuleContext),
    ).thenReturn(mockSessionData);
  });

  test('If already cached, return cached SessionData', () {
    final localSUT = SessionDataManagerImpl.test({
      packageRoot: mockSessionData,
    }, mockSessionDataFactory);

    final sessionData = localSUT.getSessionDataFor(mockRuleContext);
    expect(sessionData.isNewlyCreated, false);
    expect(sessionData.sessionData, mockSessionData);
    verifyNever(
      () => mockSessionDataFactory.createSessionData(mockRuleContext),
    );
  });

  test('If not cached, return newly created SessionData', () {
    final sessionData = sut.getSessionDataFor(mockRuleContext);
    expect(sessionData.isNewlyCreated, true);
    expect(sessionData.sessionData, mockSessionData);
    verify(
      () => mockSessionDataFactory.createSessionData(mockRuleContext),
    ).called(1);
  });
}
