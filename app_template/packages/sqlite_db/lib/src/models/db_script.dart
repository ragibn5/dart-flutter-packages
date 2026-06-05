sealed class DbScript {
  final String scriptText;

  const DbScript({required this.scriptText});
}

class SingleVersionedDbScript extends DbScript {
  final int targetVersion;

  const SingleVersionedDbScript({
    required super.scriptText,
    required this.targetVersion,
  });
}

class DbMigrationScript extends DbScript {
  final int previousVersion;
  final int presentVersion;

  const DbMigrationScript({
    required super.scriptText,
    required this.previousVersion,
    required this.presentVersion,
  });
}
