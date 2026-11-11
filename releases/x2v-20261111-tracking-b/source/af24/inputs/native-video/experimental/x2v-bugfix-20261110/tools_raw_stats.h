#ifndef X2V_TOOLS_RAW_STATS_H
#define X2V_TOOLS_RAW_STATS_H
#include <math.h>
#include <stdint.h>
#include <string.h>

/* Sample actual pre-encoder RAW, before WB, display gain and display curves.
 * The high flag means the production normalization irreversibly clips those
 * measured samples. It is NOT inferred from a white monitor pixel. Coverage
 * is an explicit sampling grid; absence is not proof about every photosite.
 */
struct tools_raw_stats {
    uint32_t bins[3][256], count[3], clipped[3], maximum[3];
    float black, white;
    uint32_t source_clip_code;
    int high_valid;
};

static uint16_t tools_raw_value(const uint16_t *raw, const struct prr_pre_geom *g,
                                int x, int y, int class_all)
{
    size_t at = (size_t)y * g->src_stride_px + x;
    if (y % 6 == 1 && (class_all || (x & 1)))
        return (uint16_t)(((uint32_t)raw[at - 2 * g->src_stride_px] + raw[at + 2 * g->src_stride_px] + 1) >> 1);
    return raw[at];
}

static void tools_raw_collect(struct tools_raw_stats *out, const uint16_t *raw,
                              const struct prr_pre_geom *g, float white, int class_all)
{
    memset(out, 0, sizeof *out);
    /* Local optical-black scratch; never race the encoder's black histogram. */
    uint32_t histogram[4096] = {0}, n = 0;
    for (int y=g->ob_y0; y<g->ob_y1; y+=9)
        for (int r=0; r<2; ++r)
            for (int x=g->ob_x[r][0]; x<g->ob_x[r][1]; ++x) {
                histogram[raw[(size_t)y*g->src_stride_px+x] >> 4]++;
                n++;
            }
    uint32_t total=0, median=0;
    while (median<4095 && (total+=histogram[median]) < (n+1)/2) median++;
    uint64_t sum=0, samples=0;
    for (unsigned i=median>32 ? median-32 : 0; i<4096 && i<=median+32; ++i) {
        sum += (uint64_t)histogram[i] * (i << 4);
        samples += histogram[i];
    }
    out->black = samples ? (float)((double)sum/samples) : 0;
    out->white = white;
    /* MODE21 source codewords are LE16 with four zero low bits. The first
     * measurable codeword beyond the fixed production white is conservative
     * even when fixed-point normalization rounds by a code or two. */
    out->source_clip_code = (uint32_t)(ceilf(white/16.0f)*16.0f);
    out->high_valid = n && out->black>=512 && white-out->black>=1024;
    float scale = white>out->black ? 256.0f/(white-out->black) : 0;
    for (int y=g->y0; y+1<g->y0+g->height; y+=32)
        for (int x=g->x0; x+1<g->x0+g->width; x+=32) {
            const int dx[4]={0,1,0,1}, dy[4]={0,0,1,1}, channel[4]={0,1,1,2};
            for (int k=0; k<4; ++k) {
                unsigned c=(unsigned)channel[k];
                uint32_t v=tools_raw_value(raw,g,x+dx[k],y+dy[k],class_all);
                int bin=(int)((v-out->black)*scale);
                bin=bin<0 ? 0 : bin>255 ? 255 : bin;
                out->bins[c][bin]++;
                out->count[c]++;
                out->clipped[c] += v>=out->source_clip_code;
                if (v>out->maximum[c]) out->maximum[c]=v;
            }
        }
}
#endif
