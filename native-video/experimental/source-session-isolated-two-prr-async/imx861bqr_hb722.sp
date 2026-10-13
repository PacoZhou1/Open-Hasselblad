{
  "stream_profile": {
    "name": "imx861bqr_sensor",
    "template": "true",
    "link_nodes": [
      {
        "id": "container_cache_link_node"
      }
    ],
    "stream_groups": [
      {
        "id": "comm_still-template-01",
        "shooter_id": "still-x2d",
        "link_nodes": [
          {
            "id": "vot_roi_process_link_node"
          },
          {
            "id": "dsp_manager_link_node"
          }
        ],
        "filters": [
          {
            "type": "reprocess",
            "id": "reprocess_fast_preview_cac_lsc",
            "style": "push"
          },
          {
            "type": "disp_eng",
            "id": "disp_eng",
            "style": "listen"
          },
          {
            "type": "disp_eng",
            "id": "disp_eng_preview",
            "style": "listen"
          },
          {
            "type": "dsp_pre_process_calib",
            "id": "dsp_pre_process_calib",
            "style": "push"
          },
          {
            "type": "dsp_fast_preview_rltm",
            "id": "dsp_fast_preview_rltm",
            "style": "push"
          },
          {
            "type": "x2d_cal",
            "id": "x2d_cal_still",
            "style": "push"
          },
          {
            "type": "isp_statistics",
            "id": "isp_statistics",
            "style": "cascade"
          },
          {
            "type": "pre_process_isp_meta_convert",
            "id": "pre_process_isp_meta_convert",
            "style": "cascade"
          },
          {
            "type": "post_process_isp_meta_convert",
            "id": "post_process_isp_meta_convert",
            "style": "cascade"
          },
          {
            "type": "isp_statistics",
            "id": "pfr_statistic_regenerate",
            "style": "cascade"
          },
          {
            "type": "stats_packer",
            "id": "fast_preview_stats_packer",
            "style": "pull"
          },
          {
            "type": "reawb",
            "id": "reawb",
            "style": "cascade"
          },
          {
            "type": "x2d_histogram",
            "id": "x2d_histogram_1",
            "style": "listen"
          },
          {
            "type": "reprocess",
            "id": "reprocess_fast_preview_1",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_jpeg_hevc_3",
            "style": "push"
          },
          {
            "type": "pp_algo",
            "id": "hiso_jpeg",
            "style": "push"
          },
          {
            "type": "pp_algo",
            "id": "hiso_hevc",
            "style": "push"
          },
          {
            "type": "pp_algo",
            "id": "hiso_gain_map",
            "style": "push"
          },
          {
            "type": "dsp_deconv_blend",
            "id": "dsp_deconv_blend_jpeg",
            "style": "pull"
          },
          {
            "type": "dsp_deconv_blend",
            "id": "dsp_deconv_blend_hevc",
            "style": "pull"
          },
          {
            "type": "packer",
            "id": "packer_1",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_dewarp_jpg",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_dewarp_hevc",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_fast_preview",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_jpeg",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_hevc",
            "style": "push"
          },
          {
            "type": "ienc",
            "id": "ienc_jls",
            "style": "pull"
          },
          {
            "type": "ienc",
            "id": "ienc_jpeg",
            "style": "push"
          },
          {
            "type": "ienc",
            "id": "ienc_hevc",
            "style": "push"
          },
          {
            "type": "ienc",
            "id": "ienc_gain_map_hevc",
            "style": "push"
          },
          {
            "type": "ienc",
            "id": "ienc_gain_map_jpeg",
            "style": "push"
          },
          {
            "type": "ienc",
            "id": "ienc_gain_map_thumbnail",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_gain_map",
            "style": "push"
          },
          {
            "type": "async_mctf",
            "id": "mctf",
            "style": "push"
          },
          {
            "type": "venc",
            "id": "venc_1",
            "style": "push"
          },
          {
            "type": "rtp_eng",
            "id": "rtp_eng_1",
            "style": "listen"
          },
          {
            "type": "venc",
            "id": "venc_3",
            "style": "push"
          },
          {
            "type": "rtp_eng",
            "id": "rtp_eng_2",
            "style": "listen"
          },
          {
            "type": "shadow",
            "id": "shadow_liveview_3",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_liveview_4",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_liveview_1",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_ml",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_histogram",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_parsing",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_nnpd",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_mee",
            "style": "pull"
          },
          {
            "type": "cnn_parsing_eng",
            "id": "cnn_parsing_eng",
            "style": "listen"
          },
          {
            "type": "observer",
            "id": "dsh_observer",
            "style": "listen"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_jpeg",
            "style": "push"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_hevc",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_raw_1",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_raw_2",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_jpeg_hevc_1_1",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_jpeg_hevc_1_2",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_jpeg_hevc_2_1",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_jpeg_hevc_2_2",
            "style": "push"
          },
          {
            "type": "async_dsp_rgrg",
            "id": "async_dsp_rgrg",
            "style": "push"
          },
          {
            "type": "cdaf",
            "id": "cdaf",
            "style": "listen"
          },
          {
            "type": "nnpd",
            "id": "nnpd",
            "style": "listen"
          },
          {
            "type": "af_dump_eng",
            "id": "af_dump_eng",
            "style": "listen"
          },
          {
            "type": "venc",
            "id": "venc_2",
            "style": "pull"
          },
          {
            "type": "streaming_mode_convert",
            "id": "streaming_mode_convert_1",
            "style": "cascade"
          },
          {
            "type": "shadow",
            "id": "shadow_liveview_2",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_af_dump",
            "style": "pull"
          },
          {
            "type": "streaming_mode_convert",
            "id": "streaming_mode_convert_2",
            "style": "cascade"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_jpeg_thumb_nail",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_hevc_thumb_nail",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_liveview",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_liveview",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_still_jpg",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_still_jpg",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_still_hevc",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_still_hevc",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_fast_preview",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_fast_preview",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_raw_thumb",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_raw_thumb",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_still_gain_map",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_still_gain_map",
            "style": "push"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_pyra_gain_map_thumbnail",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_still_gdc_gain_map",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_raw_thumb_nail",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_still_gdc_fast_preview",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_gain_map_thumbnail",
            "style": "push"
          },
          {
            "type": "liveview_sbpc",
            "id": "liveview_sbpc",
            "style": "push"
          },
          {
            "type": "state_notify",
            "id": "state_notify_stats_process_raw",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_fast_preview_cac_lsc",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_raw_thumbnail_1",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_raw_thumbnail_2",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_jpeg_hevc_calibrated_raw_1_2",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_jpeg_hevc_calibrated_raw_2_2",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_jpeg_hevc_calibrated_raw_1_1",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_jpeg_hevc_calibrated_raw_2_1",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_jpeg_hevc_low_noise_raw",
            "style": "notify"
          },
          {
            "type": "state_notify",
            "id": "state_notify_fast_preview_raw_to_yuv",
            "style": "notify"
          },
          {
            "type": "liveview_mee",
            "id": "liveview_mee",
            "style": "listen"
          },
          {
            "type": "reprocess",
            "id": "reprocess_temp_frame",
            "style": "push"
          },
          {
            "type": "state_notify",
            "id": "state_notify_temp_frame",
            "style": "notify"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_temp_frame",
            "style": "push"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_dewarp_temp_frame",
            "style": "push"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_still_temp_frame",
            "style": "push"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_still_temp_frame",
            "style": "pull"
          }
        ],
        "streams": [
          {
            "id": "liveview_rout0",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "high",
            "sink_filters": [
              {
                "filter_id": "shadow_liveview_3",
                "port_index": 0
              },
              {
                "filter_id": "shadow_liveview_4",
                "port_index": 0
              }
            ]
          },
          {
            "id": "cdaf_raw_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "high",
            "source_filter": {
              "filter_id": "shadow_liveview_3",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "cdaf",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_raw_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "flag": [
              "DCAM_STREAM_FLAG_NOT_USE_PARENT_STREAM_PARAM"
            ],
            "source_filter": {
              "filter_id": "shadow_liveview_4",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "liveview_sbpc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_sout1",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "sink_filters": [
              {
                "filter_id": "liveview_sbpc",
                "port_index": 1
              }
            ]
          },
          {
            "id": "liveview_after_sbpc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "liveview_sbpc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "gdc_calc_liveview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_after_gdc_calc",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "gdc_calc_liveview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_liveview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_after_gdc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "dewarp_liveview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "mctf",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_after_mctf",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "mctf",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "shadow_liveview_1",
                "port_index": 0
              },
              {
                "filter_id": "shadow_liveview_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_NOT_USE_PARENT_STREAM_PARAM"
            ],
            "source_filter": {
              "filter_id": "shadow_liveview_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "disp_eng",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_rtp",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "shadow_liveview_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "streaming_mode_convert_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "normal_liveview_before_venc",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "sink_filters": [
              {
                "filter_id": "venc_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "normal_liveview_after_venc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "venc_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "rtp_eng_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "zoom_in_liveview_before_venc",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "sink_filters": [
              {
                "filter_id": "venc_3",
                "port_index": 0
              }
            ]
          },
          {
            "id": "zoom_in_liveview_after_venc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "venc_3",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "rtp_eng_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_sout2",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE"
            ],
            "sink_filters": [
              {
                "filter_id": "shadow_ml",
                "port_index": 0
              },
              {
                "filter_id": "shadow_histogram",
                "port_index": 0
              },
              {
                "filter_id": "shadow_parsing",
                "port_index": 0
              },
              {
                "filter_id": "shadow_nnpd",
                "port_index": 0
              },
              {
                "filter_id": "shadow_mee",
                "port_index": 0
              },
              {
                "filter_id": "shadow_af_dump",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_histogram",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "shadow_histogram",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "x2d_histogram_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_parsing",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "shadow_parsing",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "cnn_parsing_eng",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_nnpd",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "shadow_nnpd",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "nnpd",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_mee",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "shadow_mee",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "liveview_mee",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_ml",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "shadow_ml",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dsh_observer",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_encoded_2",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "source_filter": {
              "filter_id": "shadow_af_dump",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "streaming_mode_convert_2",
                "port_index": 0
              },
              {
                "filter_id": "venc_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_dump_af",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "venc_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "af_dump_eng",
                "port_index": 0
              }
            ]
          },
          {
            "id": "root_bayer_raw_bout",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
            "priority": "normal",
            "no_check_frame_continous": "true",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ]
          },
          {
            "id": "root_bayer_raw_rout",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
            "priority": "normal",
            "no_check_frame_continous": "true",
            "line_sync_connection": "ROUT:DSP",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ]
          },
          {
            "id": "still_calib_raw_for_jpeg_hevc_relay_1_1",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "reprocess_jpeg_hevc_1_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_calib_raw_for_jpeg_hevc_relay_1_2",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "reprocess_jpeg_hevc_1_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_calib_raw_for_jpeg_hevc_relay_2_1",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "reprocess_jpeg_hevc_2_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_calib_raw_for_jpeg_hevc_relay_2_2",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "reprocess_jpeg_hevc_2_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_after_dbpc_rdns",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "reprocess_jpeg_hevc_1_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_jpeg_hevc_calibrated_raw_1_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "cap_pre_dsp_rgrg_1",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_jpeg_hevc_1_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_jpeg_hevc_calibrated_raw_1_2",
                "port_index": 0
              },
              {
                "filter_id": "async_dsp_rgrg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_after_dbpc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "reprocess_jpeg_hevc_2_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_jpeg_hevc_calibrated_raw_2_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "cap_pre_dsp_rgrg_2",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_jpeg_hevc_2_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_jpeg_hevc_calibrated_raw_2_2",
                "port_index": 0
              },
              {
                "filter_id": "async_dsp_rgrg",
                "port_index": 1
              }
            ]
          },
          {
            "id": "still_low_noise_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "async_dsp_rgrg",
              "port_index": 0
            }
          },
          {
            "id": "still_low_noise_raw_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "post_process_isp_meta_convert",
                "port_index": 0
              },
              {
                "filter_id": "reprocess_jpeg_hevc_3",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_grain_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "async_dsp_rgrg",
              "port_index": 1
            },
            "sink_filters": [
              {
                "filter_id": "dsp_deconv_blend_jpeg",
                "port_index": 1
              },
              {
                "filter_id": "dsp_deconv_blend_hevc",
                "port_index": 1
              }
            ]
          },
          {
            "id": "still_gain_map_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM"
            ],
            "source_filter": {
              "filter_id": "async_dsp_rgrg",
              "port_index": 2
            }
          },
          {
            "id": "still_gain_map_yuv_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "hiso_gain_map",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gain_map_after_hiso",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "hiso_gain_map",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "gdc_calc_still_gain_map",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_shadow_gain_map",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "gdc_calc_still_gain_map",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_still_gain_map",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_gain_map",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "dewarp_still_gain_map",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_still_gdc_gain_map",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_gain_map_frame_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "frame_adjust_still_gdc_gain_map",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_pyra_gain_map_thumbnail",
                "port_index": 0
              },
              {
                "filter_id": "frame_adjust_gain_map",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gain_map_yuv_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_gain_map",
              "port_index": 0
            }
          },
          {
            "id": "still_gain_map_thumbnail_after_pyra",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "dewarp_pyra_gain_map_thumbnail",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_gain_map_thumbnail",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gain_map_thumbnail_after_frame_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "frame_adjust_gain_map_thumbnail",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "ienc_gain_map_thumbnail",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gain_map_thumbnail_compressed",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_gain_map_thumbnail",
              "port_index": 0
            }
          },
          {
            "id": "gain_map_before_compressed_hevc_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "ienc_gain_map_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gain_map_compressed_hevc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_gain_map_hevc",
              "port_index": 0
            }
          },
          {
            "id": "gain_map_before_compressed_jpeg_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "ienc_gain_map_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gain_map_compressed_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_gain_map_jpeg",
              "port_index": 0
            }
          },
          {
            "id": "still_pre_x2d_calibration",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "x2d_cal_still",
                "port_index": 0
              }
            ]
          },
          {
            "id": "fast_preview_bayer_raw",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "dsp_pre_process_calib",
                "port_index": 0
              }
            ]
          },
          {
            "id": "stats_process_raw_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "sink_filters": [
              {
                "filter_id": "reawb",
                "port_index": 0
              },
              {
                "filter_id": "isp_statistics",
                "port_index": 0
              },
              {
                "filter_id": "state_notify_stats_process_raw",
                "port_index": 0
              },
              {
                "filter_id": "fast_preview_stats_packer",
                "port_index": 0
              }
            ]
          },
          {
            "id": "stats_process_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dsp_pre_process_calib",
              "port_index": 0
            }
          },
          {
            "id": "fast_preview_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dsp_pre_process_calib",
              "port_index": 1
            },
            "sink_filters": [
              {
                "filter_id": "fast_preview_stats_packer",
                "port_index": 1
              }
            ]
          },
          {
            "id": "fast_preview_packed_stats_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "fast_preview_stats_packer",
              "port_index": 0
            }
          },
          {
            "id": "fast_preview_cac_lsc_raw_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "sink_filters": [
              {
                "filter_id": "reprocess_fast_preview_cac_lsc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "fast_preview_cac_lsc_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_fast_preview_cac_lsc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_fast_preview_cac_lsc",
                "port_index": 0
              },
              {
                "filter_id": "dsp_fast_preview_rltm",
                "port_index": 0
              }
            ]
          },
          {
            "id": "fast_preview_rltm_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dsp_fast_preview_rltm",
              "port_index": 0
            }
          },
          {
            "id": "fast_preview_rltm_raw_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "sink_filters": [
              {
                "filter_id": "pre_process_isp_meta_convert",
                "port_index": 0
              },
              {
                "filter_id": "pfr_statistic_regenerate",
                "port_index": 0
              },
              {
                "filter_id": "reprocess_fast_preview_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_calibrated_small_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "x2d_cal_still",
              "port_index": 0
            }
          },
          {
            "id": "still_raw_thumbnail_relay_1",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "reprocess_raw_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_raw_thumbnail_relay_2",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "reprocess_raw_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_raw_thumb_nail_after_rerpocess_1",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "reprocess_raw_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_raw_thumbnail_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_raw_thumb_nail_after_rerpocess_2",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "reprocess_raw_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_raw_thumbnail_2",
                "port_index": 0
              },
              {
                "filter_id": "gdc_calc_raw_thumb",
                "port_index": 0
              }
            ]
          },
          {
            "id": "raw_thumb_gdc_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "gdc_calc_raw_thumb",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_raw_thumb",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_raw_thumbnail_with_padding",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "source_filter": {
              "filter_id": "dewarp_raw_thumb",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_raw_thumb_nail",
                "port_index": 0
              }
            ]
          },
          {
            "id": "pre_adjust_fast_preview_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_fast_preview_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_fast_preview_raw_to_yuv",
                "port_index": 0
              },
              {
                "filter_id": "gdc_calc_fast_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "fast_preview_gdc_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "gdc_calc_fast_preview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_fast_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_fast_preview",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "dewarp_fast_preview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_still_gdc_fast_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_fast_preview_frame_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "frame_adjust_still_gdc_fast_preview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_fast_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "raw_thumb_nail_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_raw_thumb_nail",
              "port_index": 0
            }
          },
          {
            "id": "fast_preview_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_fast_preview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "disp_eng_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_calibrated_big_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "x2d_cal_still",
              "port_index": 1
            }
          },
          {
            "id": "still_before_jls_raw_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "sink_filters": [
              {
                "filter_id": "ienc_jls",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_jls_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_jls",
              "port_index": 0
            }
          },
          {
            "id": "still_fullsize_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_jpeg_hevc_3",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_jpeg_hevc_low_noise_raw",
                "port_index": 0
              },
              {
                "filter_id": "hiso_jpeg",
                "port_index": 0
              },
              {
                "filter_id": "hiso_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_hiso_yuv_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "hiso_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dsp_deconv_blend_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_deconv_blend_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dsp_deconv_blend_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "gdc_calc_still_jpg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_shadow_1",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "gdc_calc_still_jpg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_still_jpg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dewarp_still_jpg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_dewarp_jpg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_jpeg_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_dewarp_jpg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_jpeg",
                "port_index": 0
              },
              {
                "filter_id": "dewarp_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_pre_ienc_yuv_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "ienc_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "pre_adjust_jpeg_thumb_nail_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dewarp_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_jpeg_thumb_nail",
                "port_index": 0
              }
            ]
          },
          {
            "id": "jpeg_thumb_nail_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_jpeg_thumb_nail",
              "port_index": 0
            }
          },
          {
            "id": "jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_jpeg",
              "port_index": 0
            }
          },
          {
            "id": "still_hiso_yuv_hevc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND",
              "DCAM_STREAM_FLAG_ZERO_FRAME_BUFFER_ON_INIT"
            ],
            "source_filter": {
              "filter_id": "hiso_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dsp_deconv_blend_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_deconv_blend_hevc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dsp_deconv_blend_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "gdc_calc_still_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_shadow_2",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "gdc_calc_still_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_still_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_hevc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dewarp_still_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_dewarp_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_hevc_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_dewarp_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_hevc",
                "port_index": 0
              },
              {
                "filter_id": "dewarp_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_pre_ienc_yuv_hevc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "ienc_hevc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "pre_adjust_hevc_thumb_nail_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dewarp_hevc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_hevc_thumb_nail",
                "port_index": 0
              }
            ]
          },
          {
            "id": "hevc_thumb_nail_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_hevc_thumb_nail",
              "port_index": 0
            }
          },
          {
            "id": "hevc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "lowest",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_hevc",
              "port_index": 0
            }
          },
          {
            "id": "still_before_temp_frame_raw_relay",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "sink_filters": [
              {
                "filter_id": "reprocess_temp_frame",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_temp_frame_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "reprocess_temp_frame",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "state_notify_temp_frame",
                "port_index": 0
              },
              {
                "filter_id": "gdc_calc_still_temp_frame",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_temp_frame_gdc_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "gdc_calc_still_temp_frame",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_still_temp_frame",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_temp_frame",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "source_filter": {
              "filter_id": "dewarp_still_temp_frame",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_dewarp_temp_frame",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_gdc_temp_frame_adjust",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM"
            ],
            "priority": "low",
            "source_filter": {
              "filter_id": "frame_adjust_dewarp_temp_frame",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_temp_frame",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_temp_frame_after_crop",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "low",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND",
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_temp_frame",
              "port_index": 0
            }
          }
        ]
      },
      {
        "id": "f2f-liveview-template",
        "shooter_id": "raw-reprocess",
        "filters": [
          {
            "type": "reprocess",
            "id": "reprocess_1",
            "style": "push"
          },
          {
            "type": "disp_eng",
            "id": "disp_eng",
            "style": "listen"
          }
        ],
        "streams": [
          {
            "id": "repeating_in",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "reprocess_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "disp_eng",
                "port_index": 0
              }
            ]
          }
        ]
      },
      {
        "id": "comm_still-template-cht",
        "shooter_id": "still-comm",
        "link_nodes": [
          {
            "id": "dsp_manager_link_node"
          }
        ],
        "filters": [
          {
            "type": "disp_eng",
            "id": "disp_eng_liveview",
            "style": "listen"
          },
          {
            "type": "disp_eng",
            "id": "disp_eng_preview",
            "style": "listen"
          },
          {
            "type": "x2d_cal",
            "id": "x2d_cal_1",
            "style": "push"
          },
          {
            "type": "isp_statistics",
            "id": "isp_statistics_1",
            "style": "cascade"
          },
          {
            "type": "stats_packer",
            "id": "stats_packer",
            "style": "pull"
          },
          {
            "type": "x2d_histogram",
            "id": "x2d_histogram",
            "style": "listen"
          },
          {
            "type": "reprocess",
            "id": "reprocess_1",
            "style": "push"
          },
          {
            "type": "pp_algo",
            "id": "rdns_grain",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_2",
            "style": "push"
          },
          {
            "type": "pp_algo",
            "id": "hiso_jpeg",
            "style": "push"
          },
          {
            "type": "dsp_deconv_blend",
            "id": "dsp_deconv_blend_jpeg",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_preview",
            "style": "pull"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_jpeg",
            "style": "pull"
          },
          {
            "type": "ienc",
            "id": "ienc_jpeg",
            "style": "pull"
          },
          {
            "type": "async_mctf",
            "id": "mctf",
            "style": "push"
          },
          {
            "type": "venc",
            "id": "liveview_venc",
            "style": "pull"
          },
          {
            "type": "rtp_eng",
            "id": "rtp_eng_1",
            "style": "listen"
          },
          {
            "type": "shadow",
            "id": "shadow_1",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_2",
            "style": "pull"
          },
          {
            "type": "packer",
            "id": "packer_jpeg",
            "style": "pull"
          },
          {
            "type": "packer",
            "id": "packer_raw",
            "style": "pull"
          },
          {
            "type": "nail",
            "id": "thumb_nail_jpeg",
            "style": "push"
          },
          {
            "type": "nail",
            "id": "screen_nail_jpeg",
            "style": "push"
          },
          {
            "type": "dng_md_packer",
            "id": "dng_md",
            "style": "cascade"
          },
          {
            "type": "shadow",
            "id": "shadow_ml",
            "style": "pull"
          },
          {
            "type": "nnpd",
            "id": "nnpd",
            "style": "listen"
          },
          {
            "type": "shadow",
            "id": "shadow_histogram",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_parsing",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_nnpd",
            "style": "pull"
          },
          {
            "type": "shadow",
            "id": "shadow_mee",
            "style": "pull"
          },
          {
            "type": "cnn_parsing_eng",
            "id": "cnn_parsing_eng",
            "style": "listen"
          },
          {
            "type": "observer",
            "id": "dsh_observer",
            "style": "listen"
          },
          {
            "type": "adjust",
            "id": "frame_adjust_liveview",
            "style": "pull"
          },
          {
            "type": "cdaf",
            "id": "cdaf_1",
            "style": "listen"
          },
          {
            "type": "liveview_mee",
            "id": "liveview_mee",
            "style": "listen"
          }
        ],
        "streams": [
          {
            "id": "liveview_bout0",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 0,
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "frame_adjust_liveview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_simulate_roi",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 0,
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_liveview",
              "port_index": 0
            }
          },
          {
            "id": "liveview_rout0",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "vmem_flag": 0,
            "sink_filters": [
              {
                "filter_id": "cdaf_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_sout1",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 0,
            "sink_filters": [
              {
                "filter_id": "mctf",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_mctf",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 0,
            "source_filter": {
              "filter_id": "mctf",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "shadow_1",
                "port_index": 0
              },
              {
                "filter_id": "liveview_venc",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "source_filter": {
              "filter_id": "shadow_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "disp_eng_liveview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_encoded",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_VIDEO",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "source_filter": {
              "filter_id": "liveview_venc",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "rtp_eng_1",
                "port_index": 0
              }
            ],
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ]
          },
          {
            "id": "liveview_sout2",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 17,
            "priority": "normal",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE"
            ],
            "sink_filters": [
              {
                "filter_id": "shadow_ml",
                "port_index": 0
              },
              {
                "filter_id": "shadow_histogram",
                "port_index": 0
              },
              {
                "filter_id": "shadow_parsing",
                "port_index": 0
              },
              {
                "filter_id": "shadow_nnpd",
                "port_index": 0
              },
              {
                "filter_id": "shadow_mee",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_histogram",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "source_filter": {
              "filter_id": "shadow_histogram",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "x2d_histogram",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_parsing",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "source_filter": {
              "filter_id": "shadow_parsing",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "cnn_parsing_eng",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_nnpd",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "source_filter": {
              "filter_id": "shadow_nnpd",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "nnpd",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_mee",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "source_filter": {
              "filter_id": "shadow_mee",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "liveview_mee",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_ml",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "priority": "normal",
            "source_filter": {
              "filter_id": "shadow_ml",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dsh_observer",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_shoot",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ]
          },
          {
            "id": "cap_bayer_raw",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "x2d_cal_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "fast_preview_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "x2d_cal_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "isp_statistics_1",
                "port_index": 0
              },
              {
                "filter_id": "reprocess_1",
                "port_index": 0
              },
              {
                "filter_id": "stats_packer",
                "port_index": 0
              }
            ]
          },
          {
            "id": "pre_adjust_fast_preview_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "fast_preview_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_preview",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "disp_eng_preview",
                "port_index": 0
              }
            ]
          },
          {
            "id": "cap_calibrated_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "x2d_cal_1",
              "port_index": 1
            },
            "sink_filters": [
              {
                "filter_id": "rdns_grain",
                "port_index": 0
              },
              {
                "filter_id": "shadow_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "cap_low_noise_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "rdns_grain",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "stats_packer",
                "port_index": 1
              }
            ]
          },
          {
            "id": "cap_grain_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "rdns_grain",
              "port_index": 1
            },
            "sink_filters": [
              {
                "filter_id": "dsp_deconv_blend_jpeg",
                "port_index": 1
              }
            ]
          },
          {
            "id": "cap_packed_stats_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "stats_packer",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "reprocess_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_fullsize_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "hiso_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "still_hiso_yuv_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "hiso_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dsp_deconv_blend_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "pre_adjust_yuv_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dsp_deconv_blend_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "frame_adjust_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "pre_ienc_yuv_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_NO_ALLOC_VMEM",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "frame_adjust_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "thumb_nail_jpeg",
                "port_index": 0
              },
              {
                "filter_id": "screen_nail_jpeg",
                "port_index": 0
              },
              {
                "filter_id": "ienc_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "ienc_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "packer_jpeg",
                "port_index": 0
              }
            ]
          },
          {
            "id": "thumb_nail_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "thumb_nail_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "packer_jpeg",
                "port_index": 2
              },
              {
                "filter_id": "packer_raw",
                "port_index": 2
              }
            ]
          },
          {
            "id": "screen_nail_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "screen_nail_jpeg",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "packer_jpeg",
                "port_index": 1
              },
              {
                "filter_id": "packer_raw",
                "port_index": 1
              }
            ]
          },
          {
            "id": "package_jpeg",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "packer_jpeg",
              "port_index": 0
            }
          },
          {
            "id": "raw_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "shadow_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dng_md",
                "port_index": 0
              },
              {
                "filter_id": "packer_raw",
                "port_index": 0
              }
            ]
          },
          {
            "id": "package_raw",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "packer_raw",
              "port_index": 0
            }
          }
        ]
      },
      {
        "id": "raw_playback-template",
        "shooter_id": "raw-reprocess",
        "filters": [
          {
            "type": "reprocess",
            "id": "reprocess_1",
            "style": "push"
          },
          {
            "type": "reprocess",
            "id": "reprocess_2",
            "style": "push"
          },
          {
            "type": "pp_algo",
            "id": "hiso_1",
            "style": "push"
          },
          {
            "type": "meta_convert",
            "id": "meta_convert",
            "style": "cascade"
          },
          {
            "type": "gdc_calc",
            "id": "gdc_calc_playback",
            "style": "pull"
          },
          {
            "type": "async_dewarp",
            "id": "dewarp_playback",
            "style": "push"
          }
        ],
        "streams": [
          {
            "id": "perrequest_in",
            "type": "DCAM_STREAM_TYPE_RELAY",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "sink_filters": [
              {
                "filter_id": "meta_convert",
                "port_index": 0
              },
              {
                "filter_id": "reprocess_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "reprocess_after_dbpc_rdns",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "reprocess_2",
                "port_index": 0
              }
            ]
          },
          {
            "id": "reprocess_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "reprocess_2",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "hiso_1",
                "port_index": 0
              }
            ]
          },
          {
            "id": "hiso_yuv",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "hiso_1",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "gdc_calc_playback",
                "port_index": 0
              }
            ]
          },
          {
            "id": "reprocess_gdc_shadow",
            "type": "DCAM_STREAM_TYPE_SHADOW",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "gdc_calc_playback",
              "port_index": 0
            },
            "sink_filters": [
              {
                "filter_id": "dewarp_playback",
                "port_index": 0
              }
            ]
          },
          {
            "id": "reprocess_gdc",
            "type": "DCAM_STREAM_TYPE_FILTER",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "flag": [
              "DCAM_STREAM_FLAG_VMEM_FULL_LIFE_CYCLE",
              "DCAM_STREAM_FLAG_ON_DEMAND"
            ],
            "source_filter": {
              "filter_id": "dewarp_playback",
              "port_index": 0
            }
          }
        ]
      },
      {
        "id": "bout_only_template",
        "shooter_id": "still-x2d",
        "filters": [
          {
            "type": "disp_eng",
            "id": "disp_eng",
            "style": "listen"
          }
        ],
        "streams": [
          {
            "id": "liveview",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 0,
            "sink_filters": [
              {
                "filter_id": "disp_eng",
                "port_index": 0
              }
            ]
          },
          {
            "id": "root_bayer_raw_bout",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_STILL",
            "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST"
          }
        ]
      },
      {
        "id": "normal_liveview_calib-template",
        "shooter_id": "still-general",
        "filters": [
          {
            "type": "disp_eng",
            "id": "color_null",
            "style": "listen"
          },
          {
            "type": "disp_eng",
            "id": "disp_null",
            "style": "listen"
          }
        ],
        "streams": [
          {
            "id": "liveview",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "sink_filters": [
              {
                "filter_id": "color_null",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_raw",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "sink_filters": [
              {
                "filter_id": "disp_null",
                "port_index": 0
              }
            ]
          }
        ]
      },
      {
        "id": "zoom_in_liveview_calib-template",
        "shooter_id": "still-general",
        "filters": [
          {
            "type": "disp_eng",
            "id": "disp_eng",
            "style": "listen"
          },
          {
            "type": "disp_eng",
            "id": "disp_null",
            "style": "listen"
          }
        ],
        "streams": [
          {
            "id": "liveview",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "vmem_flag": 0,
            "sink_filters": [
              {
                "filter_id": "disp_eng",
                "port_index": 0
              }
            ]
          },
          {
            "id": "liveview_raw",
            "type": "DCAM_STREAM_TYPE_COMMON",
            "usage": "DCAM_STREAM_USAGE_LIVEVIEW",
            "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",
            "sink_filters": [
              {
                "filter_id": "disp_null",
                "port_index": 0
              }
            ]
          }
        ]
      }
    ]
  }
}
