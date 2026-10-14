#!/usr/bin/env python3
"""CPU over a tsnap.sh window: busiest processes, then camera-service's busiest threads.
   tsnap.py out.a out.b [seconds]"""
import sys

HZ = 100


def parse(path):
    procs, threads, total = {}, {}, None
    for line in open(path):
        if line.startswith('cpu '):
            total = [int(x) for x in line.split()[1:8]]
            continue
        kind, rest = line.split(' ', 1)
        owner = None
        if kind == 'T':
            owner, rest = rest.split(' ', 1)
        tid = int(rest.split(' ', 1)[0])
        name = rest[rest.index('(') + 1:rest.rindex(')')]
        f = rest[rest.rindex(')') + 2:].split()
        ticks = (int(f[11]), int(f[12]))          # utime, stime
        (threads if kind == 'T' else procs)[(owner, tid)] = (name, ticks)
    return procs, threads, total


a, b = parse(sys.argv[1]), parse(sys.argv[2])
secs = float(sys.argv[3]) if len(sys.argv) > 3 else 20
busy = [y - x for x, y in zip(a[2], b[2])]
print('total %.0f%% of 4 cores (user %.0f sys %.0f irq %.0f)' % (
    100 * (sum(busy) - busy[3] - busy[4]) / sum(busy), 100 * (busy[0] + busy[1]) / sum(busy),
    100 * busy[2] / sum(busy), 100 * (busy[5] + busy[6]) / sum(busy)))
for title, i in (('processes', 0), ('camera-service threads', 1)):
    rows = []
    for k, (name, t1) in b[i].items():
        t0 = a[i].get(k, (name, (0, 0)))[1] if k in a[i] else None
        if t0 is None:
            continue
        u, s = t1[0] - t0[0], t1[1] - t0[1]
        if u + s:
            rows.append((u + s, u, s, k[1], name))
    rows.sort(reverse=True)
    print('\n%s (%% of one core: user+sys)' % title)
    for d, u, s, tid, name in rows[:22]:
        print('  %5.1f%%  (%4.1f + %4.1f)  %6d %s' % (100 * d / HZ / secs, 100 * u / HZ / secs, 100 * s / HZ / secs, tid, name))
