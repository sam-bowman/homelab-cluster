# In ../argocd/utilty/kubernetes-dashboard/secret.yaml
# we are generating a secret for the dashboard admin service
# account. This command outputs the bearer token for that
# account to log into the dashboard.
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d