#ifndef X2V_HAL_PROFILE_ADAPTER_H
#define X2V_HAL_PROFILE_ADAPTER_H
#include <stdint.h>
#include <stddef.h>
#define X2V_HAL_PROFILE_COUNT 10u
#define X2V_HAL_PROFILE_BYTES 312u
#define X2V_HAL_SENSOR_BYTES 132u
/* Cam-info output offset120 points to this actual indirect header. */
typedef struct { uint32_t count,padding; uintptr_t rows; } X2vNativeArrayHeader;
typedef struct {
    X2vNativeArrayHeader header;
    unsigned char profiles[X2V_HAL_PROFILE_COUNT][X2V_HAL_PROFILE_BYTES];
    unsigned char sensors[X2V_HAL_PROFILE_COUNT][X2V_HAL_SENSOR_BYTES];
    unsigned ready;
} X2vOwnedHalProfiles;
/* One caller-owned object per camera. Retain until process exit. */
int x2v_clone_hal_profiles(X2vOwnedHalProfiles *,const void *native_cam_info,uintptr_t hal_bias);
/* Applies a complete provided sensor record to a single profile; topology
 * index is an owned topology index, never an arbitrary public sensor enum. */
int x2v_bind_hal_sensor(X2vOwnedHalProfiles *,unsigned profile,unsigned topology,
                      const unsigned char sensor[X2V_HAL_SENSOR_BYTES]);
int x2v_hal_bitdepth(const X2vOwnedHalProfiles *,int profile,uint16_t *out);
int x2v_hal_aux58(const X2vOwnedHalProfiles *,int profile,uint32_t *out);
#endif
