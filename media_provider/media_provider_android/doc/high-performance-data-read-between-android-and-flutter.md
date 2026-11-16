# High performance data read between Android and Flutter

## Abstract

Android apps often need to read data they don't own: photos, videos,
documents, or files shared by other apps. Android exposes such data through
content providers, such as `MediaStore`, which identify each item by a
`content://` URI. A raw file path may also exist, but the app may not be
allowed to read the file through the regular file APIs (Java, Kotlin or Dart).
And the data isn't always backed by a plain file. The data a content provider serves can be:

- A regular file.
- A section of a larger file (given by a start offset and a length).
- A pipe, which can only be read in order.
- Generated or converted by the provider on request, such as a thumbnail.

Dart's file APIs (`File` and `RandomAccessFile`, from `dart:io`) also operate
on file paths, not content URIs. Content URIs are an Android concept. So when
no readable path exists, the stream has to be opened on the Android side, and
its bytes have to cross into the Dart VM. Or we can be smart about it.

This paper compares three approaches:

| Approach                 | Mechanism                                                                                  |
|:-------------------------|:-------------------------------------------------------------------------------------------|
| Direct path              | Dart opens the file path with `dart:io`                                                    |
| Platform channel         | Android reads the stream and returns each chunk in a method-call reply                     |
| File descriptor hand-off | Android opens the stream and hands its file descriptor to Dart, which reads it through FFI |

For each approach, the paper describes the mechanism, its strengths and its limits, and measures it on a real device.

Main results:

- **Small streams (~200 KB):** opening the stream costs more than reading it.
  Opening and closing takes 6–15 ms, while reading takes 0.1–2 ms.
- **Large streams (~375 MB):** the direct path and the file descriptor perform
  the same, at about 0.6 s per stream. The bottleneck is handing each chunk to
  the consumer, not the read itself.
- **Platform channels** are only competitive with large messages (512 KB) and
  a handler that runs off the Android main thread.

The paper ends with a design that picks the fastest available approach for each stream.

## Contents

