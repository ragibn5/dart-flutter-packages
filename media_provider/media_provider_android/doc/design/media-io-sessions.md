# Media I/O sessions — design

Status: **Draft, pre-implementation**
Scope: `media_provider_android` (Dart API, method channel, Android implementation)

## 1. Goal

Let the app read and write the bytes of `MediaStore` items through the plugin:

- **Read** — an existing item, sequentially or at arbitrary positions.
- **Create** — a new item in a `MediaStore` collection.
- **Overwrite** — an existing item, in **truncate** or **append** mode.

Requirements:

- Typed, actionable failures. The app knows *why* it can't read or write and what to do about it.
- Writes: nothing becomes visible or changes until the caller explicitly commits.
- Reads: backpressure. A slow consumer never makes the plugin buffer an unbounded amount of data.
- An abandoned session (crash, hot restart, forgotten handle) never corrupts a target and never leaks resources.
- The plugin performs **checks only**. All permission and consent UI is the app's responsibility.

Non-goals:

- Showing permission or consent dialogs.
- Writing metadata columns (they are platform-computed, §7).
- Storage Access Framework (`ACTION_OPEN_DOCUMENT` etc.) URIs. Only `MediaStore` content URIs.
- iOS / other platforms.

## 2. Background

### 2.1 Why sessions and not streams

**Writing.** Flutter platform channels have no Dart → platform stream primitive. Writes go through discrete method
calls tied together by a session id. The Dart side still accepts a `Stream<List<int>>` (`addStream`), consumed in Dart
as sequential, awaited `write` calls — which gives natural backpressure.

