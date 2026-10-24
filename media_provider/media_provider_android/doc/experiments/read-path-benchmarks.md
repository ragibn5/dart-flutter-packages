# Read path benchmarks (DFP-65)

Experiments on how fast a `MediaStore` item can be streamed to Dart through a
`MediaReadSession`. All runs read the same 204,488-byte JPEG on the same
device, in a debug build.

Reading the whole file natively with `FileInputStream`, in one go, takes
0–1 ms: everything above that is overhead of getting the bytes to Dart.

## Phases

Reading one file has three phases, and each number below says which it covers:

| Phase | What happens | Logged as |
|---|---|---|
| **Open** | `openMediaReadSession`: `MediaStore` query, open the file | `[openMediaReadSession] native handle` |
| **Read** | Channel: the `readFromSession` calls. Direct: Dart opens `/proc/self/fd/<n>` and reads. FFI: Dart calls `pread64` on the descriptor | Dart `sent` → last `reply received`; `[openReadDirect] dart total`; `[openReadFfi] dart total` |
| **Close** | `closeReadSession`: release the descriptor | `[closeReadSession] native handle` |

The `MediaStore` query is part of **Open**, so no **Read** number includes it.

## Methods

| Method | Opens the file | Reads with | Data travels | Runs on |
|---|---|---|---|---|
| V1 | every call, `openInputStream` | `BufferedInputStream.skip` (return value ignored: bug) + 8 KB copy loop into `ByteArrayOutputStream` | channel reply | main → IO |
| V2 | every call, `openFileDescriptor` | `FileChannel.position` + `FileChannel.read` into the result array | channel reply | main → IO |
| V3 | every call, `openFileDescriptor` | `FileChannel.position` + `BufferedInputStream` (bypassed for large reads, so same as V2) | channel reply | main → IO |
| V4 | once per session, cached `FileChannel` | positional `FileChannel.read(buf, pos)` | channel reply | main → IO |
| V5 | once per session, cached `FileChannel` | positional `FileChannel.read`, on the calling thread | channel reply | background task queue channel `media_provider_android/read` |
| D1 | once per session (twice: cached stream + descriptor), on main | Dart reopens `/proc/self/fd/<n>`, `RandomAccessFile.read` | `dart:io`, no channel | Dart IO threads |
| D2 | once per session, one descriptor, on IO | as D1, no seek at 0, no final empty read | `dart:io`, no channel | Dart IO threads |
| F1 | once per session, one descriptor, on IO (as D2) | `pread64` over FFI on the session's descriptor, into `malloc`'d memory viewed as a `Uint8List` (no reopen, no copy) | FFI, no channel | the listening isolate (blocking) |

All of V1–V5 live in `MediaStoreService.kt` (`readFromSession` picks V4,
`readFromSessionBlocking` runs V5). D1/D2 are `MediaReadSession.openReadDirect`.
F1 is `MediaReadSession.openReadFfi`, with the binding in
`lib/src/io/native_pread.dart`.

## All results

Same 204,488-byte file throughout. Runs that overlapped the app's own
`queryMedia` are noted, as it slows reads down (see findings).

| Method | Chunk | Calls per file | Read phase | Open phase | Close phase |
|---|---|---|---|---|---|
| V1 | 8 KB | 26 | ~600 ms | not measured | not handled |
| V2 | 8 KB | 26 | ~581 ms | not measured | not handled |
| V3 | 8 KB | 26 | ~579 ms | not measured | not handled |
| V4 | 8 KB | 26 | ~350 ms (346 ms); 488 ms in a run with one 289 ms stall | not measured | not handled |
| V5 | 8 KB | 26 | ~73 ms for 24 calls (~3 ms each, 1.1–1.6 ms steady); 349 ms with the 2 calls that overlapped `queryMedia` | not measured | not handled |
| V4 | 512 KB | 2 | 32 ms | 35 ms (1 run) | not handled |
| V5 | 512 KB | 2 | 30 ms (native read 9.2 ms, just after a 673 ms `queryMedia`), 13 ms (native read 0.48 ms), 26 ms (native read 10.4 ms, overlapping `queryMedia`) | 35–52 ms | not handled |
| V5 | 512 KB, 5 runs back to back | 2 | **8–15 ms** (15, 8, 13, 11, 12) | 19–51 ms | not handled |
| D1 | 512 KB, 5 runs back to back | 0 | **12–19 ms** (29, 12, 18, 19, 12) | 37–89 ms | 1–3 ms |
| D2 | 512 KB, 5 runs back to back | 0 | **12–23 ms** (41, 13, 16, 23, 12) | **21–56 ms** (56, 37, 38, 44, 21) | 1.5–2.5 ms |
| F1 | 512 KB, 5 runs back to back | 0 | **0.65–1.1 ms** (17.4, 0.91, 0.88, 1.12, 0.65) | **11.9–14.6 ms** (42.5, 14.5, 14.6, 14.5, 11.9) | ~1 ms (handle), ~2 ms round trip |

