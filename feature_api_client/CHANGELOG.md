# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-11

### Changed

- **Breaking:** built on `dio` directly, in place of `net_client`. A client
  takes a `Dio`, and implements `send`, which sends the request through it,
  in place of `createRequest`.
- **Breaking:** `decodeResponse` takes dio's `Response`, and also gets the
  answers with an error status.
- **Breaking:** `DioExceptionTransformer` replaces
  `NetClientExceptionTransformer`; it's injected through a
  `@visibleForTesting` parameter in place of the `test` constructor.

### Added

- A response `decodeResponse` can't decode is returned as an
  `UnexpectedError`, not thrown.

## [1.0.0] - 2026-08-30

### Added

- Initial release.
