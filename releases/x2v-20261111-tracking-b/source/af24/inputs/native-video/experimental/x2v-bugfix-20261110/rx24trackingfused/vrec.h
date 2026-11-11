#ifndef X2V_VREC_H
#define X2V_VREC_H
#include <stdint.h>

/* H.264 clips from the ISP colour stream (1300x970 NV12, every frame). */

struct vrec_stats {
    uint32_t seen, dropped, fed, frames, keys, feed_ms_max;
    uint64_t bytes;
    int error;
};

/* Applied in place to every tight 1300x970 NV12 frame before it is encoded. */
void vrec_set_filter(void (*fn)(uint8_t *nv12, int w, int h));
/* Starts the next clip's encoder ahead of it: the tool's start stalls the SSD for up to
 * ~0.6 s. A no-op while a live one waits; vrec_begin arms one itself if none does. */
int vrec_arm(uint32_t bitrate);
/* Stops a waiting encoder; a no-op while a clip is open. */
void vrec_disarm(void);
/* Feeds the armed encoder a clip written to <dirfd>/clip.partial.mov. */
int vrec_begin(int dirfd, uint32_t bitrate);
/* Waits up to <ms> for the clip's first muxed frame; returns the ms waited. The encoder's
 * hardware wakes on its first frame after ~1 s idle, and that stalls the SSD for 0.1-0.6 s. */
uint32_t vrec_wait_output(uint32_t ms);
/* Colour-callback side; a no-op unless a clip is open. */
void vrec_colour(void *frame);
/* Ends the clip: every fed frame is in the file, which is closed and renamed clip.mov. */
int vrec_end(struct vrec_stats *st);
void vrec_stats(struct vrec_stats *st);

#endif
