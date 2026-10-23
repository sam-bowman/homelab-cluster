#!/bin/bash
# Back up everything in the chat namespace before migrating it to ArgoCD.
# Read-only for the app: it takes Longhorn snapshots and copies data out.
#
# Usage: scripts/chat-backup.sh [destination-dir]
#   default destination: ~/backups/chat/<timestamp>
#
# The backup contains secrets (JWT keys, database password, LiveKit secret).
# Keep it outside the repo, readable only by you.
set -euo pipefail

export MSYS_NO_PATHCONV=1   # stop Git Bash rewriting /paths inside kubectl exec

ns=chat
stamp="$(date +%Y%m%d-%H%M%S)"
dest="${1:-$HOME/backups/chat/$stamp}"
pg_deploy=chat-federated-chat-app-postgresql
pvcs=(chat-federated-chat-app-postgresql chat-federated-chat-app-uploads)
secrets=(chat-federated-chat-app-jwt chat-federated-chat-app-postgresql chat-federated-chat-app-livekit)

umask 077
mkdir -p "$dest"/{helm,secrets}
echo "Backing up namespace $ns to $dest"

echo "1/5 Helm release (values and manifest)"
helm get values chat -n "$ns" -a -o yaml > "$dest/helm/values-all.yaml"
helm get manifest chat -n "$ns" > "$dest/helm/manifest.yaml"
helm get metadata chat -n "$ns" > "$dest/helm/metadata.txt"

echo "2/5 Secrets"
for s in "${secrets[@]}"; do
  kubectl get secret "$s" -n "$ns" -o yaml > "$dest/secrets/$s.yaml"
done

echo "3/5 Longhorn snapshots (instant, keeps both volumes as they are right now)"
for pvc in "${pvcs[@]}"; do
  vol="$(kubectl get pvc "$pvc" -n "$ns" -o jsonpath='{.spec.volumeName}')"
  snap="chat-pre-argocd-$stamp-${pvc##*-}"
  cat <<EOF | kubectl apply -f - >/dev/null
apiVersion: longhorn.io/v1beta2
kind: Snapshot
metadata:
  name: $snap
  namespace: longhorn-system
spec:
  volume: $vol
  createSnapshot: true
  labels:
    purpose: pre-argocd-migration
EOF
  for _ in $(seq 1 30); do
    ready="$(kubectl get snapshots.longhorn.io "$snap" -n longhorn-system -o jsonpath='{.status.readyToUse}' 2>/dev/null || true)"
    [ "$ready" = "true" ] && break
    sleep 2
  done
  [ "$ready" = "true" ] || { echo "snapshot $snap not ready" >&2; exit 1; }
  echo "   $snap ready"
done

echo "4/5 Postgres dump"
kubectl exec -n "$ns" "deploy/$pg_deploy" -- sh -c \
  'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -Fc -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /tmp/chat.dump && pg_restore --list /tmp/chat.dump >/dev/null'
pg_pod="$(kubectl get pods -n "$ns" -l app.kubernetes.io/component=postgresql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
[ -n "$pg_pod" ] || pg_pod="$(kubectl get pods -n "$ns" -o name | grep postgresql | head -1 | cut -d/ -f2)"
# kubectl.exe misreads Git Bash paths (/c/Users/...) as relative to the current drive, and "C:\..." as a pod name,
# so copy into the current directory with a relative path.
(cd "$dest" && kubectl cp -n "$ns" --retries=10 "$pg_pod:/tmp/chat.dump" ./chat.dump)
[ -s "$dest/chat.dump" ] || { echo "chat.dump was not copied" >&2; exit 1; }
kubectl exec -n "$ns" "$pg_pod" -- rm -f /tmp/chat.dump

echo "5/5 Uploads"
srv_pod="$(kubectl get pods -n "$ns" -o name | grep -- '-server-' | head -1 | cut -d/ -f2)"
# lost+found is the volume's own folder and is not readable by the app user; skip it.
kubectl exec -n "$ns" "$srv_pod" -c server -- rm -f /tmp/uploads.tar
kubectl exec -n "$ns" "$srv_pod" -c server -- tar cf /tmp/uploads.tar --exclude=./lost+found -C /app/uploads .
(cd "$dest" && kubectl cp -n "$ns" -c server --retries=10 "$srv_pod:/tmp/uploads.tar" ./uploads.tar)
[ -s "$dest/uploads.tar" ] || { echo "uploads.tar was not copied" >&2; exit 1; }
kubectl exec -n "$ns" "$srv_pod" -c server -- rm -f /tmp/uploads.tar
tar tf "$dest/uploads.tar" >/dev/null

echo
echo "Done. Contents of $dest:"
ls -l "$dest" "$dest/helm" "$dest/secrets" | grep -v '^total'
echo
echo "To restore the database later:  pg_restore -c -U <user> -d <db> chat.dump"
