vault login

cat <<EOF > /home/vault/read-policy.hcl
path "secret*" {
  capabilities = ["read"]
}
EOF

vault policy write read-policy /home/vault/read-policy.hcl

vault write auth/kubernetes/config kubernetes_host=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT

vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/main-role bound_service_account_names=* bound_service_account_namespaces=* policies=read-policy ttl=1h

echo "Create Secret Engine named 'secret'"
echo "Create 3 Secrets: APP_API_KEYS, cloudflare, github"
echo "Reference SPCs for info on each"