**Reading.** Platform → Dart streams *do* exist (`EventChannel`, Pigeon's `@EventChannelApi`), but they are
push-based: the stream handler only learns about `listen` and `cancel`. Pausing the Dart `StreamSubscription` does
not reach the platform, so the platform keeps reading and sending while Dart buffers — unbounded memory for a large
video and a slow consumer. Reads are therefore **pull-based**: Dart asks for the next chunk only when it wants it.
The Dart side still exposes a `Stream<List<int>>` (`openRead`), built on top of the pull loop, so pausing the
subscription really stops reading.

This is the same split `dart:io` uses: `File.openRead()` is a stream implemented by repeated `RandomAccessFile.read`
calls into native code.

### 2.2 Prior art

| Prior art                                          | Shape                                                    | What we take from it                                         |
|----------------------------------------------------|----------------------------------------------------------|--------------------------------------------------------------|
| `MediaStore` pending items (`IS_PENDING`, API 29+) | insert pending → write → publish or delete               | Create mode, invisible until commit                          |
| `PackageInstaller.Session`                         | `createSession` → `openWrite` → `commit()` / `abandon()` | open → write\* → commit \| abort, single-use session         |
| `dart:io` `RandomAccessFile`                       | Dart holds an id, native side holds the handle           | Opaque session id, platform-owned state, positional reads    |
| `dart:io` `File.openRead`                          | Stream built from pulled blocks                          | Read stream with real backpressure, optional `start`/`end`   |
| androidx `ExifInterface.saveAttributes`            | Keep a temp copy, rewrite in place, restore on failure   | Staged overwrite + optional backup                           |
| `MediaScannerConnection.scanFile`                  | Hand a written file to the scanner, get its URI back     | Create / overwrite on API 24–28 (§6.1, §6.4)                 |

## 3. Overview

Two session kinds share one core (registry, ids, timeouts, cleanup, concurrency — §4).

```
READ
open(ReadRequest) ──► ReadSession(id, size) ──► read(length[, position])* ──► close()
       │                                              (empty result = end of data)
       ▼
 typed failure          also closed by: idle timeout, engine detach

WRITE
open(WriteRequest) ──► WriteSession(id) ──► write(bytes)* ──► commit() ──► result (uri)
       │                                          │
       ▼                                          └────────► abort()
 typed failure          also aborted by: idle timeout, engine detach
```

Advisory checks (no side effects): `checkReadAccess(request)`, `checkWriteAccess(request)` — §8.

Conveniences that move no bytes over the channel, for large files:

- `readToFile(request, destinationPath)` — the platform copies the item into an app-owned file.
- `writeFromFile(request, sourcePath)` — the platform copies an app-owned file into a write session and commits it.

And one for small payloads: `readBytes(request, {maxSize})` — opens, reads everything, closes. Fails instead of
reading past `maxSize`, so it can't be used to load a 4 GB video into memory by accident.

## 4. Session core (shared)

### 4.1 Ownership and cleanup

The platform side owns all session state and is responsible for cleanup. The Dart side will leak sessions
(exceptions, forgotten handles, hot restart), so nothing depends on Dart closing them.

- **Registry**: one `SessionRegistry` holding both kinds, `Map<SessionId, Session>`. The id is an opaque UUID generated
  on the platform side.
- **Idle timeout**: every call on a session resets its timer. On expiry a write session is aborted, a read session is
  closed.
- **Engine detach** (`onDetachedFromEngine`, which includes hot restart): every open session is aborted / closed. This
  runs outside the dispatcher's scope, because that scope is cancelled on detach.
- **Dart `Finalizer`**: optional last resort that closes / aborts a garbage-collected open session. Not relied on.
- Write-specific leftovers (staging files, pending rows) — §6.6.

### 4.2 Closed-session behaviour

A session is closed after `close` (read), `commit` or `abort` (write) — successful or not — and after any failure
during `read`, `write` or `commit`. A closed session is removed from the registry.

| Call on a closed session           | Result                                                     |
|------------------------------------|------------------------------------------------------------|
| `read` / `write`                   | `SessionClosed`                                            |
| `close` after `close`              | No-op                                                      |
| `commit` after successful `commit` | No-op, returns the same result (cached on the Dart object) |
| `abort` after `abort`              | No-op                                                      |
| `abort` after `commit`             | No-op (does **not** undo the commit)                       |
| `commit` after `abort`             | `SessionClosed`                                            |

The Dart object tracks its own state and rejects these locally where possible. The platform answers unknown ids with
`session_not_found`, which Dart maps to `SessionClosed`. `close` / `abort` with an unknown id is not an error.

### 4.3 Concurrency

- The dispatcher launches every call concurrently. Each session has its own `Mutex`, so operations on one session run
  strictly in order. Different sessions run in parallel.
- The Dart session also serializes its own calls, so ordering never depends on the platform's mutex alone.
- All I/O runs on `Dispatchers.IO`.

### 4.4 Sessions on the same URI

| Already open on the URI                         | Opening a read session | Opening a write session                         |
|-------------------------------------------------|------------------------|-------------------------------------------------|
| Nothing                                         | ✅                     | ✅                                              |
| Read session(s)                                 | ✅                     | ✅, except `direct` truncate → `TargetBusy`     |
| Write session                                   | ✅ (see below)         | `TargetBusy`                                    |

- Any number of read sessions may be open on one URI.
- At most one write session per URI.
- A `direct` truncate write would destroy content an open read session is reading, so it's rejected. This makes
  read-modify-write on one URI safe within the app: read with a read session, write back with a staged overwrite.
- What a read sees while a write session on the same URI is open: with `staged`, the original until `commit` (and
  partial content during the commit copy itself); with `direct`, partial content.
- These rules only cover sessions inside this plugin. Other apps and other code paths aren't locked out — Android has
  no such locking for `MediaStore` files.

## 5. Reading

### 5.1 Request

| Field             | Type                    | Notes                                                                      |
|-------------------|-------------------------|----------------------------------------------------------------------------|
| `uri`             | `String`                | Content URI of an existing `MediaStore` item                               |
| `requireOriginal` | `bool`, default `false` | Unredacted bytes via `MediaStore.setRequireOriginal` (API 29+). See §5.3   |
| `idleTimeout`     | `Duration`, 60 s        |                                                                            |

### 5.2 Mechanism

```
open    → checks → openFileDescriptor(uri, "r") → reply { sessionId, size }
read    → read(length) from the current position, or pread at `position` if given
          → bytes (empty = end of data); a sequential read advances the position, a positional one doesn't
close   → close descriptor
```

- `size` comes from the descriptor (`statSize`). It's sent as `null` when unknown (`statSize` returns `-1` if the
  descriptor isn't backed by a regular file); callers must handle that.
- Positional reads need a seekable descriptor. If it isn't seekable, a positional read fails with `Unsupported`, and
  sequential reads still work.
- On the Dart side `openRead({start, end, chunkSize})` builds a `Stream<Uint8List>` from sequential reads. It pulls
  only while the subscription is active and not paused; the session is closed on done, error or cancel.

### 5.3 Location redaction

On API 29+, `MediaStore` may redact location metadata (e.g. Exif GPS) from the bytes it returns unless the caller asks
for the original. Per the `setRequireOriginal` reference, asking without `ACCESS_MEDIA_LOCATION` throws
`UnsupportedOperationException` when the URI is used; the plugin maps that to `PermissionDenied(ACCESS_MEDIA_LOCATION)`.

**Hazard:** reading a redacted image and writing it back with an overwrite **permanently drops** its location data.
The overwrite docs must say so, and read-modify-write callers should use `requireOriginal: true`.

## 6. Writing

### 6.1 Create — request and mechanism

| Field          | Type        | Notes                                                                                                         |
|----------------|-------------|---------------------------------------------------------------------------------------------------------------|
| `type`         | `MediaType` | Selects the collection (images, video, audio, downloads, files)                                               |
| `volume`       | volume name | Defaults to the primary external volume                                                                       |
| `displayName`  | `String`    | Required, **with the file extension**. The platform derives `MIME_TYPE` from it (§7)                          |
| `relativePath` | `String?`   | Must be a location the collection allows (e.g. `DCIM/`, `Pictures/` for images). Collection default when null |

There is no `mimeType` field: `MIME_TYPE` is read-only and computed by the platform. The plugin validates that the
extension maps to a MIME type the collection accepts (`invalid_argument` otherwise).

| API   | Mechanism                                                                                                                                                                                                                                                 |
|-------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 29+   | Insert row with `DISPLAY_NAME`, `RELATIVE_PATH`, `IS_PENDING=1` → `write` streams into its descriptor → `commit` closes the descriptor, sets `IS_PENDING=0` → `abort` deletes the row                                                                     |
| 24–28 | No pending items. `write` goes to a staging file → `commit` copies it to its public location (volume + relative path + display name) and hands that path to `MediaScannerConnection.scanFile`, which creates the row and returns its URI → `abort` deletes the staging file |

On 29+ `MediaStore` may rename the item on a name collision. `commit` returns the final URI and display name.

### 6.2 Overwrite — request

| Field             | Type                           | Notes                                                     |
|-------------------|--------------------------------|-----------------------------------------------------------|
| `uri`             | `String`                       | Content URI of an existing `MediaStore` item              |
| `mode`            | `truncate` \| `append`         |                                                           |
| `strategy`        | `staged` (default) \| `direct` | See §6.3, §6.4                                            |
| `backup`          | `bool`, default `false`        | Truncate + staged only                                    |

Both create and overwrite also take `idleTimeout` (default 60 s) and an optional `expectedSize` for an up-front space
check (§8.2).

All write modes share one rule: **the target does not change before `commit`**, except `direct`, which trades that
for speed and storage.

### 6.3 Overwrite, truncate

**Staged (default)**

```
open    → checks, writable probe (open "w", close), empty staging file
write   → append to staging file
commit  → [backup: copy target → backup file]
          open target "wt" → copy staging → target → close
          [on failure + backup: restore target from backup file]
          [API 24–28: rescan (§6.5)]
          delete staging (+ backup)
abort   → delete staging; target untouched
```

**Direct (opt-in)**: `open` opens the target with `"wt"`, `write` goes straight into it. Cheapest, but the target is
truncated as soon as the session opens, and `abort` cannot restore it. Intended for very large files where the extra
copy is too expensive. The caller accepts this explicitly.

Why not "write a new item and swap it in": `MediaStore` has no atomic replace, so a swap is publish + delete — two
steps that change the item's id/URI, reset `DATE_ADDED` and ownership, can collide on name, may need a separate delete
consent, and are still not atomic. A caller that wants a new item uses **Create**.

### 6.4 Overwrite, append

The staging file holds **only the appended bytes**; the original is never copied.

**Staged (default)**

```
open    → checks, writable probe, empty staging file
write   → append to staging file
commit  → open target "rw" → L = size → seek to L → copy staging → target → close
          [on failure: truncate target to L]
          [API 24–28: rescan (§6.5)]
          delete staging
abort   → delete staging; target untouched
```

`L` is read at `commit`, not at `open`, because the target may change while the session is open.

**Direct (opt-in)**: `open` opens the target `"rw"`, records `L`, seeks to `L`. `write` goes straight into the
target. `abort`, idle timeout and engine detach truncate back to `L`. Remaining downsides: the partial tail is visible
to readers while the session is open, and on process death nobody truncates, so the tail stays.

`"rw"` + explicit seek is used instead of `"wa"`: rollback needs a read-write descriptor for truncation anyway, and
the append position stays under our control instead of depending on the provider's handling of `"wa"`.

Appending only makes sense for formats that tolerate it (text, logs, raw streams). Appended bytes on JPEG/MP4 are
generally not part of the media. See open question Q3.

### 6.5 Metadata after a write

The platform computes the metadata columns from the file (§7). What the plugin does after writing:

| API   | After create                                       | After overwrite                                                     |
|-------|----------------------------------------------------|---------------------------------------------------------------------|
| 29+   | Nothing beyond `IS_PENDING=0`                      | Nothing. Whether the columns are refreshed on every API level is Q5 |
| 24–28 | `scanFile` creates the row with metadata (§6.1)    | `scanFile` on the item's `DATA` path to refresh its metadata        |

`MediaWriteResult.bytesWritten` is counted by the plugin, not read from `SIZE`, so the result doesn't depend on when
the platform updates the columns.

### 6.6 Write-specific cleanup

- **Staging files** live in a dedicated cache directory (`cacheDir/media_io_staging/`). On attach, anything left over
  from a previous process is deleted.
- **Pending rows** (create, 29+): per the `DATE_EXPIRES` reference, the expiry is set automatically when `IS_PENDING`
  changes ("typically 7 days"), and expired items are deleted automatically. Active cleanup on attach is Q4.

### 6.7 Summary

| Mode             | Staging holds    | `abort`         | `commit` failure                          | Extra storage                       | Target changes during session |
|------------------|------------------|-----------------|-------------------------------------------|-------------------------------------|-------------------------------|
| Create (29+)     | Pending row      | Delete row      | Delete row                                | none                                | n/a (invisible)               |
| Create (24–28)   | Staging file     | Delete staging  | Delete staging + partial target           | 1× content                          | n/a                           |
| Truncate, staged | Full new content | Delete staging  | Corrupt target, or restored with `backup` | 1× new (+1× original with `backup`) | No                            |
| Truncate, direct | —                | Cannot restore  | Cannot restore                            | none                                | Yes                           |
| Append, staged   | Appended bytes   | Delete staging  | Truncate to `L`                           | 1× appended                         | No                            |
| Append, direct   | —                | Truncate to `L` | Truncate to `L`                           | none                                | Yes                           |

## 7. Metadata columns

Per the `MediaStore.MediaColumns` reference, the plugin never writes these; they are computed by the platform:

| Column                          | Reference says                                                                 |
|---------------------------------|--------------------------------------------------------------------------------|
| `SIZE`                          | "Indexed value of `File.length()` extracted from this media item" — read-only  |
| `DATE_MODIFIED`                 | "Indexed value of `File.lastModified()` extracted…" — read-only                |
| `DATE_ADDED`                    | "The time the media item was first added" — read-only                          |
| `WIDTH`, `HEIGHT`, `DURATION`   | Extracted via `MediaMetadataRetriever` / `ExifInterface` — read-only           |
| `MIME_TYPE`                     | "typically defined based on the file extension… read-only… automatically computed" |
| `OWNER_PACKAGE_NAME`            | read-only; may be `NULL` "if ownership cannot be reliably determined"          |
| `DATE_EXPIRES`                  | "automatically calculated when `IS_PENDING` or `IS_TRASHED` is changed"        |

The plugin writes only: `DISPLAY_NAME`, `RELATIVE_PATH`, `IS_PENDING` (create, API 29+).

The reference does not say *when* extraction happens relative to closing the descriptor or clearing `IS_PENDING`.
That is open question Q5, to be settled on device.

## 8. Access checks

The plugin checks and reports; it never asks. The app obtains permissions and consent itself and retries.

### 8.1 Read

Which permission applies depends on the device API level **and** the app's `targetSdkVersion` (read from
`applicationInfo`), per the `Manifest.permission` reference:

