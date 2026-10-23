# helm_check_for_updates

Reports which Helm charts used by the ArgoCD apps have a newer version, shows what an update would change
before you make it, and edits the version for **one named app at a time**. It never commits or pushes.

Needs `helm`, `kubectl` (for the cluster's Kubernetes version) and `pip install -r requirements.txt`.

```bash
cd scripts/helm_check_for_updates
python check_updates.py                      # table of every chart: current, latest stable, size of the jump
python check_updates.py --diff vault         # render old and new chart with this repo's values and compare
python check_updates.py --apply vault        # set targetRevision to the latest stable (or --to 0.33.0)
```

## What `--diff` tells you

It renders the current and the new chart with the values file the app actually uses, then compares the objects.

- **DANGEROUS** lines are the things that break an in-place upgrade or change the application itself:
  - a Deployment, StatefulSet or DaemonSet `selector` changes (immutable: the workload has to be deleted and recreated, which is what broke UniFi);
  - StatefulSet volume claim templates or a PersistentVolumeClaim spec change;
  - a Service's type or selector changes;
  - a container's volume mount paths change (data would stop being found);
  - a container image keeps its name but changes **major version**. A chart's own version number can hide this: a Vault chart bump from 0.32 to 0.34 moves Vault itself from 1.21 to 2.0.
- **Other changes** lists added or removed objects, CRD changes, image changes and config changes.
- The full rendered diff is written to `last-diff-<app>.txt` (not committed).

`--apply` refuses if the diff has DANGEROUS lines, or if the app is pinned, unless you add `--force`.

## pins.yaml

- `pinned: true` blocks `--apply` (UniFi, chat) and shows the reason.
- `careful: ...` is a reminder shown in the report and the diff (storage, secrets, CRDs).

## Rules of thumb

1. Move **one app at a time**, read `--diff`, and check the app's release notes for anything the diff cannot show.
2. Back up anything with data first (Longhorn snapshot, `scripts/chat-backup.sh` for chat, a Consul snapshot for Vault).
3. For charts that install CRDs (cert-manager, external-secrets, longhorn), upgrade one minor version at a time.
4. The chart version is not the application version. Read the image lines.
5. Review, commit and push yourself, then watch the app in ArgoCD.

Not covered here: images that use `:latest` (homepage and the four media apps), k3s itself, ArgoCD, MetalLB and the
upgrade controller, which are not Helm chart sources in this repo.
