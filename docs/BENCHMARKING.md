# Benchmark protocol

The aim is to determine whether lower resident memory is worth any extra interaction delay. Do not compare runs taken under different workloads.

## Repeatable A/B test

1. Start Spotify and keep the same game, browser tabs, and background apps open throughout the test.
2. Record the working-set sum, private memory where available, current process CPU estimates, and the adaptive ceiling for each managed process.
3. Minimize Spotify for at least 60 seconds, then restore it. Measure from window focus until the first successful click/keyboard action. Record whether playback continued, whether the UI reloaded, and whether the same page/view and state were retained. Repeat five times.
4. Repeat with another workload and again after a fresh Spotify start. Do not change code or settings between comparable samples.
5. Compare median restore-to-interaction time, minimum resident working set, page-fault deltas, CPU estimates, playback interruptions, UI reload/state loss, and whether the adaptive policy raises or lowers ceilings.

## Interpreting metrics

- **Working set:** pages currently resident in physical memory for a process. Summing process working sets may double-count shared pages.
- **Private memory:** private committed process memory as reported by Windows process metadata; it is not the same as resident RAM.
- **CPU percentage:** an estimate based on process CPU-time deltas normalized to one logical processor, so 100% means one logical CPU fully busy. Short bursts may be averaged or missed by the sample interval.
- **Page-fault delta/rate:** changes in cumulative Windows page-fault counters; includes soft and hard faults and is not a direct disk-read counter.
- **Restore-operation duration:** time spent restoring original Windows limits. It does not measure when Spotify accepts input, and it cannot establish that page faults caused any observed delay.
- **Restore-to-interaction time:** manually measured end-to-end recovery from window focus until the UI accepts input.

The adaptive policy raises a ceiling after sustained high CPU usage and lowers it only when CPU is low and the process has working-set headroom. These thresholds are heuristics; data from real Windows systems should guide future changes. Any audio interruption, persistent hang, or repeated long recovery is a reason to disable optimization and restore original limits.
