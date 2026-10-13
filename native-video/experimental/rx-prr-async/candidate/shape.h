#ifndef X2V_SHAPE_V5
#define X2V_SHAPE_V5
/* DUSS pixel namespace, not the topology's independent numeric enum. */
#ifndef X2V_SHAPE
#define X2V_SHAPE 0
#endif
#if X2V_SHAPE == 0
#define X2V_TOKEN "HB23_DRIVER52"
#define X2V_NAME "liveview_sbpc"
#define X2V_PIXEL 2U /* stock RAW shadow's explicit NV12 carrier descriptor */
#define X2V_WIDTH 7408U
#define X2V_HEIGHT 1482U
#define X2V_STRIDE 14848U
#elif X2V_SHAPE == 1
#define X2V_TOKEN "GROUP13_HB23_RAW"
#define X2V_NAME "disp_null"
#define X2V_PIXEL 10001U /* stock conf RAW16_OPAQUE, actual frame still gated */
#define X2V_WIDTH 3920U
#define X2V_HEIGHT 986U
#define X2V_STRIDE 7936U
#elif X2V_SHAPE == 2
#define X2V_TOKEN "GROUP13_MODE21C24_PRR_ASYNC_V1"
#define X2V_NAME "disp_null"
#define X2V_PIXEL 10001U /* owned direct RAW graph; not shadow carrier2 */
#define X2V_WIDTH 3920U
#define X2V_HEIGHT 2946U
#define X2V_STRIDE 7936U
#else
#error Unsupported receiver shape
#endif
#if X2V_SHAPE == 0
#define X2V_PORT "inport0"
#else
/* Native listen style2 calls whole-filter callback, not a push/pull port. */
#define X2V_PORT "FlterDmp"
#endif
#define X2V_BYTES (X2V_STRIDE*X2V_HEIGHT)
#endif