| Device API | App target SDK | Own items                 | Other apps' items                                                                                   |
|------------|----------------|---------------------------|-----------------------------------------------------------------------------------------------------|
| 24–28      | any            | `READ_EXTERNAL_STORAGE`   | `READ_EXTERNAL_STORAGE`                                                                             |
| 29–32      | any            | none                      | `READ_EXTERNAL_STORAGE`                                                                             |
| 33+        | ≤ 32           | none                      | `READ_EXTERNAL_STORAGE`                                                                             |
| 33+        | ≥ 33           | none                      | `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` / `READ_MEDIA_AUDIO`, by the item's media type             |
| 34+        | ≥ 33           | none                      | With only `READ_MEDIA_VISUAL_USER_SELECTED`: only the images/videos the user selected               |

Plus `ACCESS_MEDIA_LOCATION` when `requireOriginal` is set (API 29+).

Failures:

- Missing permission → `PermissionDenied(permissions)` listing what would satisfy the request (e.g.
  `[READ_MEDIA_IMAGES]`, or `[READ_MEDIA_IMAGES, READ_MEDIA_VISUAL_USER_SELECTED]` on 34+).
- Item not visible to the app → `NotFound(uri, partialAccess)`. `partialAccess: true` when the app holds only
  `READ_MEDIA_VISUAL_USER_SELECTED`, which hints that the item may simply not be in the user's selection.
