# Raw logs

Every log behind [`../read-path-benchmarks.md`](../read-path-benchmarks.md),
as captured. All read the same 204,488-byte JPEG, debug build, same device.
`D/MPTiming` lines are native, `I/flutter` lines are Dart.

| File | Method | Chunk | What it shows |
|---|---|---|---|
| `01-v4-8kb-native-timing.txt` | V4 | 8 KB | Native read and call time per call; `Taken: 346` ms total |
| `02-v4-512kb-native-timing.txt` | V4 | 512 KB | Same at 512 KB; `Taken: 32` ms total |
| `03-v4-512kb-full-timing.txt` | V4 | 512 KB | First run with timing on both sides: delivery legs, hops, `result.success` |
| `04-v4-8kb-main-channel-full-timing.txt` | V4 | 8 KB | 26 calls with full timing; the 257 ms main-thread stall at `start=49152` |
| `05-v5-8kb-background-queue.txt` | V5 | 8 KB | 26 calls on the background queue; the ~248 ms Dart-side stall at `start=57344` |
| `06-v5-512kb-startup-only-no-read.txt` | — | — | Captured too early: `getVolumes` and `queryMedia` only, no read |
| `07-v5-512kb-run-a-after-slow-query.txt` | V5 | 512 KB | Native read 9.2 ms right after a 673 ms `queryMedia` |
| `08-v5-512kb-run-b.txt` | V5 | 512 KB | Native read 0.48 ms; ~13 ms read phase |
| `09-v5-512kb-run-c-overlapping-query.txt` | V5 | 512 KB | Native read 10.4 ms while `queryMedia` ran |
| `10-v5-512kb-5-runs.txt` | V5 | 512 KB | 5 runs back to back: read loop 0.27–0.43 ms each |
| `11-d1-direct-5-runs.txt` | D1 | 512 KB | First `/proc/self/fd` direct read, 5 runs, with open and close |
| `12-d2-direct-one-descriptor-5-runs.txt` | D2 | 512 KB | One descriptor per session, opened on IO; query and open timed |
| `13-ffi-pread-5-runs.txt` | F1 | 512 KB | FFI `pread64` on the session's descriptor, 5 runs, with open and close |

Files 04 and 05 were exported from logcat; the rest were pasted into the
working session and saved verbatim.

## Implemented design (2026-10-24)

Logs 19–26 measure the unified read API (`MediaReadSession` over byte
sources) with the intellisync harness. Builds and items differ per file; each
file's first line says which. Only `I/flutter` lines are kept.

| File | Build | Item | What it shows |
|---|---|---|---|
| `19-unified-api-image-both-routes-debug.txt` | debug | 200 KB JPEG | Path vs descriptor route, 5 runs each; reconstructed from the log monitor |
| `20-unified-api-video-both-routes-profile.txt` | profile | 375 MB video | Same at 512 KB, open timed; reconstructed from the log monitor |
| `21-read-methods-isolated-fromlist-copy.txt` | profile | photo, video | async/sync `dart:io`, FFI on worker/caller, no delivery; FFI copy via `fromList` |
| `22-read-methods-isolated-setrange-copy.txt` | profile | photo, video | Same with the FFI copy via `setRange` |
| `23-delivered-sources-idle-invalid.txt` | profile | video | **Invalid** (device idle): sources delivering every chunk |
| `24-delivered-sources-awake.txt` | profile | video | Sources delivering every chunk, screen kept awake |
| `25-chunk-sizes-hot-invalid.txt` | profile | video | **Invalid** (device hot): 512 KB–4 MB, sequential order |
| `26-chunk-sizes-interleaved.txt` | profile | video | 512 KB–4 MB, interleaved order |

V1–V3 (~600, ~581, ~579 ms at 8 KB) have no log: their times were recorded as
comments on the methods in `MediaStoreService.kt`.
