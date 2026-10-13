"""Same completed-source/ordinary-file contract, only the 1MiB helper differs."""
import run_dng_replay_benchmark as runner
from dng_replay_1mib_stage import EXPECTED,ssd_stage
runner.EXPECTED=EXPECTED
runner.BINARY=ssd_stage.DEVICE_BINARY
runner.RUN_PREFIX='dng-replay-1mib'
if __name__=='__main__':raise SystemExit(runner.main())