1. [Introduction](#1-introduction)
2. [Background](#2-background)
3. [Cost model](#3-cost-model)
4. [Approaches](#4-approaches)
5. [Methodology](#5-methodology)
6. [Results](#6-results)
7. [Discussion](#7-discussion)
8. [Proposed design](#8-proposed-design)
9. [Limitations and future work](#9-limitations-and-future-work)
10. [Conclusion](#10-conclusion)
11. [References](#11-references)
12. [Appendix A. Detailed results](#appendix-a-detailed-results)
13. [Appendix B. Behaviour verification](#appendix-b-behaviour-verification)

> Units: 1 KB = 1,024 bytes, 1 MB = 1,024 KB, 1 GB = 1,024 MB.

---

## 1. Introduction

### 1.1 Problem

An app can always read the files in its own storage by path. Data it doesn't own is different:

- Android exposes it through content providers, as `content://` URIs that the app opens with `ContentResolver` (native side).
- A raw file path may also exist. Whether the app can read it depends on the Android version, the app's permissions and the provider.
- Some streams have no backing file at all. The provider generates or converts them on request, as with thumbnails, or streams them through a pipe.

| Source                                           | What the app holds        | Readable with `dart:io`?               |
|:-------------------------------------------------|:--------------------------|:---------------------------------------|
| Files in the app's own storage                   | A path                    | Yes                                    |
| Data owned by others, through a content provider | A `content://` URI        | No: `dart:io` opens paths only         |
| The same data, through a raw path                | A path, when one is known | Sometimes: depends on file access      |
| Generated or converted data, such as thumbnails  | A `content://` URI        | No: no file, or one the app can't open |

In every case except the first, the Android side has to open the stream, and its bytes, or a handle to it, have to be passed to Dart.

### 1.2 Requirements

| Requirement    | Meaning                                                                                                                |
|:---------------|:-----------------------------------------------------------------------------------------------------------------------|
| Universality   | Reads any stream Android can open: whole files, file sections, pipes, and streams that can't be opened as a descriptor |
| Throughput     | Large streams (hundreds of MB) at close to storage speed                                                               |
| Latency        | Small streams (hundreds of KB) in a few milliseconds                                                                   |
| Responsiveness | Never blocks the Android main thread or the Flutter UI isolate                                                         |
| Bounded memory | A slow or paused consumer never causes unbounded buffering                                                             |
| Safe ownership | Every file descriptor is closed exactly once, even if the caller forgets                                               |

### 1.3 Terms

| Term     | Meaning in this paper                                     |
|:---------|:----------------------------------------------------------|
| Stream   | The bytes behind one URI or path, read from start to end  |
| Chunk    | The unit read and delivered at a time, for example 512 KB |
| Consumer | The code that receives the chunks                         |

---

## 2. Background

### 2.1 Android

#### Opening a content URI

On Android, an app reads provider data through `ContentResolver` [1]. Given a `content://` URI, the resolver can open the stream as a file descriptor (e.g., `openAssetFileDescriptor`) [4]. This is an ordinary file descriptor, but it doesn't always point to a whole file:

- **A section of a larger file.** The descriptor comes with a start offset and a length, and the stream is only that range [6].
- **A pipe.** A provider that generates or converts data can return a pipe instead of a file. A pipe can't seek, so it can only be read in order [4].
- **Unknown length.** The length may be reported as unknown, in which case the stream runs to the end of the descriptor [6].

A content provider only serves data as a descriptor, so a content URI that opens always yields one [7]. When no descriptor is returned, the open has failed, and opening the same URI as a stream fails too ([Appendix B](#appendix-b-behaviour-verification)).

#### Sources that can only be opened as a stream

Not every source `ContentResolver` opens is a content URI. App resources and assets (e.g., `android.resource://` URIs) can only be opened as a descriptor when they are stored uncompressed in the APK. A compressed one can still be read as a stream, but not as a descriptor [8] ([Appendix B](#appendix-b-behaviour-verification)).

#### Handing a descriptor over

The descriptor doesn't have to stay on the Android side. Android can release its ownership of the descriptor and hand out the raw descriptor number (e.g., `detachFd()`), after which the receiver is responsible for closing it [5]. We use this to hand a stream over to Dart.

#### Raw file paths

A raw path, on the other hand, is only usable some of the time. A provider may expose a file path for an item when it is backed by a file (e.g., `MediaStore`'s `DATA` column), but the file isn't guaranteed to be available, or accessible, and Android recommends opening the item through the provider instead, for better performance [3]. Even when a path is known, whether the app may read it depends on the Android version and the permissions the app holds [1], [2].

### 2.2 Flutter and Dart

#### Isolates

Dart code runs in isolates, which don't share a heap. When an isolate sends an object to another one, the object is copied, unless it is immutable [14]. A `Uint8List` isn't immutable, so every chunk passed between isolates is copied. The UI isolate's primary job is to render the app's UI, so anything that keeps it busy for longer than a frame (16.7 ms at 60 Hz) shows up as jank.

#### Platform channels

Platform channels connect Dart/Flutter to Android code [9]. Each message is encoded, sent across, and decoded on the other side. On Android, a channel's handler runs on the main thread by default. A channel can instead be bound to a background task queue, which runs its handler on a background thread [10]. The queue runs tasks one at a time, but not always on the same thread, so any state shared between calls must be thread-safe [10].

#### Event channels

`EventChannel` is the push-based variant: Android sends events, and Dart listens [11]. The Android side is only told when Dart starts or stops listening. It is never told that the Dart subscription is paused.

#### File access in Dart

For files, `dart:io` provides `RandomAccessFile` [12]. It opens files by path only, and allows at most one asynchronous operation at a time on each open file, so asynchronous reads of one file can't overlap.

#### FFI

`dart:ffi` lets Dart call C functions directly. A call blocks the calling isolate until it returns. Native memory can be exposed to Dart as a `Uint8List` without copying, and a finalizer can free that memory once the list is garbage collected [13].

#### One process

Finally, Android and the Dart VM run in the same process. A file descriptor opened by Android is therefore also valid for C calls made from Dart. This is what makes the file descriptor hand-off possible.

---

## 3. Cost model

Reading a stream splits into these costs:

| Cost          | What it covers                                                            | Incurred                 |
|:--------------|:--------------------------------------------------------------------------|:-------------------------|
| Open cost     | Opening the stream and preparing the approach                             | Once per stream          |
| Request cost  | Fixed overhead of requesting one chunk: encoding, scheduling, thread hops | Once per chunk           |
| Read cost     | Moving the chunk's bytes from storage into memory                         | Proportional to size     |
| Copy cost     | Copying the chunk across a boundary: Android to Dart, or between isolates | Proportional to size     |
| Hand-off cost | Delivering the chunk to a consumer in another isolate                     | Per chunk, plus per byte |
| Close cost    | Releasing the descriptor and any other resources                          | Once per stream          |

Predictions from the model:

| Case                             | Dominant cost          | Implication                                                      |
|:---------------------------------|:-----------------------|:-----------------------------------------------------------------|
| Small stream (1–2 chunks)        | Open cost              | The approach matters little; avoid opening the stream twice      |
| Large stream (many chunks)       | Per-chunk costs        | Larger chunks mean fewer requests, until copying them costs more |
| No request cost and no copy cost | Read and hand-off cost | The lower bound for any approach                                 |

---

## 4. Approaches

### 4.1 Direct path

**Mechanism**

- When a readable path exists, Dart opens it with `dart:io` (e.g., `RandomAccessFile`) and reads it asynchronously.
- No Android code is involved.

| Strengths                                | Limitations                                                                                   |
|:-----------------------------------------|:----------------------------------------------------------------------------------------------|
| No platform calls                        | Often unavailable: no path, no permission, or no backing file                                 |
| No copy between Android and Dart/Flutter | A path from a provider can still fail to open (e.g., not readable), so a fallback is required |
| Never blocks the calling isolate         | Async reads on one file can't overlap, so each read waits for the previous one                |
| Plain `dart:io`                          |                                                                                               |

### 4.2 Platform channel

**Mechanism**

- Android opens the stream and keeps it open for the session.
- Dart requests each chunk with a method call, and Android replies with the bytes.
- Dart requests the next chunk only when the consumer is ready, so pausing the consumer pauses the reads (backpressure).

| Strengths                                                                           | Limitations                                             | Mitigation                    |
|:------------------------------------------------------------------------------------|:--------------------------------------------------------|:------------------------------|
| Works with any source, including stream-only ones (e.g., a compressed app resource) | High request cost per message                           | Large messages (e.g., 512 KB) |
| Backpressure through pull-based requests                                            | Default handlers run on the Android main thread         | Background task queue         |
| Standard Flutter API, no native code                                                | Replies are delivered on the UI isolate, behind UI work | None within this approach     |
|                                                                                     | Every chunk is copied into a message                    | None within this approach     |
|                                                                                     | Android has to track and close every open stream        | Thread-safe session registry  |

**Why not `EventChannel`:** the Android handler is only notified of `listen` and `cancel`. Pausing the Dart subscription doesn't reach Android, which keeps pushing events, so memory grows without bound.

### 4.3 File descriptor hand-off

**Mechanism**

1. Android opens the stream as a file descriptor (e.g., `openAssetFileDescriptor`).
2. Android inspects the descriptor to tell a regular file from a pipe or socket (e.g., `Os.fstat`).
3. Android releases ownership of the descriptor (e.g., `detachFd()`), and passes its number to Dart, together with the start offset and size. Android keeps no state.
4. Dart reads the descriptor through native calls over FFI:
   - files and file sections with a positional read (e.g., `pread64`), which can read at any offset;
   - pipes with a sequential read (e.g., `read`), which can only read in order.
5. The reads run on a worker isolate, so blocking native calls never block the caller.
6. Each chunk is read into native memory and exposed to Dart as a `Uint8List` without copying. The memory is freed once the list is garbage collected.
7. Dart closes the descriptor when the session ends, with a finalizer as a fallback.

| Strengths                                                  | Limitations                                                                   | Mitigation                                    |
|:-----------------------------------------------------------|:------------------------------------------------------------------------------|:----------------------------------------------|
| No platform calls while reading                            | Some sources can't be opened as a descriptor (e.g., compressed app resources) | Fall back to the platform channel             |
| No copy: the kernel writes directly into memory Dart reads | Pipes aren't seekable                                                         | Sequential reads until a read returns 0 bytes |
| Covers files, file sections and pipes                      | FFI calls block their isolate                                                 | Reads run on a worker isolate                 |
| No state on the Android side                               | Spawning the worker adds a fixed cost per stream                              | One worker could be shared across streams     |
| Never blocks the caller                                    | Dart must close the descriptor exactly once                                   | Explicit close, plus a finalizer              |
|                                                            | Depends on the C library's read functions                                     | Contained within this approach                |

**Why not reopen the descriptor by path:** `dart:io` can open an already open descriptor by a path that refers to it (e.g., `/proc/self/fd/<n>`), but that opens the stream a second time and pays the open cost again. Reading over FFI uses the descriptor that is already open.

### 4.4 Comparison

|                           | Direct path              | Platform channel                  | File descriptor hand-off                                       |
|:--------------------------|:-------------------------|:----------------------------------|:---------------------------------------------------------------|
| Available when            | A readable path exists   | Always                            | The source opens as a descriptor: every content URI that opens |
| Request cost per chunk    | One async `dart:io` read | A platform round trip             | A message to the worker isolate                                |
| Copy cost                 | None                     | One copy per chunk                | None                                                           |
| Seeking                   | Yes                      | Depends on the stream             | Files and sections; not pipes                                  |
| State on the Android side | None                     | One session per stream            | None                                                           |
| Android main thread       | Not used                 | Not used, with a background queue | Not used                                                       |

---

## 5. Methodology

| Item             | Setting                                                                                                                             |
|:-----------------|:------------------------------------------------------------------------------------------------------------------------------------|
| Device           | Nothing CMF Phone 2 Pro: MediaTek Dimensity 7300 Pro 5G, 8 GB RAM, 256 GB storage; Android 16 (Nothing OS 4.1)                      |
| Small stream     | 204,488-byte JPEG (~200 KB)                                                                                                         |
| Large stream     | 392,674,791-byte MP4 (~375 MB)                                                                                                      |
| Generated stream | The provider's thumbnails of both, requested at 256×256                                                                             |
| Storage          | Primary shared storage                                                                                                              |
| Build            | Profile, unless marked _debug_                                                                                                      |
| Runs             | Small stream: 5 consecutive runs, with the first (warm-up) run reported separately. Large stream: 3–5 runs per variant, interleaved |
| Integrity        | Copies made through the direct path and the file descriptor matched the source's MD5                                                |
| Timing           | Wall-clock timestamps on both the Android and the Dart side                                                                         |
| Behaviour checks | Android emulators, API 29, 30, 33 and 36, with and without media permission ([Appendix B](#appendix-b-behaviour-verification))      |

Conditions that skewed results, and were controlled:

| Condition                            | Effect                                     |
|:-------------------------------------|:-------------------------------------------|
| Debug build                          | Distorts Dart-side timings                 |
| Screen off, or app in the background | Every approach ~3× slower                  |
| Hot device (CPU at ~61 °C)           | Results invalid                            |
| Concurrent heavy platform work       | Native reads ~20–37× slower                |
| Variants run back to back            | Drift favours whichever variant runs first |

Each session started by reproducing a known baseline: the large stream read in 512 KB chunks in about 0.5 s.

---

## 6. Results

Key results; the full measurements are in [Appendix A](#appendix-a-detailed-results).

| Finding                                                         | Result                                                                                                    | Details                                    |
|:----------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------|:-------------------------------------------|
| Small streams: opening costs more than reading                  | 200 KB: opening and closing 6–15 ms, reading 0.1–2 ms                                                     | [A.1](#a1-small-stream-200-kb)             |
| Large streams: direct path and file descriptor perform the same | 375 MB: 606 ms and 586 ms (~620–640 MB/s)                                                                 | [A.2](#a2-large-stream-375-mb)             |
| Delivery, not reading, sets the throughput                      | Reading alone: ~1.8–2.3 GB/s. With delivery: ~0.6 GB/s. Per 64 KB chunk: hand-off ~240 µs, read ~30 µs    | [A.3](#a3-read-cost-against-hand-off-cost) |
| 512 KB is the best chunk size                                   | No consistent gain above 512 KB; 2 MB slowest                                                             | [A.4](#a4-chunk-size)                      |
| Platform channels need large requests off the main thread       | 200 KB: 8–13 ms with 512 KB requests on a background queue, ~350 ms with 8 KB requests on the main thread | [A.5](#a5-platform-channel-configuration)  |
| Generated streams read only the generated bytes                 | Thumbnail of the 375 MB video: 41 KB read, opened in 11–14 ms                                             | [A.6](#a6-generated-streams-thumbnails)    |

---

## 7. Discussion

### 7.1 Model against measurements

Every prediction of the cost model (§3) held:

| Prediction                                                    | Confirmed by                                                                                          |
|:--------------------------------------------------------------|:------------------------------------------------------------------------------------------------------|
| Small streams are dominated by the open cost                  | [A.1](#a1-small-stream-200-kb)                                                                        |
| Larger chunks mean fewer requests, so less request cost       | [A.5](#a5-platform-channel-configuration): 8 KB → 512 KB requests on the main thread, ~350 ms → 32 ms |
| Very large chunks stop paying off                             | [A.4](#a4-chunk-size)                                                                                 |
| Without request and copy costs, only read and hand-off remain | [A.3](#a3-read-cost-against-hand-off-cost)                                                            |

### 7.2 What limits each case

| Case             | Limit                    | Evidence                                                                                                                                                                                                | Implication                                                                            |
|:-----------------|:-------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------|
| Small streams    | Open cost                | Independent of size: a descriptor open takes ~3–13 ms in Android code, the full open of the 375 MB stream ~23 ms from Dart. Reopening a descriptor by path adds ~10–17 ms                               | Open each stream once. Don't reopen by path, or query the provider just to find a path |
| Large streams    | Hand-off cost            | Per 64 KB chunk: hand-off ~240 µs, read ~30 µs. Chunks are copied between isolates, so the cost grows with chunk size                                                                                   | The read mechanism stops mattering: the direct path and the file descriptor converge   |
| Platform channel | Request cost, and stalls | ~1–6 ms per 8 KB request, depending on the handler's thread. Stalls come from a busy Android main thread (removed by a background task queue) and a busy UI isolate (unavoidable: replies arrive there) | A fallback: it always works, but is never the fastest                                  |

### 7.3 Chunk size

| Chunk size    | Effect                                                                             |
|:--------------|:-----------------------------------------------------------------------------------|
| 64 KB or less | Per-chunk costs add up; async `dart:io` is 2.6× slower than at 512 KB              |
| 512 KB        | Per-chunk costs stay small, and each chunk is still cheap to allocate and hand off |
| 2 MB or more  | No consistent gain; allocating and copying large chunks dominates                  |

---

## 8. Proposed design

Use the fastest approach available for each stream:

| Order | Approach                 | Used when                                                                   |
|:------|:-------------------------|:----------------------------------------------------------------------------|
| 1     | Direct path              | A path is known and `dart:io` can open it                                   |
| 2     | File descriptor hand-off | The stream opens as a descriptor                                            |
| 3     | Platform channel         | The source can only be opened as a stream (e.g., a compressed app resource) |

| Concern           | Decision                                                                                                                                         |
|:------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------|
| Interface         | One read session per stream, the same for every approach: chunked (`Stream<Uint8List>`) or whole                                                 |
| Backpressure      | Pull-based reads; pausing the consumer pauses the reads                                                                                          |
| Chunk size        | 512 KB                                                                                                                                           |
| Threading         | No blocking work on the Android main thread or the UI isolate: descriptor reads on a worker isolate, channel handlers on a background task queue |
| Unknown size      | Read until a read returns 0 bytes                                                                                                                |
| Seeking           | Files and sections: yes. Pipes and streams: in order only                                                                                        |
| Ownership         | Descriptor: closed by Dart, with a finalizer as a fallback. Channel: owned by Android until the session closes                                   |
| Generated streams | Opened as a descriptor of the requested type and size (e.g., `openTypedAssetFileDescriptor`)                                                     |

---

## 9. Limitations and future work

| Limitation                                        | Consequence                                                                               |
|:--------------------------------------------------|:------------------------------------------------------------------------------------------|
| One device                                        | Absolute numbers will differ on other devices                                             |
| Primary shared storage only                       | SD cards and USB drives untested                                                          |
| Two stream sizes (200 KB, 375 MB)                 | Sizes in between are interpolated                                                         |
| Some small-stream tests in debug builds           | Comparable with each other, not with profile results                                      |
| Platform channel not measured on the large stream | Its large-stream throughput is predicted                                                  |
| Pipe performance not measured                     | Behaviour verified ([Appendix B](#appendix-b-behaviour-verification)); throughput unknown |

| Future work                                                   | Expected benefit                                      |
|:--------------------------------------------------------------|:------------------------------------------------------|
| Chunk buffer reuse (the consumer returns buffers)             | Fewer allocations, closer to raw read throughput      |
| Zero-copy transfer between isolates (`TransferableTypedData`) | Lower hand-off cost                                   |
| Reading in the consumer's isolate, when it can block          | No hand-off cost                                      |
| One worker isolate shared across streams                      | ~1–2 ms saved per stream, for many small streams      |
| Small positional reads (4–64 KB), e.g., file headers          | FFI and sync reads were fastest at 64 KB in isolation |

---

## 10. Conclusion

- **No single approach covers every stream:** the direct path when available, the file descriptor for almost everything else, the platform channel as the last resort.
- **Small streams are dominated by the open cost:** open each stream once.
- **Large streams are dominated by the hand-off cost:** the direct path and the file descriptor are equally fast, at about 0.6 GB/s.
- **Platform channels are competitive only** with 512 KB requests on a background task queue.
- **Further gains have to come from cheaper delivery** (buffer reuse, fewer copies between isolates), not from faster reads.

---

## 11. References

**Android**

1. [Access media files from shared storage](https://developer.android.com/training/data-storage/shared/media)
2. [Data and file storage overview](https://developer.android.com/training/data-storage)
3. [`MediaStore.MediaColumns.DATA`](https://developer.android.com/reference/android/provider/MediaStore.MediaColumns#DATA)
4. [`ContentResolver`](https://developer.android.com/reference/android/content/ContentResolver): `openAssetFileDescriptor`, `openTypedAssetFileDescriptor`, `loadThumbnail`, `EXTRA_SIZE`
5. [`ParcelFileDescriptor.detachFd`](https://developer.android.com/reference/android/os/ParcelFileDescriptor#detachFd())
6. [`AssetFileDescriptor`](https://developer.android.com/reference/android/content/res/AssetFileDescriptor)
7. [`ContentProvider`](https://developer.android.com/reference/android/content/ContentProvider): `openFile`, `openAssetFile`, `openTypedAssetFile`, `openPipeHelper`
8. [`Resources.openRawResourceFd`](https://developer.android.com/reference/android/content/res/Resources#openRawResourceFd(int))

**Flutter and Dart**

9. [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)
10. [`BinaryMessenger`](https://api.flutter.dev/javadoc/io/flutter/plugin/common/BinaryMessenger.html)
11. [`EventChannel`](https://api.flutter.dev/flutter/services/EventChannel-class.html)
12. [`RandomAccessFile`](https://api.dart.dev/stable/dart-io/RandomAccessFile-class.html)
13. [`Uint8Pointer.asTypedList`](https://api.dart.dev/stable/dart-ffi/Uint8Pointer/asTypedList.html)
14. [`SendPort.send`](https://api.dart.dev/stable/dart-isolate/SendPort/send.html)

---

## Appendix A. Detailed results

Each result states the stream size and where the time was measured: **Android** (time in Android code only) or **Dart** (time observed on the Dart side, including any transfer from Android).

### A.1 Small stream (200 KB)

| Measurement                                               | Stream | Measured on | Time                        | Build   |
|:----------------------------------------------------------|:-------|:------------|:----------------------------|:--------|
| Reading the whole stream natively (reference)             | 200 KB | Android     | 0–1 ms                      | _debug_ |
| Opening the stream as a descriptor (`openFileDescriptor`) | 200 KB | Android     | 3.3–12.9 ms                 | _debug_ |
| Opening and closing the stream                            | 200 KB | Dart        | 6–15 ms                     | profile |
| Direct path: reading and closing                          | 200 KB | Dart        | 3–4 ms (31 ms on first run) | _debug_ |
| File descriptor: reading and closing                      | 200 KB | Dart        | 4–7 ms (25 ms on first run) | _debug_ |
| File descriptor: the `pread64` call alone                 | 200 KB | Dart        | 0.19–0.38 ms                | _debug_ |
| Platform channel: reading, in 2 requests of up to 512 KB  | 200 KB | Dart        | 8–13 ms                     | _debug_ |
| Reopening the descriptor by path (`/proc/self/fd`)        | 200 KB | Dart        | 9.5–17.2 ms                 | _debug_ |

### A.2 Large stream (375 MB)

The whole stream read in 512 KB chunks, each chunk delivered to the consumer, measured on the Dart side. Average of runs 2–5:

| Approach        | Stream | Open    | Read   | Throughput |
|:----------------|:-------|:--------|:-------|:-----------|
| Direct path     | 375 MB | 22.6 ms | 606 ms | ~620 MB/s  |
| File descriptor | 375 MB | 22.8 ms | 586 ms | ~640 MB/s  |

### A.3 Read cost against hand-off cost

Two tests separate reading from delivery. Both read the whole 375 MB stream, measured on the Dart side.

**Read only:** each chunk is discarded after it is read.

| Reader                                              | 512 KB chunks | 64 KB chunks |
|:----------------------------------------------------|:--------------|:-------------|
| Async `dart:io` (direct path)                       | 637 ms        | 1,662 ms     |
| FFI `pread64` on a worker isolate (file descriptor) | 693 ms*       | 163 ms       |
| Sync `dart:io` on a worker isolate (reference)      | 208 ms        | 199 ms       |

\* This test copied each chunk out of native memory, which the file descriptor approach doesn't do. At 512 KB, that copy likely no longer fits in the CPU cache.

**Read and deliver:** each chunk is delivered to the consumer. The figure in brackets is the time per chunk.

| Approach        | 512 KB chunks           | 64 KB chunks                    |
|:----------------|:------------------------|:--------------------------------|
| Direct path     | 471–597 ms (630–800 µs) | 1,569–1,675 ms (262–280 µs)     |
| File descriptor | 494–549 ms (660–733 µs) | 1,606 / 2,424 ms (268 / 405 µs) |

The resulting throughputs and per-chunk costs are summarised in [§6](#6-results).

### A.4 Chunk size

The whole 375 MB stream read with each chunk delivered to the consumer, measured on the Dart side, with chunk sizes interleaved:

| Chunk size | Direct path | File descriptor |
|:-----------|:------------|:----------------|
| **512 KB** | **569 ms**  | **528 ms**      |
| 1 MB       | 577 ms      | 480 ms          |
| 2 MB       | 740 ms      | 855 ms          |
| 4 MB       | 448 ms      | 619 ms          |

### A.5 Platform channel configuration

The 200 KB stream read over a platform channel, measured on the Dart side, _debug_:

| Configuration                                       | Result                                     |
|:----------------------------------------------------|:-------------------------------------------|
| Stream reopened for every request                   | ~9 ms more per request                     |
| 8 KB requests, handler on the Android main thread   | 4–6 ms per request; ~350 ms for the stream |
| 512 KB requests, handler on the Android main thread | 32 ms for the stream                       |
| 8 KB requests, handler on a background task queue   | 1.1–1.6 ms per request                     |
| 512 KB requests, handler on a background task queue | 8–13 ms for the stream                     |
| Stalls caused by a busy Android main thread         | 4–257 ms each                              |
| Reply delays caused by a busy UI isolate            | Up to ~248 ms                              |

### A.6 Generated streams: thumbnails

Thumbnails opened with `openTypedAssetFileDescriptor(uri, "image/*", {EXTRA_SIZE: 256×256})` and read through the file descriptor, measured on the Dart side:

| Source | Source size       | Thumbnail size | Dimensions | Open (warm) | Read   |
|:-------|:------------------|:---------------|:-----------|:------------|:-------|
| Photo  | 204,488 bytes     | 124,929 bytes  | 800×602    | 7–9 ms      | 1–3 ms |
| Video  | 392,674,791 bytes | 41,352 bytes   | 304×540    | 11–14 ms    | 2–3 ms |

The provider returned its closest cached thumbnail, not the requested size. Its cached thumbnail files couldn't be opened by path (`Permission denied`).

---

## Appendix B. Behaviour verification

Behaviour claims were checked on Android emulators (API 29, 30, 33 and 36), using media files indexed by `MediaStore`, test providers, and raw resources stored compressed and uncompressed. Each check ran with and without the media read permission. Every result below was the same on all four API levels unless a column says otherwise.

| Source                                                   | Opened as a descriptor                                                                                            | Opened as a stream              |
|:---------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------|:--------------------------------|
| `MediaStore` image, video and audio                      | Regular file; length not declared, size from the file                                                             | Works                           |
| Provider generating data through a pipe                  | Pipe; length unknown; positional reads fail (`ESPIPE`), sequential reads return all bytes                         | Works                           |
| Provider returning an uncompressed asset                 | Regular file (the APK), with a start offset and a length; a positional read at the offset returns the right bytes | Works                           |
| `android.resource://` URI, uncompressed resource         | Regular file (the APK), with a start offset and a length                                                          | Works                           |
| `android.resource://` URI, compressed resource           | Fails (`FileNotFoundException`)                                                                                   | Works                           |
| Provider implementing no open method                     | Fails (`FileNotFoundException`)                                                                                   | Fails (`FileNotFoundException`) |
| `MediaStore` thumbnail (`image/*` with a requested size) | Regular file: the provider's cached thumbnail                                                                     | —                               |

| Path access                                            | API 29                      | API 30, 33 and 36           |
|:-------------------------------------------------------|:----------------------------|:----------------------------|
| `MediaStore` item, without media permission            | Item not visible to the app | Item not visible to the app |
| `MediaStore` item's `DATA` path, with media permission | Fails (`EACCES`)            | Readable                    |
| Provider's cached thumbnail file, by path              | Fails (`EACCES`)            | Fails (`EACCES`)            |
