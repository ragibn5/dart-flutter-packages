# dev_tools

Shared developer tooling for Dart and Flutter projects.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  dev_tools: ^1.0.0
```

#### Or, From Git repo

```yaml
dev_dependencies:
  dev_tools:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: dev_tools
      ref: dev_tools-1.0.0
```

## Usage

### CLI

A single executable with per-domain subcommands is exposed:

| Command                               | Description                                                                                                                                                                |
|----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `coverage verify-packages`             | Runs every touched package's tests with coverage (or every package, with `--all`) and enforces a minimum line-coverage threshold on each (`--from`, `--to`, `--threshold`, `--skip-path`, `--all`). |
| `publish publish-release-candidates`   | Publishes and tags every touched release-candidate package (`--from`, `--to`, `--dry-run`).                                                                                |
| `release validate-release-mr` | Gates a release MR into its target branch, validating that every touched release-candidate package is complete and ready to be published (`--from`, `--to`).                     |
| `git changes`                 | Detects changes in a folder (default: the whole repository) between two refs: `git changes` (`--folder <dir>`, `--from <ref>` (default `HEAD~1`), `--to <ref>` (default `HEAD`)). |
| `replace`                     | Replaces text across files: `replace <src> <target>` (`--start <dir>`, `-e`/`--exclude`, `--follow-links`, `--ignore-case`, `--match-word`, `--regex`, `-y`/`--yes`).             |

> Note: Please see the files at `lib/src/commands` for full understanding.
