"""Fixed v6 protocol normal carrier one-frame receiver with independent guard."""
from pathlib import Path
import source_receiver_test as receiver

receiver.CANDIDATE = Path(__file__).resolve().parents[1] / 'native-video/experimental/source-session-normal-carrier-v6'
receiver.MODE = 'normal-carrier-v6'
receiver.RUN_PREFIX = 'source-carrier6'
receiver.session.INDEPENDENT_GUARD = True

if __name__ == '__main__':
    raise SystemExit(receiver.main())