The first run of each back-to-back series is the slowest, likely first-use
warm-up; the ranges in bold leave it out where noted in the per-run tables.

## Ranking: fastest to slowest

By the **read phase** for the 204,488-byte file, the only phase measured for
every method. For back-to-back series, the median is over runs 2–5 (run 1 is
warm-up).

| Rank | Method | Chunk | Read phase (median) | Range | vs. slowest |
|---|---|---|---|---|---|
| 1 | **F1: FFI `pread64` on the session's descriptor** | 512 KB | **~0.9 ms** | 0.65–1.1 ms | **~670× faster** |
| 2 | V5: cached channel, background queue | 512 KB | ~11.5 ms | 8–13 ms | ~52× |
| 3 | D2: direct read, one descriptor, opened on IO | 512 KB | ~14.6 ms | 12–23 ms | ~41× |
| 4 | D1: direct read, first version | 512 KB | ~15.1 ms | 12–19 ms | ~40× |
| 5 | V4: cached channel, main channel | 512 KB | 32 ms | 1 run | ~19× |
| 6 | V5: cached channel, background queue | 8 KB | ~80 ms (estimated for 26 calls: 73 ms for 24) | 1.1–1.6 ms per call | ~7.5× |
| 7 | V4: cached channel, main channel | 8 KB | ~350 ms | 346–488 ms | ~1.7× |
| 8 | V3: reopen per call, `BufferedInputStream` | 8 KB | ~579 ms | — | ~1.04× |
| 9 | V2: reopen per call, `FileChannel` | 8 KB | ~581 ms | — | ~1.03× |
| 10 | V1: reopen per call, `skip` + copy loop | 8 KB | ~600 ms | — | 1× |

- **F1 is the fastest by an order of magnitude**: ~13× faster than V5, with
  no reopen, no channel and no copy. Its read phase is about what a native
  read of the file costs.
- Among the rest, V5 at 512 KB beats D1/D2 at this size: they move the bytes
  faster (1–3 ms) but pay Dart's reopen of `/proc/self/fd/<n>` (9.5–17 ms),
  which V5 doesn't need.
- D1 and D2 are level within noise: D2's improvements are in the open phase
  (21–44 ms against 37–55 ms), which this ranking doesn't include.
- The open phase (21–56 ms) isn't ranked: it was only measured for some
  methods, and it is the same work whichever read path follows it.
- Only one file size (200 KB) has been measured. On large files the
  projected order is F1, then D2/D1 (fixed reopen, low cost per byte), then
  V5 (a channel round trip per chunk); not yet measured. F1's reads block
  the isolate, so large files need it on a background isolate.

### Where the time goes, per call or per file

Channel, per call (8 KB, steady state):

| Step | V4 (main channel) | V5 (background queue) |
|---|---|---|
| Round trip | 4–6 ms | 1.1–1.6 ms |
| Coroutine dispatch + main ↔ IO hops | ~1.5–2.5 ms | none |
| Native read of 8 KB | 0.05–0.4 ms | 0.05–0.4 ms |
| JSON request encode + decode | ~0.2–0.5 ms | same |
| Delivery, each way | ~1 ms | ≤1 ms |

