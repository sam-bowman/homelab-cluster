#!/bin/bash
# Compares the chat secrets in Vault (read into the scratch Secret chat-vault-check by
# ArgoCD) with the live ones the chat release uses. Prints only OK or MISMATCH, never a value.
#
# Usage: scripts/chat-verify-vault-secrets.sh
# Exit code 0 only if all four match.
set -uo pipefail

ns=chat
check=chat-vault-check
fail=0

hash_of() {  # secret, key -> sha256 of the decoded value, or empty if missing
  kubectl get secret "$1" -n "$ns" -o "jsonpath={.data.$2}" 2>/dev/null | base64 -d 2>/dev/null | sha256sum | cut -d' ' -f1
}

if ! kubectl get secret "$check" -n "$ns" >/dev/null 2>&1; then
  echo "Secret $check does not exist yet. Sync the chat app in ArgoCD first, and check the ExternalSecret:"
  echo "  kubectl get externalsecret chat-vault-check -n $ns"
  exit 2
fi

empty="$(printf '' | sha256sum | cut -d' ' -f1)"
compare() {  # live-secret key
  local live="$1" key="$2" a b
  a="$(hash_of "$live" "$key")"
  b="$(hash_of "$check" "$key")"
  if [ -z "$a" ] || [ "$a" = "$empty" ] || [ -z "$b" ] || [ "$b" = "$empty" ]; then
    echo "MISSING   $live / $key"; fail=1
  elif [ "$a" = "$b" ]; then
    echo "OK        $live / $key"
  else
    echo "MISMATCH  $live / $key  (Vault differs from the live secret)"; fail=1
  fi
}

compare chat-federated-chat-app-jwt        jwt-access-secret
compare chat-federated-chat-app-jwt        jwt-refresh-secret
compare chat-federated-chat-app-postgresql postgres-password
compare chat-federated-chat-app-livekit    api-secret

echo
if [ "$fail" = 0 ]; then
  echo "All four match. It is safe to switch to the Merge ExternalSecrets."
else
  echo "Do NOT switch yet: fix the Vault value (secret/CHAT) and run this again."
fi
exit "$fail"
