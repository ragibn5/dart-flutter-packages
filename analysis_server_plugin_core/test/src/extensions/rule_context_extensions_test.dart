import 'package:analysis_server_plugin_core/src/extensions/rule_context_extensions.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/workspace/workspace.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockRuleContext extends Mock implements RuleContext {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockWorkspacePackage extends Mock implements WorkspacePackage {}

class _MockFile extends Mock implements File {}

class _MockFolder extends Mock implements Folder {}

void main() {
  late _MockRuleContext mockRuleContext;
  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockWorkspacePackage mockWorkspacePackage;
  late _MockFile mockFile;
  late _MockFolder mockFolder;

  setUp(() {
    mockRuleContext = _MockRuleContext();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockWorkspacePackage = _MockWorkspacePackage();
    mockFile = _MockFile();
    mockFolder = _MockFolder();

    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockFile);
  });

  group('packageRelativeUnitPath', () {
    test('Should return null if package is null', () {
      when(() => mockRuleContext.package).thenReturn(null);
      when(() => mockFile.path).thenReturn('/Users/foo/project/lib/bar.dart');

      expect(
        mockRuleContext.packageRelativeUnitPath(pathSeparator: '/'),
        isNull,
      );
    });

    test('Should return null if path is outside package root', () {
      when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
      when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
      when(() => mockFolder.path).thenReturn('/Users/foo/project');
      when(() => mockFile.path).thenReturn('/other/path/lib/bar.dart');

      expect(
        mockRuleContext.packageRelativeUnitPath(pathSeparator: '/'),
        isNull,
      );
    });

    test('Should return package-relative path for POSIX paths', () {
      when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
      when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
      when(() => mockFolder.path).thenReturn('/Users/foo/project');
      when(() => mockFile.path).thenReturn('/Users/foo/project/lib/bar.dart');

      expect(
        mockRuleContext.packageRelativeUnitPath(pathSeparator: '/'),
        'lib/bar.dart',
      );
    });

    test('Should return package-relative path for Windows paths', () {
      when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
      when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
      when(() => mockFolder.path).thenReturn(r'C:\Users\foo\project');
      when(
        () => mockFile.path,
      ).thenReturn(r'C:\Users\foo\project\lib\bar.dart');

      expect(
        mockRuleContext.packageRelativeUnitPath(pathSeparator: r'\\'),
        r'lib\bar.dart',
      );
    });

    test('Should handle package root ending with trailing separator', () {
      when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
      when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
      when(() => mockFolder.path).thenReturn('/Users/foo/project/');
      when(() => mockFile.path).thenReturn('/Users/foo/project/lib/bar.dart');

      expect(
        mockRuleContext.packageRelativeUnitPath(pathSeparator: '/'),
        'lib/bar.dart',
      );
    });

    test('Should handle mixed separators in comparison', () {
      when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
      when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
      when(() => mockFolder.path).thenReturn(r'C:\Users\foo\project');
      when(
        () => mockFile.path,
      ).thenReturn(r'C:\Users/foo/project/lib/bar.dart');

      expect(
        mockRuleContext.packageRelativeUnitPath(pathSeparator: r'\\'),
        r'lib\bar.dart',
      );
    });

    test('Should return empty string when path equals package root', () {
      when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
      when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
      when(() => mockFolder.path).thenReturn('/Users/foo/project');
      when(() => mockFile.path).thenReturn('/Users/foo/project/');

      expect(mockRuleContext.packageRelativeUnitPath(pathSeparator: '/'), '');
    });
  });
}
