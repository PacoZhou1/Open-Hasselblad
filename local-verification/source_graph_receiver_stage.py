"""Fixed companion group13 RAW receiver stage; no sensor execution."""
import source_graph_stage as stage


if __name__ == '__main__':
    stage.ARTIFACT = 'graph_receiver/build/libx2v_group13_receiver.OFF.so'
    stage.EXPECTED = '4c263dee641c9cf9483339eefd55fe7066d788586fb4e184d42a4c65f3621961'
    stage.DESTINATION = '/system/lib64/libx2v_group13_receiver_20261012a.so'
    stage.PREFIX = 'source-g13rx-stage'
    raise SystemExit(stage.main())
