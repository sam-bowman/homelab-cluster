# Moving chat from a hand-installed Helm release to ArgoCD

The `chat` namespace was installed with `helm install` from another project.
This moves it under ArgoCD **in place**: the Deployments, Services, Ingresses,
Certificates and the two volumes (Postgres 10 Gi, uploads 5 Gi) are adopted, not
recreated, so no data is touched.

Delete this file once the migration is finished.

## What is already prepared in this repo

| File | Purpose |
|---|---|
| `apps/utility/app-chat.yaml` | The Application. Chart `0.18.0` from `oci://ghcr.io/sam-bowman/charts`. **Manual sync, no pruning, no finalizer**, so nothing changes until you sync and deleting the app can never delete the volumes. |
| `values.yaml` (this folder) | The non-secret values from the live release. Secrets are replaced by `existingSecret` references to the Secrets that already exist. |
| `argocd/argocd/repos.yaml` | Registers the OCI chart registry with ArgoCD. |
| `scripts/chat-backup.sh` | Backup of the release, secrets, both volumes and the database. |

## Checked in advance

I rendered chart 0.18.0 with `values.yaml` and compared it with the stored Helm
manifest of the live release. Of 17 objects, **16 are identical**. The only
differences:

- The three Secrets exist only in the live release. That is intended: the chart no longer renders them, and they are left alone.
- The `livekit` Deployment has a different `checksum/config` pod annotation (the
  hash covers the LiveKit secret, which is no longer in the values). **The voice pod restarts once**
  when you first sync, ending calls in progress. Pick a quiet moment.
- Helm's test pod (`test-connection`) appears in `helm template` output. ArgoCD does not run Helm test hooks.

I also compared `values.yaml` with `.run/personal-values.yaml` in the chat app repo (the file `upgrade-chat.ps1` deploys with).
They match key for key; the only differences are the secrets, which live in `.run/personal-secrets.yaml` and are not in git.

`voice.apiKey` is in `values.yaml`. It is the public half of the LiveKit
credential (the secret half stays in the cluster). Rotate it later if you want it out of git.

## Steps

1. **Back up.** Run `bash scripts/chat-backup.sh`. Check it finishes and the files look right.
2. **Push** this repo. ArgoCD creates the `chat` Application and registers the registry. Nothing is deployed yet because sync is manual.
3. **Check the diff.** In the ArgoCD UI, or:
   ```bash
   argocd app diff chat --grpc-web
   ```
   Expect only ownership labels/annotations, plus the livekit checksum. Anything that touches a pod template other than that: stop and ask.
4. **Sync once, by hand**, server-side apply on (already set). ArgoCD adopts the live objects. In the UI: `chat` > Sync. Watch the pods:
   ```bash
   kubectl get pods -n chat -w
   ```
   Only the livekit pod should restart.
5. **Verify** chat.bowmans.site loads, you can log in, an old message and an old upload are still there, and a voice call connects.
6. **Retire Helm's record.** Only after step 5. This deletes Helm's *bookkeeping secrets*, not the app:
   ```bash
   kubectl delete secret -n chat -l owner=helm,name=chat
   ```
   Never run `helm uninstall chat` or `helm upgrade chat` from now on. Releases happen by changing `targetRevision` in `apps/utility/app-chat.yaml`.
7. **Stop using `.run/upgrade-chat.ps1` for this release.** Once step 6 is done it finds no Helm release and stops. Between step 4 and step 6 it would still run `helm upgrade`, which fights ArgoCD, so do not run it then either. Upgrades now work as described below.
8. **Later, optional follow-ups**, each as its own change:
   - Move the three Secrets into Vault with External Secrets (`creationPolicy: Merge`, same names), so they can be rebuilt from Vault.
   - Add resource requests to the server, client, redis, postgres and livekit.
   - Turn on automated sync (without prune) once you trust it.

## If something looks wrong

- **Before step 4** nothing in the cluster has changed. Delete the `chat` Application (no finalizer, so resources stay) and carry on with Helm.
- **After step 4** the live objects are unchanged apart from labels. To go back, `helm upgrade chat ...` from the other project still works until you complete step 6.
- **Data:** restore from the Longhorn snapshots `chat-pre-argocd-*` or from the files in your backup folder.

## Upgrading chat after the migration

`upgrade-chat.ps1` backs up before every upgrade because a new chart version can migrate the database, and
`helm rollback` (or an ArgoCD rollback) does not undo that: the backup is the way back. Keep that habit:

1. `bash scripts/chat-backup.sh`
2. In `apps/utility/app-chat.yaml` change `targetRevision` to the new chart version (the one your release workflow publishes). Change `argocd/utility/chat/values.yaml` in the same commit if the release adds or renames a value.
3. Push, check `argocd app diff chat`, then sync by hand.
4. Check chat.bowmans.site answers. To go back: set `targetRevision` to the old version **and** restore the database from step 1, since the new version may already have migrated it.

Secrets: `personal-secrets.yaml` stays in your chat app checkout for now. If you rotate a secret, update the Kubernetes Secret
(or Vault, once step 8 is done), not git.
