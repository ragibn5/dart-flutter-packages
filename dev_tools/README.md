# dev_tools

Creates white-label apps from app_template.

## Installation

dev_tools is this repository's own tooling and isn't published. Use it from
a package in this repository by path:

```yaml
dev_dependencies:
  dev_tools:
    path: ../dev_tools
```

## Usage

`dev_tools whitelabel create <destination>` copies the current Flutter
template (or `--template <dir>`) to `<destination>`, excluding `.git` and
project-defined paths. The destination must be new, or empty with `--force`.

> Note: Please see the files at `lib/src/commands` for full understanding.