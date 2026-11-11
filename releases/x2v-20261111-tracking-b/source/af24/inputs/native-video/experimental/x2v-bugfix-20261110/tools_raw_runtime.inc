#include "tools_raw_stats.h"
static pthread_mutex_t tools_stats_mu = PTHREAD_MUTEX_INITIALIZER;
static struct tools_raw_stats tools_stats;
static _Atomic int tools_stats_enabled, tools_stats_prr = 1;
static _Atomic uint32_t tools_raw_total;
static _Atomic uint64_t tools_stats_at;
static uint64_t tools_stats_ts, tools_stats_epoch;
static unsigned tools_stats_seq;

static void tools_stats_maybe(const void *raw, uint64_t source_ts)
{
    uint64_t now = now_ns();
    if (!atomic_load(&tools_stats_enabled) || now - atomic_load(&tools_stats_at) < 200000000ull) return;
    if (pthread_mutex_trylock(&tools_stats_mu)) return;
    static const struct prr_pre_geom geom = PRR_PRE_GEOM_MODE21;
    struct timespec realtime;
    clock_gettime(CLOCK_REALTIME, &realtime);
    tools_raw_collect(&tools_stats, raw, &geom, SENSOR_WHITE, TOOLS_FPS == 30);
    tools_stats_epoch = (uint64_t)realtime.tv_sec * 1000 + realtime.tv_nsec / 1000000;
    tools_stats_ts = source_ts;
    tools_stats_seq++;
    atomic_store(&tools_stats_at, now);
    pthread_mutex_unlock(&tools_stats_mu);
}

static void tools_stats_poll(void)
{
    static uint64_t preference_at;
    uint64_t now = now_ns();
    if (now - preference_at > 500000000ull) {
        preference_at = now;
        int enabled = 0;
        FILE *f = fopen("/blackbox/x2v-native-20261011/product/raw-histogram.enabled", "r");
        if (f) { int value = fgetc(f); enabled = value == '1'; fclose(f); }
        atomic_store(&tools_stats_enabled, enabled);
        char codec[24] = {0};
        f = fopen("/blackbox/x2v-native-20261011/product/codec", "r");
        if (f) { (void)fgets(codec, sizeof codec, f); fclose(f); }
        atomic_store(&tools_stats_prr, !strncmp(codec, "prores_raw", 10));
    }
    if (!atomic_load(&tools_stats_enabled)) return;
    static unsigned published;
    struct tools_raw_stats data;
    uint64_t at, ts, epoch;
    unsigned seq;
    pthread_mutex_lock(&tools_stats_mu);
    seq = tools_stats_seq;
    if (!seq || seq == published) { pthread_mutex_unlock(&tools_stats_mu); return; }
    data = tools_stats; ts = tools_stats_ts; epoch = tools_stats_epoch;
    at = atomic_load(&tools_stats_at);
    pthread_mutex_unlock(&tools_stats_mu);
    FILE *f = fopen(LIVE_DIR "/exposure-raw.json.tmp", "w");
    if (!f) return;
    fprintf(f, "{\"schema\":1,\"pid\":%d,\"sequence\":%u,\"fps\":%d,\"epoch_ms\":%llu,\"uptime_ms\":%llu,\"source_ts_us\":%llu,"
            "\"stage\":\"RAW before WB and display gain\",\"coverage\":\"32x32 Bayer-cell grid\","
            "\"clip_stage\":\"ProRes RAW production normalization\",\"black\":%.2f,\"white\":%.0f,\"clip_source_code\":%u,"
            "\"highlight_valid\":%s,\"shadow_valid\":false,\"sample_count\":[%u,%u,%u],\"clipped_count\":[%u,%u,%u],"
            "\"raw_max\":[%u,%u,%u],\"histogram\":[",
            getpid(), seq, TOOLS_FPS, (unsigned long long)epoch, (unsigned long long)(at/1000000),
            (unsigned long long)ts, data.black, data.white, data.source_clip_code,
            data.high_valid && atomic_load(&tools_stats_prr) ? "true" : "false",
            data.count[0], data.count[1], data.count[2], data.clipped[0], data.clipped[1], data.clipped[2],
            data.maximum[0], data.maximum[1], data.maximum[2]);
    double density[256], peak = 0;
    for (int i=0;i<256;i++) {
        density[i] = 0;
        for (int c=0;c<3;c++) {
            double value = data.count[c] ? (double)data.bins[c][i]/data.count[c] : 0;
            if (value>density[i]) density[i]=value;
        }
        if (density[i]>peak) peak=density[i];
    }
    for (int i=0;i<256;i++)
        fprintf(f, "%s%u", i ? "," : "", peak>0 ? (unsigned)(density[i]*255/peak+.5) : 0);
    fputs("]}\n", f);
    if (!fclose(f) && !rename(LIVE_DIR "/exposure-raw.json.tmp", LIVE_DIR "/exposure-raw.json")) published=seq;
}