- Other apps' non-media files (downloads, documents) aren't readable through `MediaStore` under scoped storage; they
  surface as `NotFound`. Reaching them needs SAF, which is out of scope.

Note: the plugin manifest currently declares `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` but not `READ_MEDIA_AUDIO`.
Reading other apps' audio on 33+ needs it added (Q8).

### 8.2 Write

**Create**

| API   | Check                                                                                       | Failure                                    |
|-------|---------------------------------------------------------------------------------------------|--------------------------------------------|
| 24–28 | `WRITE_EXTERNAL_STORAGE` granted                                                            | `PermissionDenied([WRITE_EXTERNAL_STORAGE])` |
| 29+   | None. Validate request: extension maps to a MIME type the collection accepts, path allowed | `InvalidRequest(reason)`                   |

**Overwrite**

| API                                                          | Check                                                 | Failure                                            |
|--------------------------------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| 24–28                                                        | `WRITE_EXTERNAL_STORAGE` granted                      | `PermissionDenied([WRITE_EXTERNAL_STORAGE])`       |
| 29, legacy storage (`Environment.isExternalStorageLegacy()`) | `WRITE_EXTERNAL_STORAGE` granted                      | `PermissionDenied([WRITE_EXTERNAL_STORAGE])`       |
| 29+                                                          | Item exists                                           | `NotFound(uri)`                                    |
| 29, scoped                                                   | Writable (owned)                                      | `WriteAccessRequired(uri, remedyAvailable: false)` |
| 30+                                                          | Writable (owned, or granted via `createWriteRequest`) | `WriteAccessRequired(uri, remedyAvailable: true)`  |

