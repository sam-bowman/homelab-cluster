#!/bin/bash
# Creates the vault-unseal-keys Secret used by argocd/utility/vault/unsealer.yaml.
# Run this yourself: it prompts for the unseal keys (input hidden) so they never
# end up in shell history, the repo or a process list.
#
# Usage: scripts/vault-create-unseal-secret.sh [number-of-keys]   (default 3)
set -euo pipefail

count="${1:-3}"
namespace="hashicorp-vault"
name="vault-unseal-keys"

umask 077
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp:?}"' EXIT

for i in $(seq 1 "$count"); do
  read -rsp "Unseal key $i of $count: " key
  echo
  printf '%s' "$key" > "$tmp/key$i"
done

kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic "$name" -n "$namespace" --from-file="$tmp" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "Secret $namespace/$name created with $count key(s)."
