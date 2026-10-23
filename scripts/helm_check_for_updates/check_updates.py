#!/usr/bin/env python3
"""Report on Helm chart updates for the ArgoCD apps in this repo, and apply them one app at a time.

Read-only by default. Nothing is committed or pushed, and nothing is ever changed without naming the app.

  check_updates.py                     table of every chart: current, latest stable, size of the jump
  check_updates.py --diff NAME         render the current and the new chart with this repo's values and
                                       list what would change (selectors, volumes, images, ports, objects)
  check_updates.py --apply NAME        set targetRevision for that app to the latest stable version
        [--to VERSION] [--force]       (or VERSION). Refuses pinned apps and risky diffs without --force.

A chart bump can change labels, selectors, mount paths or default image versions, which is how a routine
update once broke UniFi. Always run --diff first, and back up anything with data before applying.
Pins and notes live in pins.yaml next to this file.
"""
import argparse
import difflib
import hashlib
import re
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
APPS_DIR = ROOT / 'apps'
PINS_FILE = Path(__file__).with_name('pins.yaml')
NOISY = {'ClusterRole', 'ClusterRoleBinding', 'Role', 'RoleBinding', 'ServiceAccount', 'Pod', 'Job', 'PodDisruptionBudget',
         'ValidatingWebhookConfiguration', 'MutatingWebhookConfiguration', 'CSIDriver'}
PRERELEASE = re.compile(r'(alpha|beta|rc|pre|dev|snapshot)', re.I)


def run(cmd, check=True):
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if check and result.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)}\n{result.stderr.strip() or result.stdout.strip()}")
    return result


def parse_version(text):
    core = re.match(r'v?(\d+(?:\.\d+)*)', str(text))
    return tuple(int(p) for p in core.group(1).split('.')) if core else ()


def is_stable(text):
    return not PRERELEASE.search(str(text))


def jump(current, latest):
    a, b = parse_version(current), parse_version(latest)
    if not a or not b or a == b:
        return 'same' if a == b else '?'
    if b < a:
        return 'older'
    if a[:1] != b[:1]:
        return 'MAJOR'
    if a[:2] != b[:2]:
        return 'minor'
    return 'patch'


def load_pins():
    if not PINS_FILE.exists():
        return {}
    return yaml.safe_load(PINS_FILE.read_text(encoding='utf-8')) or {}


def find_apps():
    """Every Application in apps/ that has a Helm chart source."""
    found = []
    for path in sorted(APPS_DIR.rglob('*.yaml')):
        try:
            docs = [d for d in yaml.safe_load_all(path.read_text(encoding='utf-8')) if d]
        except yaml.YAMLError:
            continue                      # Helm templates (e.g. apps/external-services) are not plain YAML
        for doc in docs:
            if not isinstance(doc, dict) or doc.get('kind') != 'Application':
                continue
            sources = doc.get('spec', {}).get('sources') or []
            for src in sources:
                if 'chart' in src:
                    values = [v for v in (src.get('helm') or {}).get('valueFiles', [])]
                    found.append({
                        'name': doc['metadata']['name'],
                        'file': path,
                        'chart': src['chart'],
                        'repo': src['repoURL'],
                        'current': str(src['targetRevision']),
                        'namespace': doc['spec']['destination'].get('namespace', 'default'),
                        'value_files': [ROOT / v.replace('$values/', '') for v in values if v.startswith('$values/')],
                    })
    return found


def is_oci(app):
    return app['repo'].startswith('oci://') or app['repo'].startswith('ghcr.io')


def chart_ref(app):
    """What to pass to helm for this chart. Adds the repo under a stable alias for plain repos."""
    if is_oci(app):
        base = app['repo'] if app['repo'].startswith('oci://') else f"oci://{app['repo']}"
        return f"{base.rstrip('/')}/{app['chart']}"
    alias = 'hcu-' + hashlib.sha1(app['repo'].encode()).hexdigest()[:8]
    run(['helm', 'repo', 'add', alias, app['repo'], '--force-update'])
    return f"{alias}/{app['chart']}"


def available_versions(app, ref):
    """All versions of the chart, newest first (stable and pre-release)."""
    if is_oci(app):
        out = run(['helm', 'show', 'chart', ref]).stdout          # latest tag only
        return [yaml.safe_load(out)['version']]
    out = run(['helm', 'search', 'repo', ref, '--versions', '-o', 'json']).stdout
    versions = [e['version'] for e in yaml.safe_load(out) if e['name'] == ref]
    return sorted(versions, key=parse_version, reverse=True)


def latest_stable(versions):
    stable = [v for v in versions if is_stable(v)]
    return stable[0] if stable else None


def refresh_repos(apps):
    seen = set()
    for app in apps:
        if not is_oci(app) and app['repo'] not in seen:
            seen.add(app['repo'])
            chart_ref(app)
    if seen:
        run(['helm', 'repo', 'update'], check=False)