Plus, for every write mode: free space for the staging file (and backup), via `StorageManager.getAllocatableBytes`
(API 26+) or `StatFs` below that → `InsufficientStorage`. Only checkable when the size is known up front
(`writeFromFile`, or `expectedSize`); otherwise `ENOSPC` during `write` maps to the same failure. `readToFile` checks
the destination the same way using the item's size.

### 8.3 The API 29 write gap

On API 29 there is no up-front consent API for writing. Consent for another app's item only arrives as an
`IntentSender` inside the `RecoverableSecurityException` thrown by a failed write, and it can't cross the channel. So
the app cannot obtain it on its own. Supported paths:

1. **Legacy storage** (recommended): the app sets `requestLegacyExternalStorage="true"` and requests
   `WRITE_EXTERNAL_STORAGE`. API 29 then behaves like 24–28.
2. Otherwise the plugin reports `WriteAccessRequired(remedyAvailable: false)`, and the app treats it as unsupported on
   that device.

### 8.4 Pre-checks are hints; `open` is authoritative

A check and the operation that follows it can disagree (grant revoked, item deleted, ownership changed), and the
official docs don't promise that ownership or `checkUriPermission` predict whether `openFileDescriptor` will succeed.
Therefore:

- `open` runs the cheap checks first (permissions, request validation), then **performs the real operation**
  (`openFileDescriptor` for reads, pending insert or a writable probe for writes) and maps the exception:

  | Exception                                                       | Failure                                                         |
  |-----------------------------------------------------------------|-----------------------------------------------------------------|
  | `SecurityException`, `RecoverableSecurityException`             | `PermissionDenied` or `WriteAccessRequired`, per §8.1 / §8.2    |
  | `UnsupportedOperationException` with `requireOriginal`          | `PermissionDenied([ACCESS_MEDIA_LOCATION])`                     |
  | `FileNotFoundException`                                         | `NotFound`                                                      |
  | `IllegalArgumentException` from `insert`                        | `InvalidRequest`                                                |
  | `IOException` with `ENOSPC`                                     | `InsufficientStorage`                                           |
  | other `IOException`                                             | `IOError`                                                       |

