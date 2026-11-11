# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-11

### Changed

- **Breaking:** built on `dio` directly, in place of `net_client`. The
  interceptor is a dio `QueuedInterceptor`, and the collaborators take dio's
  `RequestOptions` and `Response`.
- **Breaking:** `RequestRetrier` only sends the request: the interceptor
  applies the auth data to it first. It has no type parameter.

### Added

- `AuthRecoveryException`, the `error` of the cancelled `DioException` a
  request is rejected with, and its `AuthRecoveryFailure` reason.
- Auth errors are recovered whether they arrive as an error (dio's default for
  a 401) or as a response the `validateStatus` accepts.
- A request is rejected, not left hanging, if a collaborator throws.

## [1.0.0] - 2026-08-30

### Added

- Initial release.