def report(args):
    apps = find_apps()
    pins = load_pins()
    refresh_repos(apps)
    rows = []
    for app in apps:
        pin = pins.get(app['name'], {})
        try:
            ref = chart_ref(app)
            versions = available_versions(app, ref)
            latest = latest_stable(versions) or '-'
        except RuntimeError as err:
            rows.append((app['name'], app['chart'], app['current'], '?', 'ERROR', str(err).splitlines()[-1][:60]))
            continue
        kind = jump(app['current'], latest) if latest != '-' else '?'
        notes = []
        if not is_stable(app['current']):
            notes.append('running a pre-release')
        if kind == 'older':
            notes.append('latest stable is OLDER than current')
        if pin.get('pinned'):
            notes.append('PINNED: ' + pin['reason'])
        elif pin.get('careful'):
            notes.append('careful: ' + pin['careful'])
        rows.append((app['name'], app['chart'], app['current'], latest, kind, '; '.join(notes)))

    header = ('app', 'chart', 'current', 'latest stable', 'jump', 'notes')
    widths = [max(len(str(r[i])) for r in rows + [header]) for i in range(5)]
    fmt = '  '.join(f'{{:<{w}}}' for w in widths) + '  {}'
    print(fmt.format(*header))
    for r in rows:
        print(fmt.format(*r))
    outdated = [r for r in rows if r[4] in ('patch', 'minor', 'MAJOR')]
    print(f"\n{len(outdated)} of {len(rows)} charts have a newer stable version.")
    print('Next: check_updates.py --diff <app>   (then --apply <app>)')


_KUBE_VERSION = []


def kube_version():
    """The cluster's Kubernetes version, so charts with a kubeVersion requirement render as they will in ArgoCD."""
    if not _KUBE_VERSION:
        try:
            out = yaml.safe_load(run(['kubectl', 'version', '-o', 'json']).stdout)
            _KUBE_VERSION.append(out['serverVersion']['gitVersion'].split('+')[0])
        except (RuntimeError, KeyError, OSError):
            _KUBE_VERSION.append('')
    return _KUBE_VERSION[0]


def render(app, ref, version):
    cmd = ['helm', 'template', app['name'], ref, '--version', version, '-n', app['namespace'], '--include-crds']
    if kube_version():
        cmd += ['--kube-version', kube_version()]
    for f in app['value_files']:
        cmd += ['-f', str(f)]
    out = run(cmd).stdout
    return [d for d in yaml.safe_load_all(out) if isinstance(d, dict)]


def keyed(docs):
    return {(d.get('kind'), d.get('metadata', {}).get('name')): d for d in docs}


def walk_containers(doc):
    spec = doc.get('spec', {})
    pod = spec.get('template', {}).get('spec', {}) if 'template' in spec else spec
    return pod.get('containers', []) + pod.get('initContainers', [])


def analyse(old, new):
    """Return (flags, notes): flags are changes that are dangerous or break an in-place upgrade."""
    flags, notes, quiet = [], [], {}
    o, n = keyed(old), keyed(new)
    for k in sorted(set(o) - set(n), key=str):
        notes.append(f'removed   {k[0]} {k[1]}')
    for k in sorted(set(n) - set(o), key=str):
        notes.append(f'added     {k[0]} {k[1]}')
    for k in sorted(set(o) & set(n), key=str):
        a, b = o[k], n[k]
        kind, name = k
        if a == b:
            continue
        if kind in ('Deployment', 'StatefulSet', 'DaemonSet'):
            if a['spec'].get('selector') != b['spec'].get('selector'):
                flags.append(f'{kind} {name}: spec.selector changes (immutable: the workload must be deleted and recreated)')
            if kind == 'StatefulSet' and a['spec'].get('volumeClaimTemplates') != b['spec'].get('volumeClaimTemplates'):
                flags.append(f'StatefulSet {name}: volumeClaimTemplates change (immutable)')
            old_c = {c['name']: c for c in walk_containers(a)}
            new_c = {c['name']: c for c in walk_containers(b)}
            for cn in sorted(set(old_c) & set(new_c)):
                if old_c[cn].get('image') != new_c[cn].get('image'):
                    oi, ni = old_c[cn].get('image'), new_c[cn].get('image')
                    line = f"image     {name}/{cn}: {oi} -> {ni}"
                    ot, nt = parse_version(oi.rsplit(':', 1)[-1]), parse_version(ni.rsplit(':', 1)[-1])
                    if ot and nt and ot[0] != nt[0] and oi.rsplit(':', 1)[0] == ni.rsplit(':', 1)[0]:
                        flags.append(f"{line}  <- MAJOR version of the application itself")
                    else:
                        notes.append(line)
                om = sorted((m['name'], m['mountPath']) for m in old_c[cn].get('volumeMounts', []))
                nm = sorted((m['name'], m['mountPath']) for m in new_c[cn].get('volumeMounts', []))
                if set(om) - set(nm):
                    flags.append(f'{kind} {name}/{cn}: volume mounts removed or moved {sorted(set(om) - set(nm))}')
                elif om != nm:
                    notes.append(f'mounts    {name}/{cn}: new mounts {sorted(set(nm) - set(om))}')
            if sorted(old_c) != sorted(new_c):
                notes.append(f'containers {name}: {sorted(old_c)} -> {sorted(new_c)}')
        elif kind == 'PersistentVolumeClaim' and a.get('spec') != b.get('spec'):
            flags.append(f'PersistentVolumeClaim {name}: spec changes (mostly immutable)')
        elif kind == 'Service':
            oa, nb = a.get('spec', {}), b.get('spec', {})
            if oa.get('type') != nb.get('type') or oa.get('selector') != nb.get('selector'):
                flags.append(f'Service {name}: type or selector changes ({oa.get("type")}/{oa.get("selector")} -> {nb.get("type")}/{nb.get("selector")})')
            if sorted(p.get('port') for p in oa.get('ports', [])) != sorted(p.get('port') for p in nb.get('ports', [])):
                notes.append(f'ports     Service {name} changes')
        elif kind == 'CustomResourceDefinition':
            notes.append(f'CRD       {name} changes')
        elif kind in ('Secret', 'ConfigMap'):
            notes.append(f'{kind.lower():9} {name} changes')
        elif kind in NOISY:
            quiet[kind] = quiet.get(kind, 0) + 1
        else:
            notes.append(f'changed   {kind} {name}')
    if quiet:
        notes.append('also changed (permissions and plumbing): ' + ', '.join(f'{v} {k}' for k, v in sorted(quiet.items())))
    return flags, notes


