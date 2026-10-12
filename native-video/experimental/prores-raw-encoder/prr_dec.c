#include "prr_dec.h"
#include <errno.h>
#include <string.h>

static int alloc_map(struct prr_dec *d, void **buf, void **va, uint32_t size, uint32_t flags)
{
    int rc = duss_hal_mem_alloc(d->mem, buf, size, 0x100, 0, flags);
    if (rc)
        return rc;
    return duss_hal_mem_map(*buf, va);
}

int prr_dec_open(struct prr_dec *d, uint32_t max_frame_bytes, int sync_dir)
{
    memset(d, 0, sizeof *d);
    d->sync_dir = sync_dir;
    int rc = prr_hal_init();
    if (rc)
        return rc;
    if ((rc = duss_hal_device_open("/dev/ion", NULL, &d->mem)) || (rc = duss_hal_device_start(d->mem, NULL)))
        return rc;
    if ((rc = duss_hal_device_open("/dev/msdec0", NULL, &d->dev)))
        return rc;
    d->stream_cap = (max_frame_bytes + 0xfff) & ~0xfffu;
    if ((rc = alloc_map(d, &d->sbuf, (void **)&d->sva, d->stream_cap, 0)))
        return rc;
    prr_putp(d->stream, PRR_STREAM_HANDLE, d->sbuf);
    prr_put32(d->stream, PRR_STREAM_ALLOCATED, d->stream_cap);
    prr_put32(d->stream, PRR_DSTREAM_MODE, 1);
    return 0;
}

static int setup_frame(struct prr_dec *d, int width, int height, int bayer)
{
    if (d->fbuf && width == d->width && height == d->height && bayer == d->bayer)
        return 0;
    if (d->fbuf) {
        duss_hal_mem_free(d->fbuf);
        d->fbuf = NULL;
    }
    if (width <= 0 || height <= 0 || bayer < 0 || bayer > 3)
        return -EINVAL;
    d->width = width;
    d->height = height;
    d->bayer = bayer;
    d->stride = (width * 2 + 0xff) & ~0xff;
    d->frame_bytes = (uint32_t)d->stride * (uint32_t)height;
    int rc = alloc_map(d, &d->fbuf, (void **)&d->fva, d->frame_bytes, d->sync_dir ? PRR_MEM_CACHED : 0);
    if (rc)
        return rc;
    memset(d->frame, 0, sizeof d->frame);
    prr_putp(d->frame, PRR_FRAME_HANDLE, d->fbuf);
    prr_put32(d->frame, PRR_DFRAME_PIXFMT, (uint32_t)(PRR_PIXFMT_BAYER16_BASE + 15 * bayer));
    prr_put32(d->frame, PRR_DFRAME_WIDTH, (uint32_t)width);
    prr_put32(d->frame, PRR_DFRAME_HEIGHT, (uint32_t)height);
    prr_put32(d->frame, PRR_DFRAME_STRIDE, (uint32_t)d->stride);
    return 0;
}

int prr_dec_decode(struct prr_dec *d, uint32_t len, struct prr_dec_meta *meta)
{
    if (len < PRR_DHDR_READ || len > d->stream_cap)
        return -EINVAL;
    _Alignas(16) uint8_t hdr[PRR_DHDR_BYTES] = { 0 };
    prr_putp(hdr, PRR_DHDR_PTR, d->sva);
    prr_put32(hdr, PRR_DHDR_LEN, PRR_DHDR_READ);
    int rc = duss_hal_msdec_parse_header(d->dev, hdr);
    if (rc)
        return rc;
    int w = (int)prr_get32(hdr, PRR_DHDR_WIDTH), h = (int)prr_get32(hdr, PRR_DHDR_HEIGHT);
    if ((rc = setup_frame(d, w, h, (int)prr_get32(hdr, PRR_DHDR_BAYER))))
        return rc;
    prr_put32(d->stream, PRR_DSTREAM_WH, (uint32_t)w);
    prr_put32(d->stream, PRR_DSTREAM_WH + 4, (uint32_t)h);
    prr_put32(d->stream, PRR_STREAM_OFFSET, 0);
    prr_put32(d->stream, PRR_STREAM_WRITTEN, len);
    prr_put32(d->stream, PRR_DSTREAM_SEG2_OFFSET, 0);
    prr_put32(d->stream, PRR_DSTREAM_SEG2_LEN, 0);
    memset(d->arg, 0, sizeof d->arg);
    prr_putp(d->arg, PRR_DARG_STREAM, d->stream);
    prr_putp(d->arg, PRR_DARG_FRAME, d->frame);
    if ((rc = duss_hal_msdec_decstrm(d->dev, d->arg)))
        return rc;
    if (d->sync_dir)
        d->sync_rc = duss_hal_mem_sync(d->fbuf, d->sync_dir);
    if (meta) {
        const uint8_t *a = d->arg;
        memcpy(&meta->width, a + PRR_DARG_HSIZE, 2);
        memcpy(&meta->height, a + PRR_DARG_VSIZE, 2);
        memcpy(meta->crop, a + PRR_DARG_CROP, 4);
        meta->bayer = a[PRR_DARG_BAYER];
        memcpy(&meta->sensel_range, a + PRR_DARG_RANGE, 2);
        memcpy(&meta->wb_red, a + PRR_DARG_WB_RED, 4);
        memcpy(&meta->wb_blue, a + PRR_DARG_WB_BLUE, 4);
        memcpy(meta->matrix, a + PRR_DARG_MATRIX, sizeof meta->matrix);
        memcpy(&meta->gain, a + PRR_DARG_GAIN, 4);
        memcpy(&meta->cct, a + PRR_DARG_CCT, 2);
    }
    return 0;
}

void prr_dec_close(struct prr_dec *d)
{
    if (d->dev)
        duss_hal_device_close(d->dev);
    if (d->fbuf)
        duss_hal_mem_free(d->fbuf);
    if (d->sbuf)
        duss_hal_mem_free(d->sbuf);
    memset(d, 0, sizeof *d);
}