Direct read D2, per file (runs 2–5):

| Step | Time |
|---|---|
| `MediaStore` query (open phase) | 7.5–21.5 ms |
| Native `openFileDescriptor` (open phase) | 5.6–12.9 ms |
| Rest of the open phase: hops, `fileLocationResolver.resolve`, `File.canRead()` | ~7–10 ms |
| Dart reopens `/proc/self/fd/<n>` | 9.5–17.2 ms |
| Dart reads 200 KB | 1.1–3.0 ms |
| Close | 1.5–2.5 ms |

### Per run: D1 (first version)

| Run | Open phase | open + seek | read 200 KB | final empty read | Read phase | Read + close (app stopwatch) |
|---|---|---|---|---|---|---|
| 1 | 88.8 ms | 11.1 ms | 12.1 ms | 0.6 ms | 29.4 ms | 50 ms |
| 2 | 54.9 ms | 10.6 ms | 0.39 ms | 0.3 ms | 12.5 ms | 14 ms |
| 3 | 49.3 ms | 12.3 ms | 2.0 ms | 1.0 ms | 17.6 ms | 23 ms |
| 4 | 44.7 ms | 14.3 ms | 1.0 ms | 0.5 ms | 18.6 ms | 22 ms |
| 5 | 37.1 ms | 7.0 ms | 1.9 ms | 0.6 ms | 12.1 ms | 17 ms |

`closeReadSession` released the descriptor: the next session got the same fd
number back (249 in runs 1–4, 247 in run 5).

### Per run: D2 (one descriptor, opened on IO)

| Run | query | open descriptor | Open phase | Dart reopen | read 200 KB | Read phase | Read + close (app stopwatch) |
|---|---|---|---|---|---|---|---|
| 1 | 15.6 ms | 18.1 ms | 56.2 ms | 21.0 ms | 14.1 ms | 40.6 ms | 59 ms |
| 2 | 15.1 ms | 12.6 ms | 36.6 ms | 9.5 ms | 1.1 ms | 12.9 ms | 17 ms |
| 3 | 15.3 ms | 12.9 ms | 37.8 ms | 12.3 ms | 1.6 ms | 16.3 ms | 22 ms |
| 4 | 21.5 ms | 12.4 ms | 44.0 ms | 17.2 ms | 3.0 ms | 22.9 ms | 27 ms |
| 5 | 7.5 ms | 5.6 ms | 20.5 ms | 9.9 ms | 1.3 ms | 12.2 ms | 16 ms |

### Per run: F1 (FFI `pread64`)

| Run | query | open descriptor | Open phase | `pread` 200 KB | final empty `pread` | Read phase |
|---|---|---|---|---|---|---|
| 1 | 7.6 ms | 13.6 ms | 42.5 ms | 14.8 ms | 0.13 ms | 17.4 ms |
| 2 | 5.4 ms | 4.6 ms | 14.5 ms | 0.19 ms | 0.15 ms | 0.91 ms |
| 3 | 5.8 ms | 4.6 ms | 14.6 ms | 0.25 ms | 0.07 ms | 0.88 ms |
| 4 | 5.8 ms | 4.7 ms | 14.5 ms | 0.38 ms | 0.09 ms | 1.12 ms |
| 5 | 4.3 ms | 3.3 ms | 11.9 ms | 0.29 ms | 0.06 ms | 0.65 ms |

- Run 1's 14.8 ms `pread` is first-use warm-up (the same run-1 slowdown as
  every other series); runs 2–5 read 200 KB in 0.19–0.38 ms, the same as the
  native read loop in V5.
- The final empty `pread` still happens (the buffer is clamped to the known
  size, but the loop asks once more past it); without a channel it costs only
  0.06–0.15 ms.
- The open phase was faster in this run (11.9–14.6 ms) than in D2's
  (21–44 ms) with the same open code: query 4.3–5.8 ms and descriptor open
  3.3–4.7 ms against 7.5–21.5 ms and 5.6–12.9 ms. Device conditions differed
  between the runs; the cause isn't established.

## Findings

