"""Fixed diagnostic receiver and revised cancellation/recovery controller."""
import source_receiver_test as receiver


if __name__ == '__main__':
    receiver.CANDIDATE = receiver.ROOT/'native-video/experimental/source-session-normal-receiver-b'
    receiver.MODE = 'normal-receiver'
    receiver.RUN_PREFIX = 'source-rxb'
    raise SystemExit(receiver.main())
