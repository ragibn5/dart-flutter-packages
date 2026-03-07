import 'package:analysis_server_core/src/services/config/config_source_provider.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/workspace/workspace.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockWorkspacePackage extends Mock implements WorkspacePackage {}

class _MockAnalyzerFolder extends Mock implements Folder {}

void main() {
  const packageRootPath = 'a/b/c';

  late _MockWorkspacePackage mockWorkspacePackage;
  late _MockAnalyzerFolder mockAnalyzerFolder;

  late ConfigSourceProvider sut;

  setUp(() {
    mockWorkspacePackage = _MockWorkspacePackage();
    mockAnalyzerFolder = _MockAnalyzerFolder();
    sut = ConfigSourceProviderImpl();

    when(() => mockWorkspacePackage.root).thenReturn(mockAnalyzerFolder);
    when(() => mockAnalyzerFolder.path).thenReturn(packageRootPath);
  });

  test('Should return config source file with valid path', () {
    const configFileName = 'pubspec.yaml';
    final configSource = sut.getConfigSource(
      mockWorkspacePackage,
      configFileName,
    );

    expect(configSource.path, path.join(packageRootPath, configFileName));
  });
}
