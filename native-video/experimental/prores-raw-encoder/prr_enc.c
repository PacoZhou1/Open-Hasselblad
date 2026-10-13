#include "prr_enc.h"
#include <errno.h>
#include <string.h>
#include <time.h>

#define PRR_HAL_BUSY (-1007)

static int frame_empty(void *ctx, void **frame_and_ics)
{
    struct prr_enc *e = ctx;
    pthread_mutex_lock(&e->mu);
    int hit = 0;
    for (int i = 0; i < e->cfg.frame_slots; i++)
        if (frame_and_ics[0] == (void *)e->fr[i].frame) {
            e->fr[i].busy = 0;
            hit = 1;
        }
    if (!hit)
        e->unknown_callbacks++;
    pthread_cond_broadcast(&e->cv);
    pthread_mutex_unlock(&e->mu);
    return 0;
}

static int stream_full(void *ctx, struct prr_stream_done *done)
{
    struct prr_enc *e = ctx;
    pthread_mutex_lock(&e->mu);
    int hit = 0;
    for (int i = 0; i < e->cfg.stream_slots; i++) {
        struct prr_stream_pair *p = &e->st[i];
        if (done->stream1 == (void *)p->s[0]) {
            p->result = done->result;
            p->done = done->stream2 ? 2 : 1;
            e->encoded++;
            hit = 1;
        }
    }
    if (!hit)
        e->unknown_callbacks++;
    pthread_cond_broadcast(&e->cv);
    pthread_mutex_unlock(&e->mu);
    return 0;
}

static int alloc_map(struct prr_enc *e, void **buf, void **va, uint32_t size, uint32_t flags)
{
    int rc = duss_hal_mem_alloc(e->mem, buf, size, 0x100, 0, flags);
    if (rc)
        return rc;
    return duss_hal_mem_map(*buf, va);
}

int prr_enc_open(struct prr_enc *e, const struct prr_enc_cfg *cfg)
{
    memset(e, 0, sizeof *e);
    e->cfg = *cfg;
    if (cfg->frame_slots < 1 || cfg->frame_slots > PRR_MAX_SLOTS || cfg->stream_slots < 1 ||
        cfg->stream_slots > PRR_MAX_SLOTS || cfg->width % 8 || cfg->height % 8)
        return -EINVAL;
    pthread_mutex_init(&e->mu, NULL);
    pthread_cond_init(&e->cv, NULL);
    e->frame_bytes = (uint32_t)cfg->stride * (uint32_t)cfg->height;
    e->ics_bytes = ((uint32_t)((cfg->width / 2 + 127) / 128) * (uint32_t)((cfg->height / 2 + 7) / 8) * 16 + 0xff) & ~0xffu;
    e->stream_bytes = ((uint32_t)(e->frame_bytes * 0.8) + 0xfff) & ~0xfffu;

    int rc = prr_hal_init();
    if (rc)
        return rc;
    if ((rc = duss_hal_device_open("/dev/ion", NULL, &e->mem)) || (rc = duss_hal_device_start(e->mem, NULL)))
        return rc;

    uint8_t *o = e->open_cfg;
    prr_putp(o, PRR_OPEN_STREAM_CTX, e);
    prr_putp(o, PRR_OPEN_FRAME_CTX, e);
    prr_putp(o, PRR_OPEN_FRAME_CB, (void *)frame_empty);
    prr_putp(o, PRR_OPEN_STREAM_CB, (void *)stream_full);
    if (cfg->plugin_open) {
        prr_put8(o, PRR_OPEN_U8_08, 1);
        prr_put16(o, PRR_OPEN_WIDTH, (uint16_t)cfg->width);
        prr_put16(o, PRR_OPEN_HEIGHT, (uint16_t)cfg->height);
        prr_put8(o, PRR_OPEN_BAYER, (uint8_t)cfg->bayer);
        prr_put8(o, PRR_OPEN_U8_39, 1);
        prr_put16(o, PRR_OPEN_SENSEL_RANGE, 0xfeff);
        prr_put32(o, PRR_OPEN_U32_3C, 0x1000);
    }
    if ((rc = duss_hal_device_open("/dev/msenc0", o, &e->enc)))
        return rc;

    for (int i = 0; i < cfg->frame_slots; i++) {
        struct prr_frame_slot *f = &e->fr[i];
        void *iva;
        if ((rc = alloc_map(e, &f->fbuf, (void **)&f->va, e->frame_bytes, PRR_MEM_CACHED)) ||
            (rc = alloc_map(e, &f->ibuf, &iva, e->ics_bytes, 0)))
            return rc;
        memset(iva, 0, e->ics_bytes);
        prr_putp(f->frame, PRR_FRAME_HANDLE, f->fbuf);
        prr_put32(f->frame, PRR_FRAME_STRIDE, (uint32_t)cfg->stride);
        prr_put32(f->frame, PRR_FRAME_PLANE_H, (uint32_t)cfg->height);
        prr_put32(f->frame, PRR_FRAME_PLANES, 1);
        prr_putp(f->ics, PRR_ICS_HANDLE, f->ibuf);
    }
    for (int i = 0; i < cfg->stream_slots; i++) {
        struct prr_stream_pair *p = &e->st[i];
        for (int k = 0; k < 2; k++) {
            if ((rc = alloc_map(e, &p->buf[k], (void **)&p->va[k], e->stream_bytes, 0)))
                return rc;
            prr_putp(p->s[k], PRR_STREAM_HANDLE, p->buf[k]);
            prr_put32(p->s[k], PRR_STREAM_ALLOCATED, e->stream_bytes);
        }
    }

    prr_put32(e->start_cfg, PRR_START_WIDTH, (uint32_t)cfg->width);
    prr_put32(e->start_cfg, PRR_START_HEIGHT, (uint32_t)cfg->height);
    prr_put32(e->start_cfg, PRR_START_PROFILE, (uint32_t)cfg->profile);
    prr_put32(e->start_cfg, PRR_START_PIXFMT, (uint32_t)(PRR_PIXFMT_BAYER16_BASE + 15 * cfg->bayer));
    if ((rc = duss_hal_device_start(e->enc, e->start_cfg)))
        return rc;
    e->started = 1;
    return 0;
}

