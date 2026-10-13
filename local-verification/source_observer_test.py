"""Fixed normal observer v4 session with device-verified independent guard."""
from pathlib import Path
import source_session_test as session

session.CANDIDATE = Path(__file__).resolve().parents[1] / 'native-video/experimental/source-session-normal-observer-v4'
session.MODE = 'normal-observer-v4'
session.RUN_PREFIX = 'source-observer'
session.EXTRA_MARKER = 'observer.confirmed'
session.INDEPENDENT_GUARD = True

if __name__ == '__main__':
    raise SystemExit(session.main())
