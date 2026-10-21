/* MODE21 preview sampling: keep the RAW receiver geometry unchanged and
 * give the 970-line ISP preview exactly 2910 source rows (3:1 vertically).
 * Device A/B/A and H264/ProRes short clips: preview-debug-20261015/crop-*-trial.
 * This removes the coarse beat bands before CPU colour processing. It is a
 * mode-specific preview crop, not a general sensor calibration or RAW repair.
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <stdatomic.h>

extern int x2v_base_isp_geometry(void *, size_t);
static _Atomic int aligned;
static uint32_t get(const unsigned char *p, size_t o)
{
    uint32_t x; memcpy(&x, p + o, sizeof x); return x;
}
static void put(unsigned char *p, size_t o, uint32_t x)
{
    memcpy(p + o, &x, sizeof x);
}

int x2v_preview_lattice_aligned(void) { return atomic_load(&aligned); }

int x2v_isp_full_transfer_geometry(void *row, size_t n)
{
    int e = x2v_base_isp_geometry(row, n);
    if (e) return e;
    unsigned char *p = row;
    if (n != 0x640 || get(p, 0x5c8) != 1 || get(p, 0x5dc) != 3920 ||
        get(p, 0x5e0) != 2946 || get(p, 0x5cc) || get(p, 0x5d0)) return EPROTO;
    /* Native SUBFRONT crop descriptor: even origin, centred, within input.
     * RAW 3920x2946 and ProRes 3888x2912 are untouched. */
    put(p, 0x5d0, 18);
    put(p, 0x5e0, 2910);
    atomic_store(&aligned, 1);
    fprintf(stderr, "X2V_PREVIEW_GEOMETRY y=18 h=2910 output_h=970 raw_unchanged=1\n");
    return 0;
}
