#!/usr/bin/env python3
"""Remove failed Longhorn Backup records that hold no data, in small batches.

Why this exists: a failing backup target left thousands of Backup objects in state "Error". Deleting such an
object normally makes Longhorn run `longhorn backup rm` against the NAS, and thousands at once overload the
nodes. A failed backup has no remote URL and size 0, so there is nothing on the NAS to remove: this script strips
the finalizer first, so only the Kubernetes object disappears and the NAS is never contacted.

Only objects that are ALL of: state Error, no remote url, size 0, not already being deleted. Completed and
Pending backups are never touched.

Dry run by default.
  python scripts/longhorn_clear_failed_backups.py                 # show what would be removed
  python scripts/longhorn_clear_failed_backups.py --apply         # remove, 100 per batch, 5 s apart
Check that the backup target is OFF (empty URL) and `pgrep -fc "longhorn backup rm"` is ~0 on every node first.
"""
import argparse
import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

NS = 'longhorn-system'


def kubectl(*args):
    return subprocess.run(['kubectl', '--request-timeout=120s', *args], capture_output=True, text=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--batch', type=int, default=100)
    parser.add_argument('--pause', type=float, default=5.0)
    args = parser.parse_args()

    target = kubectl('get', 'backuptargets.longhorn.io', 'default', '-n', NS, '-o', 'json')
    if target.returncode == 0 and json.loads(target.stdout)['spec'].get('backupTargetURL'):
        sys.exit('The default backup target still has a URL. Clear it first, or this can start NFS deletions.')

    listing = kubectl('get', 'backups.longhorn.io', '-n', NS, '-o', 'json')
    if listing.returncode != 0:
        sys.exit(listing.stderr.strip())
    items = json.loads(listing.stdout)['items']

    doomed = []
    for b in items:
        s = b.get('status') or {}
        if (s.get('state') == 'Error' and not s.get('url') and int(s.get('size') or 0) == 0
                and not b['metadata'].get('deletionTimestamp')):
            doomed.append(b['metadata']['name'])
    kept = [b['metadata']['name'] for b in items if b['metadata']['name'] not in set(doomed)]
    print(f'{len(items)} Backup objects: {len(doomed)} failed and empty (to remove), {len(kept)} left alone.')
    if not args.apply:
        print('Dry run. Nothing changed. Re-run with --apply.')
        return

    done = 0
    for i in range(0, len(doomed), args.batch):
        batch = doomed[i:i + args.batch]
        manifest = {'apiVersion': 'v1', 'kind': 'List', 'items': [
            {'apiVersion': 'longhorn.io/v1beta2', 'kind': 'Backup', 'metadata': {'name': n, 'namespace': NS}} for n in batch]}
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'batch.json'
            path.write_text(json.dumps(manifest), encoding='utf-8')
            patch = kubectl('patch', '-f', str(path), '--type=merge', '-p', '{"metadata":{"finalizers":null}}')
            delete = kubectl('delete', '-f', str(path), '--wait=false', '--ignore-not-found')
        if patch.returncode or delete.returncode:
            sys.exit(f'batch at {i} failed: {(patch.stderr or delete.stderr).strip()[:300]}')
        done += len(batch)
        print(f'  removed {done}/{len(doomed)}', flush=True)
        time.sleep(args.pause)
    print('Done.')


if __name__ == '__main__':
    main()
