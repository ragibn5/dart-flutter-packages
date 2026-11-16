# dev_tools

Creates white-label apps from a template project.

## Installation

dev_tools isn't published to pub.dev. Depend on it from git, pinned to a tag
or commit:

```yaml
dev_dependencies:
  dev_tools:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: dev_tools
      ref: <tag or commit>
```

## Usage

`dev_tools whitelabel create <destination>` copies the current Flutter
template (or `--template <dir>`) to `<destination>`, excluding `.git` and
project-defined paths. The destination must be new, or empty with `--force`.

> Note: Please see the files at `lib/src/commands` for full understanding.