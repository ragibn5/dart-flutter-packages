package com.ragibn5.media.provider.media_provider_android.utils

import android.util.Log

// Experiment-only helpers for profiling the read pipeline.

internal const val TIMING_TAG = "MPTiming"

/**
 * Runs [block] and logs how long it took, in microseconds, under [TIMING_TAG].
 *
 * Inline so [block] may suspend. Logs even if [block] throws.
 */
internal inline fun <T> timed(label: String, block: () -> T): T {
    val start = System.nanoTime()
    try {
        return block()
    } finally {
        Log.d(TIMING_TAG, "$label: ${(System.nanoTime() - start) / 1_000}us")
    }
}

/**
 * Logs the time between consecutive [lap] calls, for spans that a single
 * block can't wrap, such as a thread hop.
 *
 * The first lap is measured from construction.
 */
internal class Laps(private val label: String) {
    private var last = System.nanoTime()

    fun lap(name: String) {
        val now = System.nanoTime()
        Log.d(TIMING_TAG, "$label $name: ${(now - last) / 1_000}us")
        last = now
    }
}

/**
 * Sums the time spent in each named step across many [add] calls, for steps
 * repeated per row or per item, and logs the totals with [log].
 */
internal class Totals(private val label: String) {
    @PublishedApi
    internal val nanos = LinkedHashMap<String, Long>()

    @PublishedApi
    internal val counts = LinkedHashMap<String, Int>()

    inline fun <T> add(name: String, block: () -> T): T {
        val start = System.nanoTime()
        try {
            return block()
        } finally {
            nanos[name] = (nanos[name] ?: 0L) + (System.nanoTime() - start)
            counts[name] = (counts[name] ?: 0) + 1
        }
    }

    fun log() {
        for ((name, total) in nanos) {
            val count = counts[name] ?: 0
            val average = if (count == 0) 0 else total / count / 1_000
            Log.d(
                TIMING_TAG,
                "$label $name: ${total / 1_000}us total, $count calls, ${average}us avg"
            )
        }
    }
}

/**
 * Logs the wall-clock time in milliseconds under [TIMING_TAG].
 *
 * Comparable with the Dart side's marks, which read the same clock.
 */
internal fun logMark(label: String) {
    Log.d(TIMING_TAG, "$label at ${System.currentTimeMillis()}ms")
}
