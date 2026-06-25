# Conventions

## Architecture

This project follows clean architecture. Conventions for architectural consistency are described
in the following sections, grouped by layer. Refer to the official [clean architecture][clean-arch]
documentation for more details, or see existing features for a deeper understanding.

Overall structure of the project:

```
lib/
├── di/
│   ├── config/
│   ├── modules/
│   └── provider/
├── features/
│   ├── <auth>/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   ├── <home>/
│   │   └── ...
│   ├── <other-features>/
│   │   └── ...
│   ...
├── generated/
└── l10n/
```

## Features

### Feature layers

| Layer            | Purpose                                                                |
|------------------|------------------------------------------------------------------------|
| `data`           | Repository implementations, DTOs (models), data sources, mappers, etc. |
| `domain`         | Pure Dart — entities, repository contracts, etc.                       |
| `application`    | Use cases, application layer DTOs, etc.                                |
| `infrastructure` | Database, api clients, interceptors, platform components, etc.         |
| `presentation`   | State management, widgets, etc.                                        |

Note: The `Purpose` column is not a complete list of components. You may have more or fewer
types according to your needs.

Conventions for specific layers:

- [Application layer](#application-layer)
- [Presentation layer](#presentation-layer)

Unlisted layers follow clean architecture standards — refer to existing features for guidance.

### Application layer

**Use cases**

Use cases live in `application/use_cases/` and orchestrate a single business operation.

Keep in mind the following while designing use cases:

- One class per use case, named after the operation (e.g., `RefreshAuthData`, `SubmitOrder`).
- Has exactly one public method (typically `call`, or `execute`, or anything that suits).
- Return type matches the repository pattern (`Future<Either<ApiError, Either<AppErr, AppDTO>>>`).
- Keeps orchestration logic (validation, precondition checks, fallback) — not business rules
  (those belong in domain entities).

A use case may receive its dependencies from two places:

1. From within same feature: Repositories, application services, or use cases from same feature.
2. From within other feature: Define an abstraction in `application/ports` and inject that in the
   use case. The implementation using the external use cases should live in `infrastructure/ports`.

Note: Use cases should be the only component that can cross features, i.e. other features can use
them.

**Application services**

If a feature has complex application logic shared across multiple feature-private use cases,
extract it into application services (`application/services/`). These should not cross features.

### Presentation layer

**BLoC files** follow this convention under `presentation/bloc/`:

```
bloc/
├── <feature>_bloc.dart
├── <feature>_event.dart
└── <feature>_state.dart
```

**Widgets** live under `presentation/widgets/`. Place each top-level widget (usually a page)
in its own folder with its component sub-widgets:

```
widgets/
├── profile_page
│   └── profile_page.dart
│   └── bio_fragment.dart
│   └── info_fragment.dart
│   └── profile_photo.dart
```

**BLoC pattern**

Each BLoC receives events, calls a use case, and creates sealed state classes. For remote
network calls, the flow is:

```
Event ──> BLoC ──> Use Case ──> Either<ApiError, Either<DomainErr, DomainEntity>>
                    │
                    ▼
              BLoC folds result:
                Left(ApiError)         → TransportError state + addError()
                Right(Left(DomainErr)) → DomainError state
                Right(Right(Entity))   → Success state
```

Where the sealed state is defined as:

```
sealed class MyState {}
class Initial extends MyState {}
class Loading extends MyState {}
class Success extends MyState { final DomainEntity data; ... }
class DomainError extends MyState { final DomainErr error; ... }
class TransportError extends MyState { final ApiError error; ... }
```

### Data flow between layers

Each layer uses a consistent return type pattern when communicating with the next. Data flows
from outer layers (API, infrastructure) inward toward the domain, with types transformed at
each boundary.

#### Data flow diagram

```
Per-Endpoint API Client
  │
  │  Future<Either<ApiError, ApiResponse<DataErr, DataDTO>>>
  ▼
Data Source
  │
  │  Future<Either<ApiError, Either<DataErr, DataDTO>>>
  ▼
Repository
  │  ── map DataErr → DomainErr
  │  ── map DataDTO → DomainEntity
  │
  │  Future<Either<ApiError, Either<DomainErr, DomainEntity>>>
  ▼
Use Case (application layer)
  │  ── adds validation & domain logic
  │  ── orchestrates one business operation
  │  ── may call multiple repositories (own feature) / services (cross-feature)
  │
  │  ── map DomainErr → AppErr      (Optional, transform if DomainErr is a mutable type,
  │                                  or contains behaviour, otherwise return DomainErr directly)
  │  ── map DomainEntity → AppDTO   (Optional, transform if DomainEntity is a mutable type,
  │                                  or contains behaviour, otherwise return DomainEntity directly)
  │
  │  Future<Either<ApiError, Either<AppErr, AppDTO>>>
  ▼
BLoC
  │  ── folds Either into sealed states
  │  ── routes errors via addError()
  │
  │  sealed class MyState { ... }
```

### Adding a new feature

Create `lib/features/<feature>/` with the layers in the following order:

1. **Domain layer**
    - Feature entities in `domain/entities/`.
    - Repository contracts in `domain/repositories/`.

2. **Application layer**
    - DTOs in `application/dto/`.
    - Use cases in `application/use_cases/`.

3. **Data layer**
    - Data models in `data/models/`.
    - Data sources in `data/sources/`.
    - Data mappers in `data/mappers/`.
    - Repository implementations in `data/repositories/`.

4. **Infrastructure layer**
    - Database component definitions in `infrastructure/database/`.
    - Per-endpoint client abstractions & implementations in `infrastructure/clients/`.
    - Interceptors in `infrastructure/interceptors/`.
    - Platform components in `infrastructure/platform/`.

5. **Presentation layer**
    - Widgets in `presentation/widgets/`.
    - BLoC classes (with events and states) in `presentation/bloc/`.

   See [Presentation layer](#presentation-layer) below for more details.

6. Wire new routes in `lib/features/app/infrastructure/config/router/routes.dart`.

7. Register dependencies in the [feature module](#dependency-injection).

8. Add corresponding tests in `test/features/<feature>/`.

See the [Return types in layers](#data-flow-between-layers) for information on data flow between
these layers.

## Dependency injection

The DI layer is structured as follows:

```
lib/di/
├── config/
│   ├── dependencies.dart                # Injectable config (register factories/params)
│   └── dependencies.config.dart         # Generated wiring (do not edit manually)
├── modules/
│   └── <feature>_module.dart            # One module per feature
└── provider/
    ├── dependency_provider.dart         # Abstract DI provider contract
    └── dependency_provider_impl.dart    # Concrete implementation wrapping GetIt
```

### Adding a dependency

- **Existing feature** — open the feature's DI module in `lib/di/modules/` and add the registration.
- **New feature** — create a module at `lib/di/modules/<feature>_module.dart`. Refer to existing
  modules for guidance. Simply creating the module is enough — the DI framework generates wiring
  when `build_runner` runs. See [Code generation](#code-generation).

### Reading a dependency

Retrieve dependencies via [`di`](lib/di/di.dart):

- `di.get<MyType>()` — returns the dependency. Throws if not registered.
- `di.getOrNull<MyType>()` — returns the dependency or `null` if not registered.

Do not use `di`'s registration methods directly — define dependencies through modules for
architectural consistency.

## Flavors

Four build flavors are supported:

- `dev`: For you, the developer, to do daily development work.
- `exp`: For testers or QA people.
- `stage`: For testing release candidates in production mirrors.
- `prod`: For end users - final destination.

Each flavor has its own Firebase project, launcher icon, splash screen, and app name.
Entry points are defined in `lib/main_<flavor>.dart`, with corresponding run configurations
in [`.run/`](.run) (IDEA).

## Code generation

Run the following to regenerate all generated code (JSON serializers `*.g.dart`,
typesafe assets under [`lib/generated/`](lib/generated), DI wiring, etc.):

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

These files should not be edited manually.

## Localization

ARB files live in [`lib/l10n/`](lib/l10n). Add, edit, or remove locale files there, then run
the following command to regenerate the localization components. Alternatively, use IDE features —
for example, in Android Studio under `Tools > Flutter Intl`.

```
fvm dart run intl_utils:generate
```

## Testing & coverage

- Tests use `mocktail` for mocking and `bloc_test` for BLoC unit tests.
- Coverage is collected via `flutter test --coverage` and processed with `lcov`.
- Certain directories and patterns are excluded from coverage — see
  [`scripts/coverage/exclusions.sh`](scripts/coverage/exclusions.sh) for the full list.
- The [`Makefile`](Makefile) provides targets for running tests with coverage:
    - `make run-tests-with-coverage`
    - `make process-coverage-data`
    - `make view-coverage`

## Code style

Analyzer configuration is based on `very_good_analysis` and `bloc_lint`.
See [`analysis_options.yaml`](analysis_options.yaml) for more details.

[clean-arch]: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
