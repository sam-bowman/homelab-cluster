# I'm doing a custom modification to traefik ingress in my cluster to
# allow use of some resources across namespaces, and to allow external
# name services. For some reason restarting the cluster loses these changes, 
# and if the cluster is struggling and can't pull the corrections from the
# argocd/network/traefik folder correctly, it must be manually fixed to
# regain access
#
# The important part is the last 4 lines of the spec:
# spec:
#   valuesContent: |-
#     deployment:
#       enabled: true
#       replicas: 3
#     providers:
#       kubernetesCRD:
#         allowCrossNamespace: true
#         allowExternalNameServices: true
#
# Edit the helmchartconfig the restart the traefik deployment to have it use
# these new values.

kubectl edit helmchartconfig -n kube-system traefik
kubectl rollout restart deploy traefik -n kube-system