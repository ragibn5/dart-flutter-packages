# getMedia benchmarks (DFP-65)

How long `getMedia` (`queryMedia` on the platform side) takes, and where.
Priority: a one-time listing, so a few extra milliseconds are fine; what
matters is not blocking the Android main thread or the Dart UI isolate.

Debug build, same device as the read benchmarks. Raw log:
[`logs/14-get-media-baseline.txt`](logs/14-get-media-baseline.txt).

## Baseline: 634 items (585 photos, 49 videos)

Each row: how many times the step ran in this one `getMedia` call, the time
of all those runs together, and the average per run.

| Step | Runs on | Calls | Total time | Avg per call |
|---|---|---|---|---|
| `contentResolver.query` (photos, videos) | `Dispatchers.Default` | 2 | 44.1 ms (28.3 + 15.8) | 22 ms |
| `cursor.moveToNext` | `Dispatchers.Default` | 636 | 3.6 ms | 6 µs |
| Read columns | `Dispatchers.Default` | 634 | 23.0 ms | 36 µs |
| **Resolve file location** | `Dispatchers.Default` | **634** | **659.3 ms (86% of the service)** | **1.04 ms** |
|   `storageManager.getStorageVolume(file)` | | 634 | 530.7 ms | 837 µs (675 µs photos, 2.77 ms videos) |
|   Volume path | | 634 | 11.7 ms | 18 µs |
|   `StatFs` for the volume identity | | 634 | 100.5 ms | 159 µs |
| Build content URI | `Dispatchers.Default` | 634 | 16.9 ms | 27 µs |
| Build item | `Dispatchers.Default` | 634 | 5.2 ms | 8 µs |
| **Service total** | `Dispatchers.Default` | 1 | **767.4 ms** | — |
| JSON encode (481,316 chars, ~760 per item) | `Dispatchers.Default` | 1 | 114.0 ms | — |
| `result.success` (encode + send) | **Android main thread** | 1 | 1.8 ms | — |
| Delivery to Dart | — | 1 | ~7 ms | — |
| `jsonDecode` | **Dart UI isolate** | 1 | 25.7 ms | — |
| `MediaItem.fromJson` | **Dart UI isolate** | 634 | 5.7 ms | 9 µs |
| **Round trip, as Dart sees it** | | 1 | **904.7 ms** | 1.43 ms per item |

`moveToNext` runs once more per query than there are rows: the last call
returns `false`.

A second `queryMedia` (the target use case, 0 rows) took 17.6 ms.

## Findings

1. **The Android main thread is barely touched**: 1.8 ms for
   `result.success`. The query and encoding already run off it.
2. **The Dart UI isolate is blocked ~31 ms** (`jsonDecode` + `fromJson`):
   about two frames at 60 Hz, and it grows with the library.
3. **86% of the native time is resolving each file's location**: a
   `getStorageVolume` call and a `StatFs` per row, for data that is the same
   for every file on a volume.
4. **The JSON is ~760 chars per item**, partly because every item repeats its
   full volume identity.

## Run 2: volumes looked up once per call, decode on a background isolate

`FileLocationResolver.batch()` looks the volumes up once (with one `StatFs`
each) and matches every path to its volume by prefix; `getMedia` decodes in
`Isolate.run`. Raw log:
[`logs/15-get-media-batch-volumes-isolate-decode.txt`](logs/15-get-media-batch-volumes-isolate-decode.txt).