- `checkReadAccess` / `checkWriteAccess` run the same checks without opening anything and return the same reasons, so
  the app can decide up front whether to run its permission / consent flow (and batch several URIs into one
  `createWriteRequest`). They are advisory: `open` can still fail.

Both are backed by the same checker classes as `open`, so the reason codes always match.

## 9. Failures

| Dart exception                 | Channel code            | Payload                     | Raised by                         |
|--------------------------------|-------------------------|-----------------------------|-----------------------------------|
| `PermissionDeniedException`    | `permission_denied`     | `permissions`               | check, open                       |
| `WriteAccessRequiredException` | `write_access_required` | `uri`, `remedyAvailable`    | checkWrite, openWrite             |
| `MediaNotFoundException`       | `not_found`             | `uri`, `partialAccess`      | check, open, read, commit         |
| `InvalidMediaRequestException` | `invalid_argument`      | `message`                   | check, open, read                 |
| `TargetBusyException`          | `target_busy`           | `uri`                       | openWrite                         |
| `InsufficientStorageException` | `insufficient_storage`  | —                           | openWrite, write, commit, readToFile |
| `MediaUnsupportedException`    | `unsupported`           | `message`                   | read (positional, non-seekable)   |
| `MediaTooLargeException`       | `too_large`             | `size`, `maxSize`           | readBytes                         |
| `SessionClosedException`       | `session_not_found`     | `sessionId`                 | read, write, commit               |
| `MediaIOException`             | `io_error`              | `message`                   | any I/O                           |
| (existing)                     | `unexpected_error`      | `message`                   | any                               |

On the Dart side these form a `sealed class MediaAccessException implements Exception` (name TBD), so callers can
`switch` exhaustively. On Kotlin they are thrown as the existing `MethodCallException(code, message, details)`.

A failure during `read`, `write` or `commit` **closes the session** after cleaning up per §6 (staging deleted, append
truncated, backup restored). The session is not retryable.

## 10. Dart API (sketch)

```dart
// ---- Read ----

final class MediaReadRequest {
  final String uri;
  final bool requireOriginal; // default: false
}

abstract interface class MediaReadSession {
  String get id;
  bool get isClosed;

  /// Size in bytes, or null if unknown.
  int? get size;

  /// Reads up to [length] bytes. Empty result means end of data.
  /// With [position], reads from there without moving the sequential position.
  Future<Uint8List> read(int length, {int? position});

  /// Streams the bytes in [start, end). Pulls only while listened to and not paused.
  /// Closes the session on done, error or cancel.
  Stream<Uint8List> openRead({int start = 0, int? end, int chunkSize});

  Future<void> close();
}

// ---- Write ----

sealed class MediaWriteRequest {}

final class CreateMediaRequest extends MediaWriteRequest {
  final MediaType type;
  final String? volume;
  final String displayName; // with extension; determines MIME type
  final String? relativePath;
  final int? expectedSize;
}

enum OverwriteMode { truncate, append }

enum OverwriteStrategy { staged, direct }

final class OverwriteMediaRequest extends MediaWriteRequest {
  final String uri;
  final OverwriteMode mode;
  final OverwriteStrategy strategy; // default: staged
  final bool backup; // default: false; truncate + staged only
  final int? expectedSize;
}

final class MediaWriteResult {
  final String uri;
  final String displayName;
  final int bytesWritten;
}

abstract interface class MediaWriteSession {
  String get id;
  bool get isClosed;

  /// Appends [bytes]. Calls are serialized.
  Future<void> write(Uint8List bytes);

  /// Writes every chunk of [stream], re-chunked to at most [chunkSize] bytes.
  Future<void> addStream(Stream<List<int>> stream, {int chunkSize});

  /// Applies the write and closes the session.
  Future<MediaWriteResult> commit();

  /// Discards the write and closes the session. Never throws.
  Future<void> abort();
}

// ---- Platform interface additions ----

Future<void> checkReadAccess(MediaReadRequest request);
Future<MediaReadSession> openReadSession(MediaReadRequest request, {Duration idleTimeout});
Future<Uint8List> readBytes(MediaReadRequest request, {required int maxSize});
Future<void> readToFile(MediaReadRequest request, String destinationPath);

Future<void> checkWriteAccess(MediaWriteRequest request);
Future<MediaWriteSession> openWriteSession(MediaWriteRequest request, {Duration idleTimeout});
Future<MediaWriteResult> writeFromFile(MediaWriteRequest request, String sourcePath);
```

