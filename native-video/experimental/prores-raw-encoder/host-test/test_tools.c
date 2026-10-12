/* Host harness for the hardware-independent parts of x2v_prr_dec: the MOV reader and the preview renderer. */
#include "../prr_movr.h"
#include "../prr_view.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int cmd_movr(const char *path)
{
    struct prr_movr r;
    int rc = prr_movr_open(&r, path);
    if (rc) {
        printf("{\"rc\": %d}\n", rc);
        return 1;
    }
    printf("{\"rc\": 0, \"count\": %u, \"recovered\": %d, \"fourcc\": \"%s\", \"width\": %u, \"height\": %u, "
           "\"timescale\": %u, \"duration\": %u, \"max\": %u, \"samples\": [",
           r.count, r.recovered, r.fourcc, r.width, r.height, r.timescale, r.sample_duration, prr_movr_max_size(&r));
    uint8_t *buf = malloc(prr_movr_max_size(&r) + 1);
    int bad = 0;
    for (uint32_t i = 0; i < r.count; i++) {
        int n = prr_movr_read(&r, i, buf, prr_movr_max_size(&r));
        if (n != (int)r.sizes[i] || memcmp(buf + 4, "prrf", 4))
            bad++;
        printf("%s[%llu, %u]", i ? ", " : "", (unsigned long long)r.offsets[i], r.sizes[i]);
    }
    printf("], \"bad\": %d}\n", bad);
    free(buf);
    prr_movr_close(&r);
    return bad != 0;
}

static int cmd_view(int argc, char **argv)
{
    if (argc != 21)
        return 2;
    const char *in = argv[2];
    int w = atoi(argv[3]), h = atoi(argv[4]), stride = atoi(argv[5]);
    struct prr_dec_meta m = { 0 };
    m.bayer = (uint8_t)atoi(argv[6]);
    m.wb_red = strtof(argv[7], NULL);
    m.wb_blue = strtof(argv[8], NULL);
    int scale = atoi(argv[9]);
    float ev = strtof(argv[10], NULL);
    for (int i = 0; i < 9; i++)
        m.matrix[i] = strtof(argv[11 + i], NULL);
    const char *out = argv[20];
    FILE *f = fopen(in, "rb");
    size_t bytes = (size_t)stride * h;
    uint16_t *bayer = malloc(bytes);
    if (!f || fread(bayer, 1, bytes, f) != bytes)
        return 1;
    fclose(f);
    struct prr_view v;
    prr_view_setup(&v, &m, w, h, scale, ev);
    uint8_t *rgb = malloc((size_t)v.out_w * v.out_h * 3);
    prr_view_rows(&v, bayer, stride, rgb, 0, v.out_h);
    f = fopen(out, "wb");
    fwrite(rgb, 1, (size_t)v.out_w * v.out_h * 3, f);
    fclose(f);
    printf("{\"out_w\": %d, \"out_h\": %d}\n", v.out_w, v.out_h);
    return 0;
}

int main(int argc, char **argv)
{
    if (argc >= 3 && !strcmp(argv[1], "movr"))
        return cmd_movr(argv[2]);
    if (argc >= 3 && !strcmp(argv[1], "view"))
        return cmd_view(argc, argv);
    fprintf(stderr, "usage: test_tools movr file | view in.raw w h stride bayer wbr wbb scale ev m0..m8 out.rgb\n");
    return 2;
}
