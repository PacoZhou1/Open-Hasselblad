"""Product controller: proven PRR capture, without the previous boot's cgroup."""
import shutil
from pathlib import Path

SRC = Path(__file__).resolve().parents[1] / 'source-session-isolated-two-prr-async' / 'controller.sh'
DST = Path(__file__).resolve().parent / 'controller.sh'

text = SRC.read_text()
old_boot = '''bootstrap_owner() {
 read bv br bn bb bfp bfs bfpg bd extra < "$RUN/passive.binding" || return 1
'''
new_boot = '''bootstrap_owner() {
 if [ -f "$RUN/product.mode" ]; then
  fg=$(cat "$ROOT/target.group") || return 1
  [ -n "$fg" ] && [ "$(proc_group $$)" = "$fg" ] || return 1
  [ "$(cat /proc/self/attr/current 2>/dev/null)" = "$DOMAIN" ] || return 1
  printf '%s\\n' "$fg" > "$RUN/owner.group" || return 1
  printf '%s\\n' /product > "$RUN/factory.group" || return 1
  return 0
 fi
 read bv br bn bb bfp bfs bfpg bd extra < "$RUN/passive.binding" || return 1
'''
old_guard = '''guard_ready() (
 read bv br bn bb bd extra < "$RUN/guard.binding" || exit 1
'''
new_guard = '''guard_ready() (
 if [ -f "$RUN/product.mode" ]; then return 0; fi
 read bv br bn bb bd extra < "$RUN/guard.binding" || exit 1
'''
old_seal = '''seal_guard_owners() {
 guard_ready 130 || return 1
'''
new_seal = '''seal_guard_owners() {
 if [ -f "$RUN/product.mode" ]; then
  read wp ws < "$RUN/watchdog.identity" || return 1
  alive "$wp" "$ws" || return 1
  log PRODUCT_GUARD_SEAL_SKIPPED
  return 0
 fi
 guard_ready 130 || return 1
'''
old_group = '[ "$(proc_group $$)" = "$fg" ] && [ "$fg" = /uid_0/pid_3102 ] || exit 4\n'
new_group = '[ "$(proc_group $$)" = "$fg" ] && { [ "$fg" = /uid_0/pid_3102 ] || [ -f "$RUN/product.mode" ]; } || exit 4\n'
old_stop = '''receiver_user_stop_trial() {
 sleep 2
 gate && match_service && receiver_inodes || return 1
'''
new_stop = '''receiver_user_stop_trial() {
 if [ -f "$RUN/product.mode" ]; then
  n=0
  while [ "$n" -lt 80 ] && [ ! -f /blackbox/x2v-native-20261011/rec/user-stop ]; do
   n=$((n+1)); sleep 0.1
  done
 else
  sleep 2
 fi
 gate && match_service && receiver_inodes || return 1
'''
old_chain = 'receiver_arm && receiver_user_stop_trial && receiver_frame && receiver_arm_second && receiver_user_stop_trial && receiver_frame && target_setup_evidence || exit 5\n'
new_chain = '''receiver_arm && receiver_user_stop_trial && receiver_frame && { [ -f "$RUN/product.mode" ] || { receiver_arm_second && receiver_user_stop_trial && receiver_frame; }; } && target_setup_evidence || exit 5
'''
for name, old, new in [
    ('bootstrap', old_boot, new_boot),
    ('guard', old_guard, new_guard),
    ('seal', old_seal, new_seal),
    ('group', old_group, new_group),
    ('stop', old_stop, new_stop),
    ('chain', old_chain, new_chain),
]:
    if old not in text:
        raise SystemExit('patch missing: ' + name)
    text = text.replace(old, new, 1)
DST.write_text(text)
print(DST, DST.stat().st_size)
