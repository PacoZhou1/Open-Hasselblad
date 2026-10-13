"""Fixed reviewed normal-clone session through the stock ownership runner."""
from pathlib import Path
import source_session_test as session


def main():
    session.CANDIDATE = Path(__file__).resolve().parents[1]/'native-video/experimental/source-session-normal-clone'
    session.MODE = 'normal-clone'
    session.RUN_PREFIX = 'source-clone'
    session.EXTRA_MARKER = 'clone.confirmed'
    return session.main()


if __name__ == '__main__':
    raise SystemExit(main())
