"""Fixed normal HAL/parser/group13 experiment; target MODE21 is absent."""
import source_receiver_test as receiver


if __name__ == '__main__':
    receiver.CANDIDATE = receiver.ROOT/'native-video/experimental/source-session-normal-graph'
    receiver.MODE = 'normal-graph'
    receiver.RUN_PREFIX = 'source-graph'
    receiver.EXPECTED_BYTES = 7824896
    receiver.RAW_NAME = 'raw-3920x986-stride7936.bin'
    raise SystemExit(receiver.main())
