# getVolumes benchmarks (DFP-65)

How long `getVolumes` takes on the platform side, and on which thread.
Debug build, same device as the other benchmarks, 2 volumes. Raw log:
[`logs/17-get-volumes-baseline.txt`](logs/17-get-volumes-baseline.txt).

## Baseline

`GetVolumesHandler.handle` has no `withContext`, so everything below runs on
the **Android main thread** (`service total (main)` in the log).

| Step | Runs on | Calls | Total time | Avg per call |
|---|---|---|---|---|
| `storageManager.storageVolumes` (system call) | **main** | 1 | 3.3 ms | — |
| Volume path | **main** | 2 | 0.1 ms | 62 µs |
| `StatFs` | **main** | 2 | 1.0 ms | 502 µs |
| `VolumeState.from` | **main** | 2 | 0.6 ms | 323 µs |
| Type (reflective `getId`) | **main** | 2 | 1.0 ms | 475 µs |
| **Service total** | **main** | 1 | **7.0 ms** | — |
| JSON encode | **main** | 1 | 4.2 ms | — |
| `result.success` | **main** | 1 | 0.2 ms | — |
| **Handler total** | **main** | 1 | **11.5 ms** | — |

## Findings

1. **All 11.5 ms is on the main thread**: about 70% of a 60 Hz frame.
2. The largest pieces are the volume-list system call (3.3 ms) and the JSON
   encoding (4.2 ms for 2 volumes, most likely the JSON library's first-use
   set-up, as `parseRequest` showed for `queryMedia`).
3. `VolumeIdentity` is built in two places with different defaults:
   `VolumeProviderServiceImpl` sets `capacityInBytes = stats?.capacityInBytes`
   (nullable), `FileLocationResolver` sets `stats?.capacityInBytes ?: 0`. If
   `StatFs` fails, the same volume comes back with `null` capacity from
   `getVolumes` and `0` inside a media item.

## Run 2: off the main thread, one shared `VolumeProviderService`

`GetVolumesHandler.handle` runs in `withContext(Dispatchers.IO)`;
`VolumeIdentity` is built only in `VolumeProviderServiceImpl`, and
`FileLocationResolver` gets its volumes from the same instance. Raw log:
[`logs/18-get-volumes-on-io-shared-service.txt`](logs/18-get-volumes-on-io-shared-service.txt)
(its first few lines were cut off when captured).

| Step | Baseline (main) | Run 2: `getVolumes` call (worker) | Run 2: resolver refresh during `getMedia` |
|---|---|---|---|
| `storageManager.storageVolumes` | 3.3 ms | (not captured) | 0.05 ms |
| Volume path, 2 calls | 0.1 ms | 0.2 ms | 0.03 ms |
| `StatFs`, 2 calls | 1.0 ms | 4.6 ms | 0.8 ms |
| `VolumeState.from`, 2 calls | 0.6 ms | 0.9 ms | 0.02 ms |
| Type (reflective `getId`), 2 calls | 1.0 ms | 2.5 ms | 0.5 ms |
| Service total | 7.0 ms | 10.6 ms | — |
| JSON encode | 4.2 ms | 15.6 ms | — |
| Handler total | **11.5 ms on main** | **29.8 ms off main** | — |
| `result.success` (main) | 0.2 ms | 0.2 ms | — |

- **The work now runs on `DefaultDispatcher-worker-4`**: the main thread
  only receives the call and sends the reply.
- It took longer on the worker (29.8 ms against 11.5 ms). At startup the
  worker likely competes with everything else starting up, and doesn't get
  the main thread's priority; this is the first `getVolumes` call, so it also
  pays first-use costs. Off the main thread, that only delays the result.
- The second set of `[getVolumes]` lines, during `getMedia`, is the resolver
  filling its cache through the shared service: all warm, under 1.5 ms in
  total.
- `queryMedia` is unchanged: 247.6 ms round trip (run 3: 252.9 ms).
