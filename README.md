# dart-flutter-packages

A curated collection of Dart and Flutter packages designed to streamline development, promote code reuse, enforce architectural consistency, and standardize best practices across projects.

---

## Package List

### Core Packages

Foundational utilities and infrastructure packages with minimal dependencies. These packages form the base layer and are intended to be reusable across all projects.

- [`dart_functionals`](dart_functionals)
- [`extended_string`](extended_string)
- [`collection_utils`](collection_utils)
- [`extended_datetime`](extended_datetime)
- [`extended_color`](extended_color)
- [`loghub`](loghub)
- [`net_models`](net_models)
- [`generator_core`](generator_core)
- [`analysis_server_plugin_core`](analysis_server_plugin_core)
- [`analysis_plugin_test_helper`](analysis_plugin_test_helper)

---

### Intermediate Packages

Built on top of the core layer. These packages provide higher-level tooling, UI components, code generation utilities, and architectural support.

- [`parser_core`](parser_core)
- [`json_coder`](json_coder)
- [`json_parser_annotations`](json_coder/json_parser_annotations)
- [`json_parser_linter`](json_coder/json_parser_linter)
- [`json_parser_generator`](json_coder/json_parser_generator)
- [`synced_file_store`](synced_file_store)
- [`preference_store`](preference_store)
- [`sqlite_db`](sqlite_db)
- [`base_auth_interceptor`](base_auth_interceptor)
- [`feature_api_client`](feature_api_client)
- [`infinity_radio_group`](infinity_radio_group)
- [`infinity_selection_group`](infinity_selection_group)
- [`infinity_menu`](infinity_menu)
- [`clean_arch_linter`](clean_arch_linter)

---

### Plugins

Flutter plugins with an Android implementation.

- [`document_tree_android`](document_tree/document_tree_android)
- [`media_provider_android`](media_provider/media_provider_android)
- [`user_provider_android`](user_provider/user_provider_android)

---

### Tooling

Command-line tools for working with projects, not published to pub.dev.

- [`dev_tools`](dev_tools): creates white-label apps from a template project

---

## Using Packages

### Internal Usage

Refer to each package’s individual documentation for setup and usage instructions.

### Public Usage

Some packages may be available on pub.dev. Please check individual package documentation for availability and installation details.

---

## Development

### Setup

#### 1. Clone the repository

Using HTTPS:

```bash
git clone https://github.com/Ragibn5/dart-flutter-packages.git
```

Or, using SSH:

```bash
git clone git@github.com:Ragibn5/dart-flutter-packages.git
```

#### 2. Open the repository in your IDE

The packages form one [pub workspace](https://dart.dev/tools/pub/workspaces):
open the repository root, and every package resolves together.

#### 3. Install the pinned Flutter SDK and the dependencies

The root `.fvmrc` pins the one Flutter SDK every package uses. With
[`FVM`](https://fvm.app), from the repository root:

```bash
fvm install
fvm flutter pub get
```

CI reads the same `.fvmrc` and installs that Flutter version directly, so
bumping the pin there updates both.

#### 4. Run a script across the packages

[Melos](https://melos.invertase.dev) runs the workspace's scripts, such as:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run coverage
```

| Script          | What it does                                                                |
|-----------------|-----------------------------------------------------------------------------|
| `analyze`       | Runs `dart analyze` in every package.                                       |
| `test`          | Runs `dart test` or `flutter test` in every package that has a `test` folder. |
| `coverage`      | Checks each package's line coverage (see [Coverage](#coverage)).            |

Melos's own commands work on the workspace too, such as
`fvm dart run melos publish --yes`, which dry-runs publishing every package
whose version isn't on pub.dev yet. Add `--diff=<ref>` to a script to run it
only in the packages changed since `<ref>`, as CI does.

### Coverage

[`tool/coverage.dart`](tool/coverage.dart) checks one package's line
coverage; the `coverage` script runs it in every package, and CI runs it in
the packages a pull request changes.

- Every library in `lib/` counts, including those no test imports.
- The required coverage is 100%, unless the package's `coverage.yaml` sets a
  lower `threshold:`.
- Files matching the `exclude:` patterns are left out: those in the root
  [`coverage.yaml`](coverage.yaml) apply to every package (generated code and
  models), and a package's own `coverage.yaml` adds its own.
- Lines between `// coverage:ignore-start` and `// coverage:ignore-end`, or
  marked `// coverage:ignore-line`, aren't counted.

A package's `coverage.yaml`, for example:

```yaml
threshold: 80
exclude:
  - 'lib/src/configs/*'
```

### Checking everything locally

From the repository root, this analyzes every package and runs its tests
with the coverage check:

```bash
make check
```

It needs [lcov](https://github.com/linux-test-project/lcov), activates the
`coverage` package if it's missing, and uses fvm when it's installed. The
[Makefile](Makefile) lists its other targets.

CI runs the same Melos scripts with `--diff=<ref> --include-dependents`, so
only the packages a pull request changed, and those that depend on them, are
checked.

### Contributing

1. Create a new branch for your changes:
    ```bash
    git checkout -b feature/<package-name>/branch-name
    ```
2. Make your changes within the appropriate package directory
3. Update readme, examples, tests and documentations as needed
4. Create a pull request with a clear description of your changes

## License

Click [here](LICENSE) to see the license.

## Contact

For internal inquiries about these packages, please contact me at ragibn5@gmail.com.