The write session deliberately does **not** implement `StreamSink`/`StreamConsumer`: their `close()` can't say
whether it means commit or abort. `addStream` covers the stream use case without that ambiguity.

Typical use:

```dart
// Copy one item into a new one.
final reader = await platform.openReadSession(MediaReadRequest(uri: sourceUri));
final writer = await platform.openWriteSession(createRequest);
try {
  await writer.addStream(reader.openRead()); // reader closes itself when done
  return await writer.commit();
} catch (_) {
  await writer.abort(); // no-op if already closed
  await reader.close(); // no-op if already closed
  rethrow;
}
```

## 11. Channel protocol

Follows the existing conventions: requests are JSON strings decoded with kotlinx.serialization; one handler per method.
Bytes are the exception: they travel as raw `Uint8List` (`byte[]` on Kotlin), never JSON-encoded.

| Method               | Arguments                                                   | Reply                         |
|----------------------|-------------------------------------------------------------|-------------------------------|
| `checkReadAccess`    | `request`: JSON                                             | `null` or error               |
| `openReadSession`    | `request`: JSON, `idleTimeoutMillis`: int                   | JSON `{ sessionId, size? }`   |
| `readFromSession`    | `sessionId`: String, `length`: int, `position`: int?        | `Uint8List` (empty = end)     |
| `closeReadSession`   | `sessionId`: String                                         | `null`                        |
| `readBytes`          | `request`: JSON, `maxSize`: int                             | `Uint8List`                   |
| `readToFile`         | `request`: JSON, `destinationPath`: String                  | `null`                        |
| `checkWriteAccess`   | `request`: JSON                                             | `null` or error               |
| `openWriteSession`   | `request`: JSON, `idleTimeoutMillis`: int                   | JSON `{ sessionId }`          |
| `writeToSession`     | `sessionId`: String, `bytes`: Uint8List                     | `null`                        |
| `commitWriteSession` | `sessionId`: String                                         | JSON `MediaWriteResult`       |
| `abortWriteSession`  | `sessionId`: String                                         | `null`                        |
| `writeFromFile`      | `request`: JSON, `sourcePath`: String                       | JSON `MediaWriteResult`       |

Chunk size: 512 KiB default for both `addStream` and `openRead`. Large enough to keep per-call overhead low, small
enough to keep memory and main-thread message handling bounded. To be tuned with measurements (Q7). `openRead` may
keep one read in flight ahead of the consumer to hide channel latency (Q9).

## 12. Android components

A new `features/io` package, matching the existing feature layout.

```
features/io/
  session/
    Session.kt                 interface: id, uri, close/abort for cleanup
    SessionRegistry.kt         id → session, per-session Mutex, idle timers, closeAll(), §4.4 URI rules
  access/
    PermissionState.kt         device API, target SDK, granted permissions, legacy storage
    ReadAccessChecker.kt       §8.1
    WriteAccessChecker.kt      §8.2
    StorageSpaceChecker.kt
    IoFailure.kt               sealed; exception mapping (§8.4) → MethodCallException codes
  read/
    models/ReadRequest.kt
    ReadSession.kt             descriptor, sequential + positional reads
    MediaReader.kt             open, readBytes, readToFile
  write/
    models/                    WriteRequest (sealed: Create / Overwrite), OverwriteMode, OverwriteStrategy, WriteResult
    StagingFileStore.kt        cacheDir/media_io_staging/, create/delete, orphan sweep on attach
    MediaScanner.kt            suspend wrapper over MediaScannerConnection.scanFile (API 24–28)
    sessions/
      WriteSession.kt          write(bytes), commit(): WriteResult, abort()
      PendingCreateSession.kt         API 29+
      ScannedCreateSession.kt         API 24–28
      StagedTruncateSession.kt        optional backup
      StagedAppendSession.kt
      DirectTruncateSession.kt
      DirectAppendSession.kt
    WriteSessionFactory.kt     request + API level → WriteSession
  di/
    MediaIoServiceFactory.kt
handlers/
  CheckReadAccessHandler.kt, OpenReadSessionHandler.kt, ReadFromSessionHandler.kt,
  CloseReadSessionHandler.kt, ReadBytesHandler.kt, ReadToFileHandler.kt,
  CheckWriteAccessHandler.kt, OpenWriteSessionHandler.kt, WriteToSessionHandler.kt,
  CommitWriteSessionHandler.kt, AbortWriteSessionHandler.kt, WriteFromFileHandler.kt
```

