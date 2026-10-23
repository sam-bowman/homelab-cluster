#!/usr/bin/env python3
"""Snapshot and back up every attached Longhorn volume, one at a time, and wait for each to finish.

Run it before anything risky (a Longhorn upgrade, a k3s upgrade). It only adds a snapshot and a backup per
volume; running data is not touched. Backups go to the default Longhorn backup target (the NAS).

Usage: python scripts/longhorn_backup_all.py [--only namespace/pvc ...] [--timeout-minutes 20]
  --only   back up just these volumes, e.g. --only unifi/unifi-pvc
Exit code 0 only if every volume backed up.
"""
import argparse
import json
import subprocess
import sys
import time
from datetime import datetime

NS = 'longhorn-system'


def kubectl(*args, stdin=None):
    return subprocess.run(['kubectl', *args], input=stdin, capture_output=True, text=True)


def get(kind, name=None):
    args = ['get', kind] + ([name] if name else []) + ['-n', NS, '-o', 'json']
    out = kubectl(*args)
    if out.returncode != 0:
        return None
    obj = json.loads(out.stdout)
    if name:
        obj.setdefault('status', {})     # a brand-new object has no status yet
    return obj


def apply(manifest):
    result = kubectl('apply', '-f', '-', stdin=json.dumps(manifest))
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())


def wait(fetch, done, bad, timeout):
    end = time.time() + timeout
    while time.time() < end:
        obj = fetch()
        if obj and bad(obj):
            return obj, 'failed'
        if obj and done(obj):
            return obj, 'ok'
        time.sleep(4)
    return fetch(), 'timeout'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--timeout-minutes', type=int, default=20)
    parser.add_argument('--only', nargs='+', metavar='NAMESPACE/PVC', help='back up only these volumes')
    args = parser.parse_args()
    timeout = args.timeout_minutes * 60
    stamp = datetime.now().strftime('%Y%m%d-%H%M%S')

    targets = get('backuptargets.longhorn.io', 'default')
    if not targets or not targets['status'].get('available'):
        sys.exit('The default backup target is not available. Fix that first.')

    volumes = get('volumes.longhorn.io')['items']
    def pvc_of(v):
        ks = v['status'].get('kubernetesStatus', {})
        return f"{ks.get('namespace', '-')}/{ks.get('pvcName', v['metadata']['name'])}"

    if args.only:
        volumes = [v for v in volumes if pvc_of(v) in args.only]
        if len(volumes) != len(args.only):
            sys.exit(f'Not every volume in --only was found: {args.only}')
    attached = [v for v in volumes if v['status'].get('state') == 'attached']
    skipped = [v for v in volumes if v['status'].get('state') != 'attached']
    print(f'{len(attached)} attached volume(s) to back up, {len(skipped)} skipped (not attached).\n')

    results = []
    for index, vol in enumerate(sorted(attached, key=lambda v: int(v['spec']['size'])), start=1):
        vname = vol['metadata']['name']
        ks = vol['status'].get('kubernetesStatus', {})
        label = f"{ks.get('namespace', '-')}/{ks.get('pvcName', vname)}"
        snap = f'backup-all-{stamp}-{index:02d}'
        started = time.time()
        print(f'[{index}/{len(attached)}] {label}', flush=True)
        try:
            apply({'apiVersion': 'longhorn.io/v1beta2', 'kind': 'Snapshot',
                   'metadata': {'name': snap, 'namespace': NS},
                   'spec': {'volume': vname, 'createSnapshot': True, 'labels': {'purpose': 'backup-all'}}})
            obj, state = wait(lambda: get('snapshots.longhorn.io', snap),
                              lambda o: o['status'].get('readyToUse') is True,
                              lambda o: bool(o['status'].get('error')), 120)
            if state != 'ok':
                raise RuntimeError(f'snapshot {state}: {(obj or {}).get("status", {}).get("error", "")}')
            apply({'apiVersion': 'longhorn.io/v1beta2', 'kind': 'Backup',
                   'metadata': {'name': snap, 'namespace': NS, 'labels': {'backup-volume': vname}},
                   'spec': {'snapshotName': snap, 'labels': {'purpose': 'backup-all'}}})
            obj, state = wait(lambda: get('backups.longhorn.io', snap),
                              lambda o: o['status'].get('state') == 'Completed',
                              lambda o: o['status'].get('state') == 'Error', timeout)
            if state != 'ok':
                raise RuntimeError(f'backup {state}: {(obj or {}).get("status", {}).get("error", "")}')
            size = int(obj['status'].get('size') or 0) / 2**20
            took = int(time.time() - started)
            print(f'      done: {size:.0f} MiB in {took}s', flush=True)
            results.append((label, 'OK', f'{size:.0f} MiB'))
        except RuntimeError as err:
            print(f'      FAILED: {err}', flush=True)
            results.append((label, 'FAILED', str(err)[:80]))

    print('\nSummary')
    for label, state, detail in results:
        print(f'  {state:7} {label:55} {detail}')
    for v in skipped:
        ks = v['status'].get('kubernetesStatus', {})
        print(f"  skipped {ks.get('namespace', '-')}/{ks.get('pvcName', v['metadata']['name'])} (state {v['status'].get('state')})")
    sys.exit(0 if all(r[1] == 'OK' for r in results) else 1)


if __name__ == '__main__':
    main()