| Step | Runs on | Calls | Baseline total | Run 2 total | Avg per call (run 2) |
|---|---|---|---|---|---|
| Volume lookup | `Dispatchers.Default` | 1 (was 634) | — | 1.0 ms | — |
| `contentResolver.query` (photos, videos) | `Dispatchers.Default` | 2 | 44.1 ms | 35.5 ms | 18 ms |
| `cursor.moveToNext` | `Dispatchers.Default` | 636 | 3.6 ms | 1.6 ms | 2 µs |
| Read columns | `Dispatchers.Default` | 634 | 23.0 ms | 15.2 ms | 24 µs |
| **Resolve file location** | `Dispatchers.Default` | 634 | **659.3 ms** | **11.6 ms** | **18 µs** (was 1.04 ms) |
| Build content URI | `Dispatchers.Default` | 634 | 16.9 ms | 7.2 ms | 11 µs |
| Build item | `Dispatchers.Default` | 634 | 5.2 ms | 3.4 ms | 5 µs |
| **Service total** | `Dispatchers.Default` | 1 | **767.4 ms** | **91.1 ms** | — |
| JSON encode (481,316 chars) | `Dispatchers.Default` | 1 | 114.0 ms | 113.8 ms | — |
| `result.success` | Android main thread | 1 | 1.8 ms | 1.9 ms | — |
| **Round trip, as Dart sees it** | | 1 | **904.7 ms** | **228.9 ms** | — |
| `jsonDecode` | UI isolate → background isolate | 1 | 25.7 ms | 52.8 ms | — |
| `MediaItem.fromJson` | UI isolate → background isolate | 634 | 5.7 ms | 10.7 ms | 17 µs |
| Decode, as awaited (incl. isolate start) | | 1 | 31.4 ms (blocking the UI) | 116.2 ms (not blocking) | — |
| **Total until the list is ready** | | | **~936 ms** | **~345 ms** | — |

- **Resolving file locations is 57× faster** (659 → 11.6 ms), and the
  native service is 8.4× faster (767 → 91 ms).
- **JSON encoding is now the largest native step** (114 ms, 54% of the
  handler), off the main thread.
- **The UI isolate no longer runs the decode**, but `Isolate.run` costs:
  the decode itself runs ~2× slower on the fresh isolate (63.5 ms against
  31.4 ms), and starting the isolate and handing the result back add ~53 ms.
  For the empty result, the isolate alone took 41.8 ms for 0.1 ms of work.
  Debug builds inflate isolate start-up; not yet measured in profile mode.

## Run 3: volume cache in `FileLocationResolver`, query builder on IO

Final resolver: it caches the mounted volumes itself (`@Volatile`, refreshed
on a miss, no lock), with `resolve(path)` unchanged. `mediaQueryBuilder.build`
moved inside the service's `withContext(IO)`. Raw log:
[`logs/16-get-media-cached-volumes-builder-on-io.txt`](logs/16-get-media-cached-volumes-builder-on-io.txt).

| Step | Runs on | Calls | Run 2 total | Run 3 total | Avg per call (run 3) |
|---|---|---|---|---|---|
| Decode request (`parseRequest`) | **Android main** | 1 | not timed | **5.9 ms** (0.8 ms on the 2nd call) | — |
| Build queries | IO (was Default) | 1 | not timed | 1.1 ms | — |
| `contentResolver.query` (photos, videos) | IO | 2 | 35.5 ms | 57.0 ms (48.9 + 8.1) | 28 ms |
| Read columns | IO | 634 | 15.2 ms | 14.5 ms | 22 µs |
| Resolve file location | IO | 634 | 11.6 ms | 12.6 ms | 20 µs |
| Build content URI + item | IO | 634 | 10.6 ms | 8.4 ms | 13 µs |
| Service total | | 1 | 91.1 ms | 105.0 ms | — |
| JSON encode | Default | 1 | 113.8 ms | 123.5 ms | — |
| `result.success` | **Android main** | 1 | 1.9 ms | 1.9 ms | — |
| Round trip, as Dart sees it | | 1 | 228.9 ms | 252.9 ms | — |
| Decode, as awaited (background isolate) | | 1 | 116.2 ms | 136.4 ms | — |

- The cached volumes hold: resolving all 634 file locations takes 12.6 ms.
- The differences from run 2 are run-to-run noise, mostly in the photo
  query (48.9 ms against 21.8 ms).
- **`parseRequest` takes 5.9 ms on the main thread on the first call**
  (0.8 ms after): likely first-use warm-up of the JSON decoder. It's the
  largest piece of main-thread work in `getMedia`.
