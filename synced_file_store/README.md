# synced_file_store

A string store backed by a single file, whose reads and writes are queued one at a time so concurrent callers never overlap.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  synced_file_store: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  synced_file_store:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: synced_file_store
      ref: synced_file_store-1.0.0
```

## Example

See the [example](example/example.dart) for a complete demonstration.