static int wait_until(struct prr_enc *e, const struct timespec *deadline)
{
    return deadline ? pthread_cond_timedwait(&e->cv, &e->mu, deadline) : pthread_cond_wait(&e->cv, &e->mu);
}

static struct timespec *deadline_in(struct timespec *ts, int timeout_ms)
{
    if (timeout_ms < 0)
        return NULL;
    clock_gettime(CLOCK_REALTIME, ts);
    ts->tv_sec += timeout_ms / 1000;
    ts->tv_nsec += (long)(timeout_ms % 1000) * 1000000L;
    if (ts->tv_nsec >= 1000000000L) {
        ts->tv_sec++;
        ts->tv_nsec -= 1000000000L;
    }
    return ts;
}

int prr_enc_acquire_frame(struct prr_enc *e, uint16_t **va)
{
    struct timespec ts;
    struct timespec *dl = deadline_in(&ts, 2000);
    pthread_mutex_lock(&e->mu);
    for (;;) {
        for (int i = 0; i < e->cfg.frame_slots; i++)
            if (!e->fr[i].busy) {
                e->fr[i].busy = 1;
                pthread_mutex_unlock(&e->mu);
                *va = e->fr[i].va;
                return i;
            }
        if (wait_until(e, dl) == ETIMEDOUT) {
            pthread_mutex_unlock(&e->mu);
            return -ETIMEDOUT;
        }
    }
}

int prr_enc_submit(struct prr_enc *e, int slot, uint64_t pts, const struct prr_meta *meta)
{
    struct prr_frame_slot *f = &e->fr[slot];
    pthread_mutex_lock(&e->mu);
    int pair = -1;
    for (int i = 0; i < e->cfg.stream_slots && pair < 0; i++)
        if (!e->st[i].busy)
            pair = i;
    if (pair < 0) {
        pthread_mutex_unlock(&e->mu);
        return -EAGAIN;
    }
    struct prr_stream_pair *p = &e->st[pair];
    for (int k = 0; k < 2; k++) {
        prr_put32(p->s[k], PRR_STREAM_OFFSET, 0);
        prr_put32(p->s[k], PRR_STREAM_WRITTEN, 0);
    }
    p->busy = 1;
    p->done = 0;
    p->pts = pts;
    e->order[(e->order_head + e->order_count) % PRR_MAX_SLOTS] = pair;
    e->order_count++;
    pthread_mutex_unlock(&e->mu);

    prr_put64(f->frame, PRR_FRAME_PTS, pts);
    uint8_t *k = f->packet;
    memset(k, 0, PRR_PKT_BYTES);
    prr_putp(k, PRR_PKT_FRAME, f->frame);
    prr_putp(k, PRR_PKT_ICS, f->ics);
    prr_putp(k, PRR_PKT_STREAM1, p->s[0]);
    prr_putp(k, PRR_PKT_STREAM2, p->s[1]);
    if (meta) {
        prr_putf(k, PRR_PKT_WB_RED, meta->wb_red);
        prr_putf(k, PRR_PKT_WB_BLUE, meta->wb_blue);
        prr_putf(k, PRR_PKT_GAIN, meta->gain);
        for (int i = 0; i < 9; i++)
            prr_putf(k, PRR_PKT_MATRIX + 4 * i, meta->matrix[i]);
        prr_put16(k, PRR_PKT_CCT, meta->cct);
    }
    (void)duss_hal_mem_sync(f->fbuf, 2);
    int rc = duss_hal_msenc_encfrm(e->enc, k);
    pthread_mutex_lock(&e->mu);
    if (rc == PRR_HAL_BUSY) {
        e->busy_returns++;
        rc = 0;
    }
    if (rc) {
        e->order_count--;
        p->busy = 0;
        f->busy = 0;
    } else {
        e->submitted++;
    }
    pthread_mutex_unlock(&e->mu);
    return rc;
}