def pick_target(app, ref, to):
    versions = available_versions(app, ref)
    if to:
        if to not in versions and not is_oci(app):
            sys.exit(f'{to} is not a published version of {app["chart"]}. Latest: {versions[:5]}')
        return to
    target = latest_stable(versions)
    if not target:
        sys.exit('No stable version found.')
    return target


def find_app(name):
    for app in find_apps():
        if app['name'] == name:
            return app
    sys.exit(f'No Application named {name!r} with a Helm chart in {APPS_DIR}.')


def do_diff(name, to, write_full=True):
    app = find_app(name)
    pins = load_pins().get(name, {})
    ref = chart_ref(app)
    target = pick_target(app, ref, to)
    print(f"{app['name']}: {app['chart']} {app['current']} -> {target}  ({jump(app['current'], target)})")
    if pins:
        print('pin/note: ' + (pins.get('reason') or pins.get('careful') or ''))
    if app['current'] == target:
        print('Already on that version.')
        return [], target
    try:
        old = render(app, ref, app['current'])
        new = render(app, ref, target)
    except RuntimeError as err:
        sys.exit(f"Could not render the chart: {str(err).splitlines()[-1]}")
    flags, notes = analyse(old, new)
    print(f'\nRendered with {[str(p.relative_to(ROOT)) for p in app["value_files"]] or "no values file"}')
    print(f'{len(old)} objects before, {len(new)} after.\n')
    if flags:
        print('DANGEROUS (do not apply without a plan):')
        for f in flags:
            print('  !', f)
        print()
    print('Other changes:' if notes else 'No other structural changes.')
    for n in notes:
        print('  -', n)
    if write_full:
        out = Path(__file__).with_name(f'last-diff-{name}.txt')
        a = yaml.safe_dump_all(old, sort_keys=True).splitlines()
        b = yaml.safe_dump_all(new, sort_keys=True).splitlines()
        out.write_text('\n'.join(difflib.unified_diff(a, b, app['current'], target, lineterm='')), encoding='utf-8')
        print(f'\nFull rendered diff: {out}')
    return flags, target


def do_apply(name, to, force):
    app = find_app(name)
    pins = load_pins().get(name, {})
    if pins.get('pinned') and not force:
        sys.exit(f"{name} is pinned: {pins['reason']}\nUse --force only after reading that.")
    flags, target = do_diff(name, to, write_full=True)
    if app['current'] == target:
        return
    if flags and not force:
        sys.exit('\nRefusing to apply: the diff above has dangerous changes. Plan for them, or use --force.')
    text = app['file'].read_text(encoding='utf-8')
    pattern = re.compile(rf'(targetRevision:\s*["\']?){re.escape(app["current"])}(["\']?[ \t]*(?:#[^\r\n]*)?(?:\r?\n|$))')
    matches = pattern.findall(text)
    if len(matches) != 1:
        sys.exit(f'Expected exactly one "targetRevision: {app["current"]}" in {app["file"]}, found {len(matches)}. Edit it by hand.')
    app['file'].write_text(pattern.sub(rf'\g<1>{target}\g<2>', text, count=1), encoding='utf-8', newline='')
    print(f"\nUpdated {app['file'].relative_to(ROOT)}: {app['current']} -> {target}")
    print('Nothing was committed. Back up anything with data, then review, commit and push.')


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--diff', metavar='APP')
    parser.add_argument('--apply', metavar='APP')
    parser.add_argument('--to', metavar='VERSION')
    parser.add_argument('--force', action='store_true')
    args = parser.parse_args()
    if args.apply:
        do_apply(args.apply, args.to, args.force)
    elif args.diff:
        do_diff(args.diff, args.to)
    else:
        report(args)


if __name__ == '__main__':
    main()
