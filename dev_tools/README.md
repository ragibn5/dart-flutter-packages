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

| Command                              | Description                                                                                                                                                           |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `coverage verify`                    | Runs every given package's tests with coverage and enforces a minimum line-coverage threshold on each (`--package`, repeatable, required; `--threshold`).             |
| `publish publish-release-candidates` | Publishes and tags every eligible release candidate among a given set of packages (`--package`, repeatable, required; `--dry-run`).                                   |
| `release validate-release-mr`        | Gates a release MR into its target branch, validating that every touched release-candidate package is complete and ready to be published (`--from`, `--to`).          |
| `packages get-touched`               | Prints the repo-root-relative path of every package touched between two git refs, one per line (`--from`, `--to`, `--skip-path`).                                     |
| `packages get-all`                   | Prints the repo-root-relative path of every package in the repository, one per line (`--skip-path`).                                                                  |
| `find-replace replace`               | Replaces text across files: `replace <src> <target>` (`--start <dir>`, `-e`/`--exclude`, `--follow-links`, `--ignore-case`, `--match-word`, `--regex`, `-y`/`--yes`). |

> Note: Please see the files at `lib/src/commands` for full understanding.