int prr_enc_pending(struct prr_enc *e)
{
    pthread_mutex_lock(&e->mu);
    int n = e->order_count;
    pthread_mutex_unlock(&e->mu);
    return n;
}

int prr_enc_next(struct prr_enc *e, struct prr_out *out, int timeout_ms)
{
    struct timespec ts;
    struct timespec *dl = deadline_in(&ts, timeout_ms);
    pthread_mutex_lock(&e->mu);
    for (;;) {
        if (!e->order_count) {
            pthread_mutex_unlock(&e->mu);
            return -ENOENT;
        }
        int pair = e->order[e->order_head];
        struct prr_stream_pair *p = &e->st[pair];
        if (p->done) {
            e->order_head = (e->order_head + 1) % PRR_MAX_SLOTS;
            e->order_count--;
            pthread_mutex_unlock(&e->mu);
            const uint8_t *s1 = p->s[0], *s2 = p->s[1];
            out->pair = pair;
            out->pts = p->pts;
            out->result = p->result;
            out->a = p->va[0] + prr_get32(s1, PRR_STREAM_DATA_OFFSET) + prr_get32(s1, PRR_STREAM_OFFSET);
            out->alen = prr_get32(s1, PRR_STREAM_WRITTEN);
            out->b = p->va[1];
            out->blen = p->done == 2 ? prr_get32(s2, PRR_STREAM_WRITTEN) : 0;
            return 0;
        }
        if (timeout_ms == 0 || wait_until(e, dl) == ETIMEDOUT) {
            pthread_mutex_unlock(&e->mu);
            return -ETIMEDOUT;
        }
    }
}

void prr_enc_release(struct prr_enc *e, const struct prr_out *out)
{
    pthread_mutex_lock(&e->mu);
    e->st[out->pair].busy = 0;
    e->st[out->pair].done = 0;
    pthread_cond_broadcast(&e->cv);
    pthread_mutex_unlock(&e->mu);
}

void prr_enc_close(struct prr_enc *e)
{
    if (e->enc) {
        e->close_step = 1;
        if (e->started)
            duss_hal_device_stop(e->enc, NULL);
        e->close_step = 2;
        duss_hal_device_close(e->enc);
        e->enc = NULL;
    }
    e->close_step = 3;
    for (int i = 0; i < PRR_MAX_SLOTS; i++) {
        if (e->fr[i].fbuf)
            duss_hal_mem_free(e->fr[i].fbuf);
        if (e->fr[i].ibuf)
            duss_hal_mem_free(e->fr[i].ibuf);
        for (int k = 0; k < 2; k++)
            if (e->st[i].buf[k])
                duss_hal_mem_free(e->st[i].buf[k]);
    }
    memset(e->fr, 0, sizeof e->fr);
    memset(e->st, 0, sizeof e->st);
    e->close_step = 4;
}

static void *close_thread(void *arg)
{
    prr_enc_close(arg);
    return NULL;
}

int prr_enc_close_timed(struct prr_enc *e, int timeout_ms)
{
    pthread_t t;
    if (pthread_create(&t, NULL, close_thread, e))
        return -1;
    pthread_detach(t);
    for (int waited = 0; e->close_step != 4 && waited < timeout_ms; waited += 10) {
        struct timespec ts = { 0, 10000000L };
        nanosleep(&ts, NULL);
    }
    return e->close_step;
}