1. **Reopening the file on every call** cost ~9 ms per call (V2/V3 → V4).
2. **Chunk size is the biggest lever on the channel**: the cost is per
   message, not per byte. 8 KB → 512 KB took V4 from ~350 ms to 32 ms.
   256 KB–1 MB is a sensible range; native should cap the length whatever Dart
   asks for, since V2–V5 allocate `request.length` up front.
3. **The Android main thread is the variable cost on the main channel.** Each
   read waits on main twice (dispatch and `result.success`), and stalls of
   4–257 ms there landed directly on reads. A background task queue channel
   removes those hops: 8 KB calls went from 4–6 ms to 1.1–1.6 ms.
4. **The Dart UI isolate is the other stall point**: channel replies waited up
   to ~248 ms while the app decoded `queryMedia`'s result on it.
5. **Large native reads slowed to 9–10 ms only while `queryMedia` ran.** Five
   back-to-back runs read 200 KB in 0.27–0.43 ms, the first included, so it
   wasn't a cold cache. Cause unproven: MediaProvider/FUSE or CPU contention.
6. **The direct read moves the bytes ~5× faster** than the channel (1–3 ms
   for 200 KB), but **Dart's reopen of `/proc/self/fd/<n>` costs 9.5–17 ms**,
   so for a 200 KB file it ends up level with V5. The reopen is a fixed cost
   per file, so the direct read should pull ahead with larger files (not yet
   measured).
7. **Opening a MediaStore file costs ~6–18 ms each time**, natively and from
   Dart alike: the direct read pays it twice, once to get the descriptor and
   once because `dart:io` can only open by path.
8. **The open phase is now the largest cost per file** (21–44 ms after warm-up):
   more than reading 200 KB on either path. One descriptor per session and
   opening on IO took it down from 37–55 ms.
9. **FFI `pread64` on the session's descriptor is the fastest read path**:
   0.65–1.1 ms for 200 KB after warm-up, against 8–13 ms for V5. It skips the
   reopen, the channel and any copy; the bytes land in native memory that
   Dart views as a `Uint8List`, freed by a finalizer.
10. **EventChannel is not worth building**: events must be sent from the main
   thread and land on the UI isolate, the two places the stalls come from, and
   it has no flow control.
11. The background queue is serial but not pinned to one thread
    (`flutter-worker-0` and `-1` both seen), so the session registry is now a
    `ConcurrentHashMap`.

## Setup during the experiments (superseded)

Replaced by the implemented design below; kept as the record of what V1–V5,
D1/D2 and F1 ran on.

- One `ParcelFileDescriptor` per session, from `openFileDescriptor(uri, "r")`
  on the IO dispatcher; it backs the channel reads (V4/V5) and
  `/proc/self/fd/<n>`. `closeReadSession` releases it.
- Direct read (D2): `openReadDirect` reopens `/proc/self/fd/<n>` with
  `RandomAccessFile`; no seek at 0, no final empty read once `sizeInBytes` is
  reached.
- Channel read: V5 on the background task queue channel, 512 KB chunks.
- FFI read (F1): `openReadFfi` calls `pread64` on `descriptorFd`; the
  session sends the descriptor number alongside `directPath`.

## Raw logs

