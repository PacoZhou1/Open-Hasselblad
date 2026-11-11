/* Capture-only, fixed-size telemetry. No file I/O in the callback. */
#define TOOLS_BUCKETS 64
struct tools_timing_bucket {
    _Atomic uint32_t seen, dropped, source_gaps, pre_count, pre_us_max;
    _Atomic uint64_t pre_ns;
};
static struct tools_timing_bucket tools_trace[TOOLS_BUCKETS];
static uint64_t tools_previous_ts;
static unsigned tools_bucket(void)
{
    uint64_t elapsed = now_ns() - S.clip_begin_ns;
    unsigned b = (unsigned)(elapsed / 1000000000ull);
    return b < TOOLS_BUCKETS ? b : TOOLS_BUCKETS - 1;
}
static void tools_trace_reset(void)
{
    memset(tools_trace, 0, sizeof tools_trace);
    tools_previous_ts = 0;
}
static void tools_trace_seen(void *frame)
{
    unsigned b = tools_bucket();
    atomic_fetch_add(&tools_trace[b].seen, 1);
    uint64_t ts = u64(frame, 0x30);
    if (tools_previous_ts && ts > tools_previous_ts) {
        uint64_t period = 1000000u / TOOLS_FPS;
        uint64_t intervals = (ts - tools_previous_ts + period/2) / period;
        if (intervals > 1 && intervals < 1000)
            atomic_fetch_add(&tools_trace[b].source_gaps, (uint32_t)(intervals - 1));
    }
    tools_previous_ts = ts;
}
static void tools_trace_drop(void)
{
    atomic_fetch_add(&tools_trace[tools_bucket()].dropped, 1);
}
static void tools_trace_pre(uint64_t start)
{
    uint64_t elapsed = now_ns() - start;
    struct tools_timing_bucket *b = &tools_trace[tools_bucket()];
    atomic_fetch_add(&b->pre_count, 1);
    atomic_fetch_add(&b->pre_ns, elapsed);
    uint32_t us = (uint32_t)(elapsed / 1000), old = atomic_load(&b->pre_us_max);
    while (old < us && !atomic_compare_exchange_weak(&b->pre_us_max, &old, us)) {}
}
static void tools_trace_save(void)
{
    FILE *f = fopen(LIVE_DIR "/frame-timing.json.tmp", "w");
    if (!f) return;
    fprintf(f, "{\"fps\":%d,\"window\":\"monotonic seconds since recording begins\",\"buckets\":[", TOOLS_FPS);
    int comma = 0;
    for (unsigned i=0; i<TOOLS_BUCKETS; ++i) {
        struct tools_timing_bucket *b = &tools_trace[i];
        uint32_t n = atomic_load(&b->seen);
        if (!n) continue;
        uint32_t count = atomic_load(&b->pre_count);
        fprintf(f, "%s{\"second\":%u,\"seen\":%u,\"dropped\":%u,\"source_gaps\":%u,\"pre_us_mean\":%.1f,\"pre_us_max\":%u}",
                comma++ ? "," : "", i, n, atomic_load(&b->dropped), atomic_load(&b->source_gaps),
                count ? (double)atomic_load(&b->pre_ns)/count/1000.0 : 0,
                atomic_load(&b->pre_us_max));
    }
    fputs("]}\n", f);
    if (!fclose(f)) rename(LIVE_DIR "/frame-timing.json.tmp", LIVE_DIR "/frame-timing.json");
}