Plugin wiring: `attach` creates the registry and runs the staging sweep; `onDetachedFromEngine` calls
`registry.closeAll()` (aborting write sessions) before disposing the dispatcher.

## 13. Testing

- **Unit (JVM)**: access-checker matrices per API level and target SDK; registry lifecycle (timeouts, §4.4 URI rules,
  closed-session behaviour); each session type's success/abort/failure paths against a fake resolver; exception →
  code mapping.
- **Dart**: request/result serialization, error mapping to the sealed hierarchy, session state tracking, `addStream`
  chunking, `openRead` pause/cancel behaviour (no reads while paused, close on cancel).
- **Device (example app / integration test)**: real `MediaStore` on API 28, 29 (legacy and scoped), 30, 33, 34+ with
  full and partial media access; owned vs foreign items; redacted vs original reads; crash/hot restart mid-session
  leaves targets intact; metadata after create and overwrite (Q5).

## 14. Open questions

| #  | Question                                                                                                                    | Leaning                              |
|----|-----------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| Q1 | Default `idleTimeout`, and whether it's per request or global                                                               | 60 s, per request                    |
| Q2 | Name collision on create, API 24–28 (no auto-rename): fail with an `already_exists` code, or auto-rename like 29+?          | Auto-rename, so both behave the same |
| Q3 | Should `open` reject append on formats where it's meaningless (image/video MIME types)?                                     | Allow, document it                   |
| Q4 | Actively delete our own leftover pending rows on attach, or rely on `DATE_EXPIRES`?                                         | Rely on the system first; revisit    |
| Q5 | Are `SIZE` / `DATE_MODIFIED` (and extracted columns) refreshed after an in-place write on API 29+, or must we trigger it?   | Verify on device before deciding     |
| Q6 | Expose `expectedSize` on write requests for up-front space checks?                                                          | Yes, optional                        |
| Q7 | Chunk size default                                                                                                          | 512 KiB, tune after measuring        |
| Q8 | Add `READ_MEDIA_AUDIO` to the plugin manifest, or leave manifest permissions to the app?                                    | Add it, alongside images/video       |
| Q9 | Read-ahead of one chunk in `openRead`?                                                                                      | Yes, if measurements show a gain     |

## 15. References

- `MediaStore.MediaColumns` — `SIZE`, `DATE_MODIFIED`, `DATE_ADDED`, `MIME_TYPE`, `IS_PENDING`, `DATE_EXPIRES`,
  `OWNER_PACKAGE_NAME` (read-only / computed column docs)
- `MediaStore.setRequireOriginal`, `MediaStore.createWriteRequest`
- `ContentResolver.openFileDescriptor` (modes `r`, `w`, `wt`, `wa`, `rw`, `rwt`)
- `Manifest.permission` — `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES` / `VIDEO` / `AUDIO`,
  `READ_MEDIA_VISUAL_USER_SELECTED`, `ACCESS_MEDIA_LOCATION`, `WRITE_EXTERNAL_STORAGE`
- `RecoverableSecurityException`, `Environment.isExternalStorageLegacy`, `requestLegacyExternalStorage`
- `MediaScannerConnection.scanFile`
- `StorageManager.getAllocatableBytes`
- Guide: "Access media files from shared storage" (developer.android.com/training/data-storage/shared/media)
- `PackageInstaller.Session`; `dart:io` `RandomAccessFile`, `File.openRead`; androidx `ExifInterface.saveAttributes`