Every log behind these numbers is in [`logs/`](logs/), one file per run, as
captured (`adb logcat -s MPTiming flutter`, or the app's console). See
[`logs/README.md`](logs/README.md) for which file is which.

## Tooling (during the experiments)

- `utils/Timing.kt` and `lib/src/utils/timing.dart`: `timed`, `Laps`,
  `logMark` (wall-clock marks comparable across sides). Filter with
  `adb logcat -s MPTiming flutter`.
- `MethodChannelMediaProviderAndroid.useBackgroundReadChannel` toggles V5's
  channel vs the main one.
- `MediaReadSession.openReadDirect` is the direct read; the session's
  `directPath` comes from `MediaReadSessionFactory`, and `closeReadSession`
  (`CloseReadSessionRequestHandler`) releases the descriptor.
- The intellisync app's `GetMediaItemsInSourceUseCaseImpl._benchmarkReads`
  reads the first item N times after a start delay, to avoid overlapping the
  dashboard's own queries. Its `mode` picks `ffi` (default, `openReadFfi`),
  `direct` (`openReadDirect`) or `channel` (`openRead`). Its `=== Run … done`
  time covers the read and close phases, not the open phase.

## Proposed design (discussed before implementation)

Implemented, with the differences listed under *Implemented design*.

- **FFI `pread` is the main read path**, chosen per item at session open:

  | Source | Detected by | Read path |
  |---|---|---|
  | Regular file | `openFileDescriptor` works, `Os.fstat` says regular file | FFI `pread` |
  | Pipe or socket (streamed/cloud content) | descriptor works, `fstat` not a regular file; `pread` would fail with `ESPIPE` | FFI `read`, sequential only (no `read(position:)`) |
  | Part of a larger file | `AssetFileDescriptor` with a start offset | FFI `pread`, offset added, bounded by the length |
  | No descriptor | `openFileDescriptor` unsupported or fails | V5 over the background queue, from `openInputStream` |

  Kotlin sends the result in the session (e.g. `readMode: pread | sequential |
  stream`); Dart routes `openRead` to it.
- **Dart owns the descriptor**: Kotlin hands it over with `pfd.detachFd()` and
  keeps no session; Dart closes it with libc `close` over FFI, with a
  `NativeFinalizer` as a safety net. This makes closing free, and rules out
  Kotlin closing the descriptor mid-read and the number being reused by
  another file (a silent wrong-file read). Never `close` a descriptor a
  `ParcelFileDescriptor` still owns: fdsan aborts the app on Android 10+.
- **Use the `@Native` binding** so `pread` writes into an ordinary Dart
  `Uint8List` (GC-accounted, still no copy), instead of `malloc` + finalizer,
  whose native memory the GC doesn't count.
- **Large reads on a background isolate**: FFI reads block the calling isolate.
- **Fix `isSeekable`**: derive it from `fstat` on the descriptor, not
  `File(path).canRead()`.
- **Don't trust `sizeInBytes` for pipes/streams**: read until 0 bytes.
- An unclosed session writes nothing to storage and is cleaned up when the
  process exits; while it lives it leaks a descriptor (limit: a few thousand
  per process).

## Implemented design (2026-10-24)

Commits `837438c7` (Dart), `f24f4000` (native), `fdc41be4` and `6ca1ce2f`.

- **Public API:** `MediaReadSession` is single-use: `openRead({chunkSize})`
  (default 512 KB) or `readAsBytes()`, then it closes itself; `close()` for a
  session never read.
- **Sources** (`lib/src/io/source/`), chosen by `DefaultMediaByteSourceFactory`:

  | Order | Source | When | Read with |
  |---|---|---|---|
  | 1 | `FileByteSource` | `filePath` given and openable by `dart:io` | async `RandomAccessFile`; no platform call |
  | 2 | `DescriptorByteSource` | platform reply `kind: descriptor` | FFI `pread64` (files, sections) or `read` (pipes) on a worker isolate per source |
  | 3 | `ChannelByteSource` | platform reply `kind: channel` | `readFromSession` over the background-queue channel |

- **Native open** (`MediaSourceOpener`): `openAssetFileDescriptor`, `Os.fstat`
  for seekability and size, then `detachFd()`; no session is kept for a
  descriptor. Only an item with no descriptor gets an in-order stream session.
  The MediaStore query at open was removed.
- **Differences from the proposal:** native memory from `malloc`, returned as
  `asTypedList(finalizer: free)` (no copy), not the `@Native` binding; one
  worker isolate per descriptor source; `readAll` goes through the same worker.

## Device results with the implemented design (2026-10-24)

Same device as above. Logs 19–26 in [`logs/`](logs/).

### Both routes, 204,488-byte JPEG, debug build (log 19)

Read and close only (the open is excluded). Session ids `local-1`…`-5` (path)
and `local-6`…`-10` (descriptor); no stream fallback, no fdsan abort, copy's
MD5 matches the original.

| Run | Path (`FileByteSource`) | URI only (`DescriptorByteSource`) |
|---|---|---|
| 1 (cold) | 31 ms | 25 ms |
| 2–5 | 4, 4, 3, 3 ms | 7, 4, 4, 5 ms |

### Both routes, 392,674,791-byte video, profile build, 512 KB (log 20)

| | Path: open | Path: read | URI: open | URI: read |
|---|---|---|---|---|
| Runs 2–5 average | 22.6 ms | 606 ms (~620 MB/s) | 22.8 ms | 586 ms (~640 MB/s) |

Run 1 of each also wrote a copy (899 / 774 ms). Both copies' MD5 matches the
original. Opening costs the same either way, so it's the storage stack, not
`dart:io` or the platform call.

### Read methods in isolation, profile build (logs 21–22)

Whole file read inside one isolate; each chunk copied into a new `Uint8List`
and dropped; nothing delivered elsewhere. Video, average of 3 (log 22):

| Method | 512 KB | 64 KB |
|---|---|---|
| async `dart:io` (`read`) | 637 ms | 1,662 ms |
| sync `dart:io` (`readSync`) on a worker | 208 ms | 199 ms |
| sync FFI `pread64` on a worker | 693 ms | 163 ms |
| sync FFI `pread64` on the caller | 670 ms | 161 ms |

- Async `dart:io` is limited by its per-call IO-thread round trip.
- FFI copies twice (kernel → native buffer → Dart list); at 64 KB that stays in
  cache, at 512 KB it doesn't (likely; not measured directly). `fromList` vs
  `setRange` made no difference (logs 21 vs 22).
- Photo (200 KB): every read is 0.1–2 ms; opening and closing cost 6–15 ms
  whatever the method.

### Sources delivering every chunk to the caller, video, profile build (log 24)

| Source | 512 KB (per chunk) | 64 KB (per chunk) |
|---|---|---|
| plugin `FileByteSource` | 471–597 ms (630–800 µs) | 1,569–1,675 ms (262–280 µs) |
| `readSync` worker, chunks sent back | 587–690 ms (783–921 µs) | 1,650–1,768 ms (275–295 µs) |
| plugin `DescriptorByteSource` | 494–549 ms (660–733 µs) | 1,606 / 2,424 ms (268 / 405 µs) |

Once each chunk crosses to the caller, all three converge: the hand-off
(about 240 µs per chunk at 64 KB, against about 30 µs to read it) decides the
speed, not the read method. Log 23 is the same run with the device idle and
is invalid (every source ~3× slower).

### Chunk sizes, video, profile build, interleaved order (log 26)

| Chunk | `FileByteSource` | `DescriptorByteSource` |
|---|---|---|
| 512 KB | 569 ms | 528 ms |
| 1 MB | 577 ms | 480 ms |
| 2 MB | 740 ms | 855 ms |
| 4 MB | 448 ms | 619 ms |

No steady gain above 512 KB: the best cells are within run-to-run spread, and
2 MB is consistently worst for both. Above 512 KB the per-chunk cost grows with
the chunk's size, so the bytes themselves (likely fresh memory per chunk), not
the number of hand-offs, dominate. **Default kept at 512 KB.** Log 25 is the
same run with the device hot (CPU ~61 °C) and is invalid.

### Benchmarking notes

- Use a profile build; debug skews Dart-side timings.
- Keep the screen on and the app in front (an idle device throttled every
  source ~3×), and let the device cool between long runs; check that a known
  baseline (512 KB ≈ 0.5 s for this video) reproduces before trusting a run.
- Interleave the variants per round so drift affects them all alike.

## Next

- Done: FFI reads on a background isolate; MediaStore query removed from the
  open; open and read timed separately; large video measured on both routes.
- Share one worker isolate across descriptor sources, if many small items
  (e.g. thumbnails by URI) show the per-source worker start (~1–2 ms) matters.
- Reusable chunk buffers, to approach the raw read speed (~1.8–2.3 GB/s); needs
  an API where the caller hands chunks back.
- Small-read patterns (4–64 KB, e.g. header parsing) favour FFI or sync reads;
  revisit if such a read API is added.
